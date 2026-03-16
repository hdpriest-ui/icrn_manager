#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# ── Colour helpers ─────────────────────────────────────────────────────────
RED='\033[0;31m'; YELLOW='\033[1;33m'; GREEN='\033[0;32m'; BOLD='\033[1m'; NC='\033[0m'
info() { echo -e "${BOLD}[deploy]${NC} $*"; }
ok()   { echo -e "${GREEN}[  ok  ]${NC} $*"; }
warn() { echo -e "${YELLOW}[ warn ]${NC} $*"; }
fail() { echo -e "${RED}[ fail ]${NC} $*" >&2; }
die()  { fail "$*"; exit 1; }

# ── Flags ──────────────────────────────────────────────────────────────────
ENV=""
DRY_RUN=false
KICK_INDEXER=false
RUN_CONTAINERS=false
RUN_SCRIPTS=false
RUN_KUBERNETES=false
RUN_VERIFY=false
PHASE_EXPLICIT=false

usage() {
    cat <<EOF
Usage: $0 --env <dev|prod> [options] [phases]

Required:
  --env dev|prod  Target environment

Phases (default: all):
  --containers    Build and push Docker images
  --scripts       Deploy CLI scripts to campus cluster
  --kubernetes    Apply Kubernetes manifests
  --verify        Health-check the web service

Options:
  --kick-indexer  Trigger a manual indexer run after kubernetes phase
  --dry-run       Print commands without executing
  -h, --help      Show this help

Config files: $SCRIPT_DIR/deploy.dev.config, $SCRIPT_DIR/deploy.prod.config
EOF
}

while [[ $# -gt 0 ]]; do
    case $1 in
        --env)
            [[ $# -gt 1 ]] || die "--env requires an argument: dev or prod"
            ENV="$2"; shift
            [[ "$ENV" == "dev" || "$ENV" == "prod" ]] || die "--env must be 'dev' or 'prod', got: $ENV"
            ;;
        --containers)   RUN_CONTAINERS=true;  PHASE_EXPLICIT=true ;;
        --scripts)      RUN_SCRIPTS=true;     PHASE_EXPLICIT=true ;;
        --kubernetes)   RUN_KUBERNETES=true;  PHASE_EXPLICIT=true ;;
        --verify)       RUN_VERIFY=true;      PHASE_EXPLICIT=true ;;
        --kick-indexer) KICK_INDEXER=true ;;
        --dry-run)      DRY_RUN=true ;;
        -h|--help)      usage; exit 0 ;;
        *) die "Unknown flag: $1. Run with --help for usage." ;;
    esac
    shift
done

[[ -n "$ENV" ]] || die "--env is required. Run with --help for usage."

if ! $PHASE_EXPLICIT; then
    RUN_CONTAINERS=true
    RUN_SCRIPTS=true
    RUN_KUBERNETES=true
    RUN_VERIFY=true
fi

# ── Load config ────────────────────────────────────────────────────────────
CONFIG_FILE="$SCRIPT_DIR/deploy.${ENV}.config"
if [[ ! -f "$CONFIG_FILE" ]]; then
    die "Config not found: $CONFIG_FILE\nCopy deploy/deploy.${ENV}.config.example to deploy/deploy.${ENV}.config and fill in your values."
fi

# Snapshot any vars already set in the environment before sourcing the config —
# inline overrides (e.g. CC_USER=foo ./deploy.sh) take precedence over the file.
declare -A _env_overrides=()
for _var in CC_HOST CC_USER CC_BIN_PATH DOCKER_REGISTRY IMAGE_TAG KUBECTL_CONTEXT NAMESPACE DEPLOY_BRANCH; do
    [[ -v "$_var" ]] && _env_overrides["$_var"]="${!_var}"
done

# shellcheck source=/dev/null
source "$CONFIG_FILE"

# Restore inline overrides
for _var in "${!_env_overrides[@]}"; do
    printf -v "$_var" '%s' "${_env_overrides[$_var]}"
done
unset _var _env_overrides

# DEPLOY_BRANCH defaults to the current git branch if not set in config or env
DEPLOY_BRANCH="${DEPLOY_BRANCH:-$(git -C "$REPO_ROOT" rev-parse --abbrev-ref HEAD)}"

# ── Dry-run wrapper ────────────────────────────────────────────────────────
run() {
    if $DRY_RUN; then
        echo -e "${YELLOW}[dry-run]${NC} $(printf '%q ' "$@")"
    else
        "$@"
    fi
}

# ── Prod confirmation ──────────────────────────────────────────────────────
confirm_prod() {
    if [[ "$ENV" != "prod" ]] || $DRY_RUN; then return; fi

    echo ""
    echo -e "${RED}${BOLD}  !! PRODUCTION DEPLOYMENT !!${NC}"
    echo ""
    echo "  Environment: prod"
    echo "  Branch:      $DEPLOY_BRANCH"
    echo "  Cluster:     $KUBECTL_CONTEXT"
    echo "  CC path:     $CC_BIN_PATH"
    echo ""
    read -r -p "  Type 'yes' to continue: " answer
    echo ""
    [[ "$answer" == "yes" ]] || die "Aborted."
}

# ── Preflight ──────────────────────────────────────────────────────────────
PREFLIGHT_ERRORS=0

check() {
    local label=$1; local detail=$2; shift 2
    if "$@" &>/dev/null 2>&1; then
        ok "  $label"
        echo -e "          ${NC}↳ $detail"
    else
        fail "  $label"
        echo -e "          ↳ $detail"
        PREFLIGHT_ERRORS=$(( PREFLIGHT_ERRORS + 1 ))
    fi
}

check_var() {
    local name=$1
    if [[ -n "${!name:-}" ]]; then
        ok "  config: $name = ${!name}"
    else
        fail "  config: $name is not set"
        PREFLIGHT_ERRORS=$(( PREFLIGHT_ERRORS + 1 ))
    fi
}

preflight() {
    info "Preflight checks"
    echo ""

    info "Required config vars:"
    local required_vars=(CC_BIN_PATH DOCKER_REGISTRY IMAGE_TAG KUBECTL_CONTEXT NAMESPACE INGRESS_URL)
    for var in "${required_vars[@]}"; do
        check_var "$var"
    done
    echo ""

    if $RUN_CONTAINERS; then
        info "Container build checks:"
        check "docker in PATH" \
              "which docker" \
              command -v docker
        check "docker daemon accessible" \
              "docker info" \
              docker info
        if [[ ! -f ~/.docker/config.json ]] || \
           ! grep -q "index.docker.io" ~/.docker/config.json 2>/dev/null; then
            warn "  Could not confirm Docker Hub credentials in ~/.docker/config.json"
            warn "  Push will fail if you are not logged in. Run: docker login"
        else
            ok "  Docker Hub credentials present"
            echo -e "          ↳ grep index.docker.io ~/.docker/config.json"
        fi
        echo ""
    fi

    if $RUN_KUBERNETES || $RUN_VERIFY; then
        info "Kubernetes checks:"
        check "kubectl in PATH" \
              "which kubectl" \
              command -v kubectl
        check "helm in PATH" \
              "which helm" \
              command -v helm
        check "context '$KUBECTL_CONTEXT' exists" \
              "kubectl config get-contexts $KUBECTL_CONTEXT" \
              kubectl config get-contexts "$KUBECTL_CONTEXT"
        check "context '$KUBECTL_CONTEXT' is active" \
              "kubectl config current-context == $KUBECTL_CONTEXT" \
              bash -c "[[ \$(kubectl config current-context) == '$KUBECTL_CONTEXT' ]]"
        echo ""
    fi

    if ! git -C "$REPO_ROOT" diff --quiet HEAD 2>/dev/null; then
        warn "Working tree has uncommitted changes."
        warn "Curled scripts will reflect GitHub (branch: $DEPLOY_BRANCH), not local edits."
        echo ""
    fi

    if (( PREFLIGHT_ERRORS > 0 )); then
        die "$PREFLIGHT_ERRORS preflight check(s) failed — fix the above before deploying."
    fi

    ok "All preflight checks passed."
    echo ""
}

# ── Phase 1: containers ────────────────────────────────────────────────────
phase_containers() {
    info "Phase 1: Building and pushing container images"
    echo ""

    info "Building indexer image..."
    run docker build \
        -t "${DOCKER_REGISTRY}/icrn-kernel-indexer:${IMAGE_TAG}" \
        -f "$REPO_ROOT/kernel-indexer/Dockerfile" \
        "$REPO_ROOT/kernel-indexer"
    run docker push "${DOCKER_REGISTRY}/icrn-kernel-indexer:${IMAGE_TAG}"
    ok "Indexer image pushed: ${DOCKER_REGISTRY}/icrn-kernel-indexer:${IMAGE_TAG}"
    echo ""

    info "Building web image..."
    run docker build \
        -t "${DOCKER_REGISTRY}/icrn-kernel-webserver:${IMAGE_TAG}" \
        -f "$REPO_ROOT/web/Dockerfile" \
        "$REPO_ROOT/web"
    run docker push "${DOCKER_REGISTRY}/icrn-kernel-webserver:${IMAGE_TAG}"
    ok "Web image pushed: ${DOCKER_REGISTRY}/icrn-kernel-webserver:${IMAGE_TAG}"
    echo ""
}

# ── Phase 2: CLI scripts ───────────────────────────────────────────────────
phase_scripts() {
    local base_url="https://raw.githubusercontent.com/ncsa/icrn_kernel_manager/${DEPLOY_BRANCH}"

    info "Phase 2: CLI scripts — manual step required"
    echo ""
    echo "  SSH to the campus cluster and run the following commands:"
    echo ""
    echo "    curl -fsSL '${base_url}/icrn_manager' \\"
    echo "        -o '${CC_BIN_PATH}/icrn_manager'"
    echo ""
    echo "    curl -fsSL '${base_url}/update_r_libs.sh' \\"
    echo "        -o '${CC_BIN_PATH}/update_r_libs.sh'"
    echo ""
    echo "    chmod +x '${CC_BIN_PATH}/icrn_manager' '${CC_BIN_PATH}/update_r_libs.sh'"
    echo ""
}

# ── Phase 3: Kubernetes ────────────────────────────────────────────────────
phase_kubernetes() {
    info "Phase 3: Deploying with Helm"
    echo ""

    local values_file="$REPO_ROOT/charts/icrn-kernel-manager/values.${ENV}.yaml"
    if [[ ! -f "$values_file" ]]; then
        die "Helm values file not found: $values_file\nCopy charts/icrn-kernel-manager/values.${ENV}.yaml.example to values.${ENV}.yaml and fill in your values."
    fi

    run helm upgrade --install icrn-kernel-manager \
        "$REPO_ROOT/charts/icrn-kernel-manager" \
        -f "$values_file" \
        --set "image.webserver.tag=${IMAGE_TAG}" \
        --set "image.indexer.tag=${IMAGE_TAG}" \
        --namespace "$NAMESPACE" \
        --wait --timeout 15m

    ok "Helm release deployed."
    echo ""

    if $KICK_INDEXER; then
        info "Triggering indexer run..."
        run "$REPO_ROOT/kubernetes/kick-cronjob.sh"
        ok "Indexer job created. Tail logs with:"
        echo "    kubectl -n $NAMESPACE logs -l component=kernel-indexer --follow"
        echo ""
    fi
}

# ── Phase 4: Verify ────────────────────────────────────────────────────────
phase_verify() {
    info "Phase 4: Verifying web service via ingress"
    info "  URL: $INGRESS_URL"
    echo ""

    if $DRY_RUN; then
        run curl -sf "${INGRESS_URL}/health"
        run curl -sf "${INGRESS_URL}/api/languages"
        return
    fi

    local health languages
    if health=$(curl -sf "${INGRESS_URL}/health") && \
       languages=$(curl -sf "${INGRESS_URL}/api/languages"); then
        ok "Health:    $health"
        ok "Languages: $languages"
    else
        die "Web service health check failed. Check pod logs: kubectl -n $NAMESPACE logs -l app=icrn-web"
    fi

    echo ""
    ok "Verification passed."
    echo ""
}

# ── Main ───────────────────────────────────────────────────────────────────
echo ""
info "ICRN Kernel Manager — Deploy [${ENV}]"
info "Branch: $DEPLOY_BRANCH"
$DRY_RUN && warn "DRY-RUN mode enabled — no changes will be made"
echo ""

confirm_prod
preflight

$RUN_CONTAINERS && phase_containers
$RUN_SCRIPTS    && phase_scripts
$RUN_KUBERNETES && phase_kubernetes
$RUN_VERIFY     && phase_verify

ok "Deploy complete."
