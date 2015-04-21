#!/bin/bash
printf "This will download and run scripts to configure GVL command-line utilities, including environment modules, RStudio, and IPython Notebook. Press any key to continue."
read -n 1 _input
if [ -d "/opt/gvl/gvl_commandline_utilities" ]; then
   cd /opt/gvl/gvl_commandline_utilities
   sh run_all.sh
fi
printf "Press any key to close"
read -n 1 _input