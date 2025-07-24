icrn_manager kernels use none
conda create --solver=libmamba -c r -y -n R_cowsay r-base=4.4.3
conda activate R_cowsay
Rscript -e 'install.packages("cowsay", repos="http://cran.us.r-project.org")'
conda install -y --solver=libmamba conda-pack
conda pack -n R_cowsay -o ~/conda-packs/R_cowsay.conda.pack.tar.gz