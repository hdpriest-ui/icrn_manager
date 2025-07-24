# This Dockerfile is installing R and RStudio Server on Ubuntu 22.04.03
# purpose of this dockerfile is to create a test environment for the ICRN manager
# this docker is intended to mimic the NCSA ICRN JupyterHub environment
# Use the minimal-notebook as base
ARG JUPYTER_VERSION=latest
FROM jupyter/minimal-notebook:${JUPYTER_VERSION}

ARG ICRN_MANAGER_PATH=/sw/icrn/jupyter/icrn_ncsa_resources/tools/icrn_manager/
ARG ICRN_KERNELS_PATH=/sw/icrn/jupyter/icrn_ncsa_resources/kernels/
ARG ICRN_TESTS_PATH=/sw/icrn/jupyter/icrn_ncsa_resources/tests/

# Switch to root to install additional packages
USER root

WORKDIR /

# Install R and its dependencies
RUN apt update -qq && \
    apt install -y --no-install-recommends software-properties-common dirmngr && \
    wget -qO- https://cloud.r-project.org/bin/linux/ubuntu/marutter_pubkey.asc | tee -a /etc/apt/trusted.gpg.d/cran_ubuntu_key.asc && \
    add-apt-repository "deb https://cloud.r-project.org/bin/linux/ubuntu $(lsb_release -cs)-cran40/" && \
    apt install -y r-base

# Installs Rstudio Server
RUN apt install -y --no-install-recommends gdebi-core && \
    wget https://download2.rstudio.org/server/jammy/amd64/rstudio-server-2024.12.0-467-amd64.deb && \
    gdebi -n rstudio-server-2024.12.0-467-amd64.deb && \
    rm -f rstudio-server-2024.12.0-467-amd64.deb

# Install tidyverse and jq (required by icrn_manager)
RUN apt update -qq && apt install --yes --no-install-recommends wget ca-certificates gnupg jq && \
    wget -q -O- https://eddelbuettel.github.io/r2u/assets/dirk_eddelbuettel_key.asc | tee -a /etc/apt/trusted.gpg.d/cranapt_key.asc && \
    echo "deb [arch=amd64] https://r2u.stat.illinois.edu/ubuntu jammy main" > /etc/apt/sources.list.d/cranapt.list && \
    apt update -qq && \
    apt install --yes --no-install-recommends  r-cran-data.table r-cran-tidyverse && \
    apt clean && \
    rm -rf /var/lib/apt/lists/*

# Installs the jupyter-rsession-proxy
RUN pip install jupyter-rsession-proxy && \
    chown -R $NB_USER:users /home/$NB_USER/.cache

# Switch to default working directory
WORKDIR /home/$NB_USER

RUN mkdir -p $ICRN_KERNELS_PATH && \
 mkdir -p $ICRN_MANAGER_PATH 

# Copy icrn_manager tools to /usr/local/bin for system-wide access
COPY ./icrn_manager /usr/local/bin/icrn_manager
COPY ./update_r_libs.sh /usr/local/bin/update_r_libs.sh

# Make the icrn_manager tools executable
RUN chmod +x /usr/local/bin/icrn_manager && \
    chmod +x /usr/local/bin/update_r_libs.sh

RUN chown -R $NB_USER:users /sw

# Switch to default NB_USER
USER $NB_USER

RUN icrn_manager kernels init $ICRN_KERNELS_PATH