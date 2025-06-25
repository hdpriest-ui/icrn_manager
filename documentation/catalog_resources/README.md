# how to create an R library

The beginning here is that we are going to create a library of packages for use in the ICRN's R-Studio environment.

It is important to remember that we're creating an environment for others to use via the library management system, so we're not going to do everything as we typically would do it, for R.

To start, you'll want to create your environment with a version of R that matches whatever ICRN's R-studio is on at the moment:

```sh
(base) [hdpriest@cc-login3 ~]$ conda create --solver=libmamba -c r -y -n R_vctrs r-base=4.4.3
(base) [hdpriest@cc-login3 ~]$ conda activate R_vctrs
(R_vctrs) [hdpriest@cc-login3 ~]$ which R
~/.conda/envs/R_vctrs/bin/R
(R_vctrs) [hdpriest@cc-login3 ~]$ which Rscript
~/.conda/envs/R_vctrs/bin/Rscript
(R_vctrs) [hdpriest@cc-login3 ~]$ R --version
R version 4.4.3 (2025-02-28) -- "Trophy Case"
```

You will need to confirm that you're installing packages into the conda environment's 'base' R library. This is distinct from your own, user-level library.
```sh
(R_vctrs) [hdpriest@cc-login3 ~]$ Rscript -e '.libPaths()'
[1] "/u/hdpriest/.conda/envs/R_vctrs/lib/R/library"  # conda environment 'R_vctrs' base R library

(R_vctrs) [hdpriest@cc-login3 ~]$ Rscript -e 'install.packages("vctrs", repos="http://cran.us.r-project.org" )'
also installing the dependencies ‘cli’, ‘glue’, ‘lifecycle’, ‘rlang’

```

We can see that the target location holds our libraries:
```sh
(R_vctrs) [hdpriest@cc-login3 ~]$ ll /u/hdpriest/.conda/envs/R_vctrs/lib/R/library/
total 0
# ...
drwx--S--- 2 hdpriest hdpriest-ic 4.0K Jun  4 10:52 utils
drwxr-xr-x 2 hdpriest hdpriest-ic 4.0K Jun  4 10:59 cli # <------
drwxr-xr-x 2 hdpriest hdpriest-ic 4.0K Jun  4 10:59 glue # <------
drwxr-xr-x 2 hdpriest hdpriest-ic 4.0K Jun  4 10:59 rlang # <------
drwxr-xr-x 2 hdpriest hdpriest-ic 4.0K Jun  4 10:59 lifecycle   # <------
drwxr-xr-x 2 hdpriest hdpriest-ic 4.0K Jun  4 11:00 vctrs # <------
```

We'll create a 2nd one, just for show:
```sh
(R_cowsay) [hdpriest@cc-login3 ~]$ conda create --solver=libmamba -c r -y -n R_cowsay r-base=4.4.3
# ...
(base) [hdpriest@cc-login3 ~]$ conda activate R_cowsay
(R_cowsay) [hdpriest@cc-login3 ~]$ Rscript -e '.libPaths()'
[1] "/u/hdpriest/.conda/envs/R_cowsay/lib/R/library"
(R_cowsay) [hdpriest@cc-login3 ~]$ which R
~/.conda/envs/R_cowsay/bin/R
(R_cowsay) [hdpriest@cc-login3 ~]$ which Rscript
~/.conda/envs/R_cowsay/bin/Rscript
(R_cowsay) [hdpriest@cc-login3 ~]$ R --version
(R_cowsay) [hdpriest@cc-login3 ~]$ Rscript -e 'install.packages("cowsay", repos="http://cran.us.r-project.org")'
also installing the dependencies ‘crayon’, ‘rlang’
# ...
(R_cowsay) [hdpriest@cc-login3 ~]$ ls -lhart /u/hdpriest/.conda/envs/R_cowsay/lib/R/library/
total 0
# ...
drwxr-xr-x 2 hdpriest hdpriest-ic 4.0K Jun  4 11:04 rlang
drwxr-xr-x 2 hdpriest hdpriest-ic 4.0K Jun  4 11:04 cowsay
```

Now we can conda-pack these.
```sh
# activate each environment, and within it, do:
(R_cowsay) [hdpriest@cc-login3 ~]$ mkdir -p conda_packs
(R_cowsay) [hdpriest@cc-login3 ~]$ conda install -y --solver=libmamba conda-pack
(R_vctrs) [hdpriest@cc-login3 ~]$ conda install -y --solver=libmamba conda-pack

# then we can pack each environment
(R_vctrs) [hdpriest@cc-login3 ~]$ conda pack -n R_vctrs -o ./conda_packs/R_vctrs.conda.pack.tar.gz
Collecting packages...
Packing environment at '/u/hdpriest/.conda/envs/R_vctrs' to './conda_packs/R_vctrs.conda.pack.tar.gz'
[########################################] | 100% Completed | 39.4s

# Note the conda environment change!
(R_cowsay) [hdpriest@cc-login3 ~]$ conda pack -n R_cowsay -o ./conda_packs/R_cowsay.conda.pack.tar.gz
Collecting packages...
Packing environment at '/u/hdpriest/.conda/envs/R_cowsay' to './conda_packs/R_cowsay.conda.pack.tar.gz'
[########################################] | 100% Completed | 27.4s
```

Then they need to be placed in the central repo and made available:
```sh
(base) [hdpriest@cc-login3 ~]$ mkdir ~/icrn_temp_repository/
(base) [hdpriest@cc-login3 ~]$ mkdir ~/icrn_temp_repository/r_libraries
(base) [hdpriest@cc-login3 ~]$ mkdir ~/icrn_temp_repository/r_libraries/cowsay
(base) [hdpriest@cc-login3 ~]$ mkdir ~/icrn_temp_repository/r_libraries/cowsay/1.0
(base) [hdpriest@cc-login3 ~]$ cp -p ~/conda_packs/R_cowsay.conda.pack.tar.gz ~/icrn_temp_repository/r_libraries/cowsay/1.0/
(base) [hdpriest@cc-login3 ~]$ mkdir ~/icrn_temp_repository/r_libraries/vctrs
(base) [hdpriest@cc-login3 ~]$ mkdir ~/icrn_temp_repository/r_libraries/vctrs/1.0
(base) [hdpriest@cc-login3 ~]$ cp -p ~/conda_packs/R_vctrs.conda.pack.tar.gz ~/icrn_temp_repository/r_libraries/vctrs/1.0/
```

We then need to create the central catalog json:
```sh
(base) [hdpriest@cc-login3 ~]$ echo "{
    \"vctrs\":{
            \"1.0\":{
                    \"conda-pack\":\"R_vctrs.conda.pack.tar.gz\",
                    \"manifest\": \"\"
            }
    },
    \"cowsay\":{
            \"1.0\":{
                    \"conda-pack\":\"R_cowsay.conda.pack.tar.gz\",
                    \"manifest\": \"\"
            }
    }
}" > ~/icrn_temp_repository/r_libraries/icrn_catalogue.json

```

Obviously, for subsequent additions to the catalog, you will need to enter those libraries into the appropriate structure without clobbering the existing catalog. 

Version numbers are actually strings, of course, which allows for flexibility. Package & version number must uniquely identify a tarball. The manifest parameter is intended for future use to identify the contents of each library, enabling reverse-lookup of libraries from desired packages.