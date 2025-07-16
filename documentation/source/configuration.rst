Configuration
=============

Central Repository Structure
---------------------------
The central repository has the following structure:

.. code-block:: text

   <central_repo>/
        Python/
           ...
        R/
           icrn_catalogue.json
              <library_name>/
                 <version>/
                    <conda-pack>.tar.gz
        
         

Example catalog file (icrn_catalogue.json):

.. code-block:: json

   {
       "vctrs":{
               "1.0":{
                       "conda-pack":"R_vctrs.conda.pack.tar.gz",
                       "manifest": ""
               }
       },
       "cowsay":{
               "1.0":{
                       "conda-pack":"R_cowsay.conda.pack.tar.gz",
                       "manifest": ""
               }
       }
   }

User Configuration
------------------
User-specific configuration is stored in:

- ~/.icrn/manager_config.json
- ~/.icrn/icrn_libraries/user_catalog.json

These files are managed automatically by the `init` and other commands.

Best Practices
--------------
- Use string version numbers for flexibility.
- Ensure each (library, version) pair uniquely identifies a tarball.
- The `manifest` field is reserved for future use (e.g., listing included R packages). 