#!/bin/bash
if [ -d "gvl_commandline_utilities" ]
then
    printf "This will add a new user to the system. Press any key to continue."
    read -n 1 _input
    cd gvl_commandline_utilities
    printf "Please enter the name for the user: "
    read username
    sh setup_user.sh $username
else
    printf "\nYou need to run 'Set up GVL utilities' before adding a user\n\n"
fi
printf "\nPress any key to close"
read -n 1 _input