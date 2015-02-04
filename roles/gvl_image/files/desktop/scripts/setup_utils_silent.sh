#!/bin/bash
printf "This will download and run scripts to configure GVL command-line utilities, including environment modules, RStudio, and IPython Notebook. Press any key to continue."
if [ -d "gvl_commandline_utilities" ]; then
   cd gvl_commandline_utilities
   git pull
else
   git clone https://github.com/claresloggett/gvl_commandline_utilities
   cd gvl_commandline_utilities
fi
source run_all.sh -s
sudo su - researcher -c "screen -d -m -S ipython /home/ubuntu/ipython_screen.sh"