#!/bin/bash
if [ -d "gvl_commandline_utilities" ]
then
    printf "This will start the IPython Notebooki as the research user. Press any key to continue."
    read -n 1 _input
    #printf "Please enter the name of the user you want to run ipython as - note: you must have already created this user: "
    #read username
    sudo su - researcher -c "screen -d -m -S ipython /opt/gvl/scripts/cmdlineutils/ipython_screen.sh"
else
    printf "\nYou need to run 'Set up GVL utilities' before adding a user\n\n"
fi
printf "\nPress any key to close"
read -n 1 _input