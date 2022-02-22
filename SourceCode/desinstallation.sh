#!/bin/bash
# @(#) desinstallation.sh

read -p "Êtes-vous sûr de supprimer cette commande ? (Y/N)" choix

case "${choix}" in
	"Y"|"y" )
				rm -rf ~/proprescripts
				sed -i -e '/rvsh/d' ~/.bash_profile		# Parce qu'on a amené l'identificateur (#rvsh) quand on l'a écrit.
				sed -i -e '/rvsh/d' ~/.bashrc			# On peut donc faire comme ca.
				;;

	"N"|"n" )
				exit 0
				;;

	* )
				echo "Bad commande ! Êtes-vous sûr de supprimer cette commande ? "
				echo "Usage : Y/N"
				sleep 3
				exit 0
				;;
esac
