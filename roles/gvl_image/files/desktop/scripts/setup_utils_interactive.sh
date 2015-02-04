#!/bin/bash
printf "This will download and run scripts to configure GVL command-line utilities, including environment modules, RStudio, and IPython Notebook. Press any key to continue."
read -n 1 _input
if [ -d "gvl_commandline_utilities" ]; then
   cd gvl_commandline_utilities
   git pull
else
   git clone https://github.com/claresloggett/gvl_commandline_utilities
   cd gvl_commandline_utilities
fi
sh run_all.sh
printf "Press any key to close"
read -n 1 _input