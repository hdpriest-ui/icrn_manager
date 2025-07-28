# install custom kernel

open terminal

first time setup python config

```
conda config --prepend envs_dirs ${HOME}/conda
```

create the kernel, addding all packages

```
conda create -y -n astro 'numpy<2' python=3.11 astropy matplotlib spectral-cube pandas
conda activate astro

# install jupyterlab to enable integration
conda install jupyterlab
conda install conda-pack
```