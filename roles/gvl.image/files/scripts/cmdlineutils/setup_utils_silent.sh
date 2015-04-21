#!/bin/bash
printf "This will download and run scripts to configure GVL command-line utilities, including environment modules, RStudio, and IPython Notebook. Press any key to continue."
if [ -d "/opt/gvl/gvl_commandline_utilities" ]; then
   cd /opt/gvl/gvl_commandline_utilities
   sudo su - ubuntu -c "source run_all.sh -s"
   sudo su - researcher -c "screen -d -m -S ipython /opt/gvl/scripts/cmdlineutils/ipython_screen.sh"
fi
