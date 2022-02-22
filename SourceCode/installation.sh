#!/bin/bash
# @(#)installation.sh

# Pour créer des répertoire nécessaires
mkdir ~/proprescripts
mkdir ~/proprescripts/rvsh
cp ./rvsh.sh ~/proprescripts
cp ./write.sh ~/proprescripts


# Pour définir le synonyme rvsh de la comande "bash ~/proprescripts/rvsh.sh"
if [ ! -f ~/.bash_profile ]; then
	touch ~/.bash_profile
fi
echo "if [ \"\${BASH-no}\" != \"no\" ]; then  #rvsh" >> ~/.bash_profile
echo "[ -r ~/.bashrc ] && . ~/.bashrc  #rvsh" >> ~/.bash_profile
echo "fi  #rvsh" >> ~/.bash_profile

if [ ! -f ~/.bashrc ]; then
	touch ~/.bashrc
fi
printf "alias rvsh=\"bash ~/proprescripts/rvsh.sh\"\n" >> ~/.bashrc
echo "export pid_write=0 #rvsh" >> ~/.bashrc

source ~/.bashrc

# Pour créer des fichiers nécessaires -- passwd droit machine_liste
cd ~/proprescripts/rvsh
touch passwd droit machine_liste
touch who_liste users rhost
touch write
