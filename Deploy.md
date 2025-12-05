# deploying the ICRN kernel manager services

## get the most recent changes moved to campus cluster

#### ONCE
Move or re-create the central repo located at `/sw/icrn/jupyter/icrn_ncsa_resources/Kernels/` to 
`/sw/icrn/dev/kernels/`

copy tools to path loc (dev paths):
```sh
cp ./icrn_manager /sw/icrn/dev/bin/
cp ./update_r_libs.sh /sw/icrn/dev/bin/
chmod +x /sw/icrn/dev/bin/icrn_manager
chmod +x /sw/icrn/dev/bin/update_r_libs.sh
```

Change Kernel Central Repo Path in icrn_manager to reflect environment
-- what is the signal in icrn that we are in prod/dev? --


## Changes needed to ICRN containers in dev
JQ installed on container


## running the kernel index process

This is done via a container, currently located at: `docker://hdpriest0uiuc/icrn-kernel-indexer`;

Tested on campus cluster via apptainer, this indexes the central repository of kernels and places the two manifest files at their location in `/sw/icrn/jupyter/icrn_ncsa_resources/Kernels/`. If we want to keep them somewhere else, we can shift that via bind-mount changes.

```sh
(base) [hdpriest@cc-login2 icrn_manager]$ cd /sw/icrn/jupyter/icrn_ncsa_resources/tools/icrn_manager
(base) [hdpriest@cc-login2 icrn_manager]$ apptainer pull docker://hdpriest0uiuc/icrn-kernel-indexer

(base) [hdpriest@cc-login2 icrn_manager]$ apptainer run --bind /sw/icrn/jupyter/icrn_ncsa_resources/Kernels:/sw/icrn/jupyter/icrn_ncsa_resources/Kernels icrn-kernel-indexer_latest.sif

#### DEV
(base) [hdpriest@cc-login2 icrn_manager]$ apptainer run --bind /sw/icrn/dev/kernels:/sw/icrn/dev/kernels icrn-kernel-indexer_latest.sif
## ... output
Collated manifest written to: /sw/icrn/jupyter/icrn_ncsa_resources/Kernels/collated_manifests.json
## ... output
Package-centric index written to: /sw/icrn/jupyter/icrn_ncsa_resources/Kernels/package_index.json
## ... output
```


## running the web server, based on the index contents of the central repository

Docker build from git root:
```sh
docker build -t icrn-web -f web/Dockerfile web/
```

Assuming you have a built container (obtained from dockerhub, or built locally), the container expects bind mounts to the location where the manifests/index are kept, and so is flexible for its back-end storage as long as it has access to the same disk mount as the index job:
```bash
docker run -d -p 8080:80 --name icrn-web \
  -v /sw/icrn/dev/kernels:/app/data:ro \
  icrn-web
```

Generic docker run commands:
```bash
docker run -d -p 8080:80 --name icrn-web \
  -v /path/to/collated_manifests.json:/app/data/collated_manifests.json \
  -v /path/to/package_index.json:/app/data/package_index.json \
  icrn-web
```
