#!/bin/bash
# @(#)
# @(#) Cette fichier a pour objectif de créer un réseau virtuel de machine Linux par créer une nouvelle commande shell,
# @(#) Elle fonctionne selon deux modes:
# @(#) le mode CONNECT et le mode ADMIN
# @(#)      rvsh -connect nom_machine nom_utilisateur
# @(#)      rvsh -admin
# @(#)
# @(#)
# @(#) Created by Armand XU on 2019/1/13.
# @(#) Copyright © 2019 Armand XU. All rights reserved.
# @(#)
# @(#) Développé sur macOS 10.14.2, GNU bash, version 3.2.57(1)-release (x86_64-apple-darwin18)
# @(#) Copyright (C) 2007 Free Software Foundation, Inc.
# @(#)
# @(#) En coopération entre Ziyi XU et Weihao YUAN, avec l’aide d’internet et des diapos de LO03.

densifier() {																	#usage : densifier "string"
	echo -n $1 | md5
}

who_shell() {
	cat ~/proprescripts/rvsh/who_liste | grep ${machine}  | cut -f1-5
}

users_shell() {
	cat ~/proprescripts/rvsh/users
}

entrer_verifier(){																#usage : entrer_verifier nom_utilisateur
																				#permet à l'utilisateur de saisir le mot de passe et vérifier avec le mot_référence
	read -p "Saisissez le code S.V.P." -s motdepasse							#renvoye 1 : vérification passée
	temp=`densifier ${motdepasse}`												#renvoye 0 : vérification n'a pas passée
	refe=`cat ~/proprescripts/rvsh/passwd | grep $1 | cut -f2 -d ':'`
	#echo ${temp}
	#echo ${refe}

	if [[ ${temp} == ${refe} ]]; then
		return 1
	elif [[ ${temp} != ${refe} ]]; then
		return 0
	fi
}

machine_verifier() {															#usage : machine_verifier nom_machine
	if [[ `cat ~/proprescripts/rvsh/machine_liste | grep -w -c $1` == 1 ]]; then
		return 1
	else
		echo "La machine $1 n'existe pas !"
		echo "Vérifier de nouveau !"
		exit 0
	fi

}

get_uid(){																		#obtenir le UID de l'utilisateur &&& usage : get_uid nom_utilisateur
	uid=`cat ~/proprescripts/rvsh/passwd | grep -w $1 | cut -f3 -d ':'`
	echo ${uid}
}

droit_verifier(){																#usage droit_verifier nom_utilisateur nom_machine
	uid=`get_uid $1`
	resulta=`sed -n '/'"${uid}"'/p' ~/proprescripts/rvsh/droit | grep -c -w "$2"`
	#sed -n '/'"${uid}"'/p' ~/proprescripts/rvsh/droit
	#echo resultadroit = ${resulta}

	if [[ ${resulta} == "0" ]]; then
		return 0
	elif [[ ${resulta} != "0" ]]; then
		return 1
	fi																			#0 n'a pas trouvé!!
}

login() {																		#usage : login nom_utilisateur nom_machine
	droit_verifier $1 $2
	((resulta=$?))
	#echo resulta = ${resulta}

	if [[ ${resulta} == 0 ]]; then
		echo "L'utilisateur $1 na pas de droit !"
		echo "Vérifier de nouveau !"
		exit 0
	fi

	j=10
	flag=0

	if [[ `grep -c -w $1 ~/proprescripts/rvsh/passwd` == 0 ]]; then
		echo "Utilisateur $1 n'existe pas !"
		echo "Vérifier de nouveau !"
		exit 0
	fi

	while [[ 1 ]]; do
		entrer_verifier $1
		((resulta=$?))

		if [[ ${resulta} != 1 && $j != 0 ]]; then
				echo Désolé ! WRONG !
				((j--))
				echo "Vous avez encore ${j} fois de tentative"
			elif [[ ${resulta} == 1 && $j != 0 ]]; then
				#armandxu 20190209
				month=`date +%b` #(Jan..Dec)
				day=`date +%d` #(01..31)
				time=`date +%l:%M` #%l:(1..12) %M:(00..59)
				nb_tty=`cat ~/proprescripts/rvsh/who_liste | grep -w -c $1`
				((nb_tty++))
				#printf "%s\tttys%3d\t%s %s\t%s\t%s" $1 ${nb_tty} ${month} ${day} ${time}
				echo -e "$1\tttys${nb_tty}\t${month} ${day}\t${time}\t$2" >> ~/proprescripts/rvsh/who_liste
				break
			elif [[ $j == 0 ]]; then
				echo rvsh est désactivé
				echo Réssavyez dans 5 minute
				sleep 300
				((j=10))
		fi

	done

	if [[ `grep -c -w ${1} ~/proprescripts/rvsh/users` == 0 ]]; then
		printf "${1} " >> ~/proprescripts/rvsh/users
	fi

	if [[ `grep -c -w ${2} ~/proprescripts/rvsh/rhost` == 0 ]]; then
		printf "${2} " >> ~/proprescripts/rvsh/rhost
	fi
}

# ================== Ce qui suit est le programme principal. ==================
#pour un utilisateur, il y a trois cas possibiles :
#1. rvsh avec l'option "-admin"
#2. rvsh avec l'option "-connect" et les corrects paramètres
#3. rvsh avec quoi d'autre qui ne peut pas permet de s'exécuter ! Dans ce cas là, on donnera un message qui s'affirme une erruer et echo la correcte syntaxe.


#1. rvsh avec l'option "-admin"

if [[ $# == 1 && $1 == "-admin" ]]; then
	clear
	echo === MODE ADMIN ===
	j=10

	while [[ 1 ]]; do
		read -p  "Saisissez le code S.V.P." -s motdepasse
		#echo "motdepasse=${motdepasse}"
		temp=`densifier ${motdepasse}`

		if [[ ${temp} != "de81459305398c88048a05a620fb4717" && $j != 0 ]]; then
			#echo ${temp}
			echo Désolé ! WRONG !
			((j--))
			echo "Vous avez encore ${j} fois de tentative"
		elif [[ ${temp} == "de81459305398c88048a05a620fb4717" && $j != 0 ]]; then
			break
		elif [[ $j == 0 ]]; then
			echo rvsh est désactivé
			echo Réssavyez dans 5 minute
			sleep 300
			((j=10))
		fi

	done

	utilisateur="root"
	machine=$2


	month=`date +%b` #(Jan..Dec)
	day=`date +%d` #(01..31)
	time=`date +%l:%M` #%l:(1..12) %M:(00..59)
	nb_tty=`cat ~/proprescripts/rvsh/who_liste | grep -w -c ${utilisateur}`
	((nb_tty++))
	#printf "%s\tttys%3d\t%s %s\t%s\t%s" $1 ${nb_tty} ${month} ${day} ${time}
	echo -e "${utilisateur}\tttys${nb_tty}\t${month} ${day}\t${time}\t${machine}" >> ~/proprescripts/rvsh/who_liste
	
	echo -e "\nBonjour ! \n"
	echo -e "\t-- Les commandes disponibles --"
	echo -e "who \t rusers \t rhost \t\t connect"
	echo -e "su \t passwd \t finger \t write"
	echo -e "host -a  host -d         users -a \t users -d\nafinger\n"
	souscommande=0

	while [[ souscommande!="Q" || souscommande!="q" ]]; do

		if [[ ${utilisateur} != "root" ]]; then
			echo -e "${utilisateur}@root - "
		fi

		read -p "rvsh > " souscommande											#l'option "-p" permet de présenter le "prompt" rvsh >
																				#sans modifier la variable PS1 prédéfinie du shell 
		case "${souscommande}" in
		"host -a" )																#Cette commande permet à l’administrateur d’ajouter une machine au réseau virtuel.
					#echo host -a mode
					read -p "Le nom de la machine : " nom_machine
					echo -e "${nom_machine}" >> ~/proprescripts/rvsh/machine_liste
					;;

		"host -d" )																#Cette commande permet à l’administrateur d’enlever une machine au réseau virtuel.
					echo "La liste de machines :"
					echo "======="
					cat ~/proprescripts/rvsh/machine_liste
					echo "======="
					read -p "Vous voulez supprimer : " nom_machine
					echo "======="
					sed -e '/^'"${nom_machine}"'$/d' ~/proprescripts/rvsh/machine_liste
					echo "======="
					read -p "Vous êtes sur Y/N ?" oui

					case "${oui}" in
						Y | y )
								sed -i -e '/^'"${nom_machine}"'$/d' ~/proprescripts/rvsh/machine_liste
								echo DONE !
								;;
						N | n )
								echo ANNULÉ !
								break
								;;
					esac
					;;

		"users -a" )
					read -p "Le nom de l'utilisateur : " nom_utilisateur
					#echo -e "${nom_utilisateur}:" >> ~/proprescripts/rvsh/passwd
					read -p "Définir un mot de passe : " mot
					#densifier ${mot}
					motencry=`densifier ${mot}`
					read -p "Définir un UID : " uid
					#cunzaifou ?
					read -p "Définir un GID : " gid
					echo "${nom_utilisateur}:${motencry}:${uid}:${gid}:gecos:shell" >> ~/proprescripts/rvsh/passwd
					#echo "${uid}:" >> ~/proprescripts/rvsh/droit
					read -p "Des machines accessibles : " nom_machine
					echo "${uid}:${nom_machine}" >> ~/proprescripts/rvsh/droit
					;;

		"users -d" )
					read -p "Vous voulez supprimer : " nom_utilisateur
					echo "======="
					sed -e '/^'"${nom_utilisateur}"'/d' ~/proprescripts/rvsh/passwd
					echo "======="
					uid_utilisateur=`get_uid ${nom_utilisateur}`
					#echo ${uid_utilisateur}
					sed -e '/^'"${uid_utilisateur}"'/d' ~/proprescripts/rvsh/droit
					echo "======="
					read -p "Vous êtes sur Y/N ?" oui

					case "${oui}" in
						Y | y )
								sed -i -e '/^'"${nom_utilisateur}"'/d' ~/proprescripts/rvsh/passwd
								sed -i -e '/^'"${uid_utilisateur}"'/d' ~/proprescripts/rvsh/droit
								echo DONE !;;
						N | n )
								echo ANNULÉ !
					esac
					;;

		"afinger" )
					read -p "Renseigner les informations complémentaires à QUI : " nom_utilisateur
					read -p "Saisissez des informations : " informations
					echo "======="
					sed -e '/^'"${nom_utilisateur}"'/s/\(.*\):\(.*\):\(.*\):\(.*\):.*:\(.*\)/\1:\2:\3:\4:'"${informations}"':\5/g' ~/proprescripts/rvsh/passwd | grep "${nom_utilisateur}"
					echo "======="
					read -p "Vous êtes sur Y/N ?" oui

					case "${oui}" in
						Y | y )
								sed -i -e '/^'"${nom_utilisateur}"'/s/\(.*\):\(.*\):\(.*\):\(.*\):.*:\(.*\)/\1:\2:\3:\4:'"${informations}"':\5/g' ~/proprescripts/rvsh/passwd
								echo DONE !
								;;
						N | n )
								echo ANNULÉ !
								;;
					esac
					;;

		"Q"|"q" )	echo "Au revoir !"											#Taper Q ou q pour sortir ce mode.
					exit 0
					;;

		*)			echo Bad commande !											#Affichier l'erreur et le usage.
					echo -e "\t-- Les commandes disponibles --"
					echo -e "who \t rusers \t rhost \t\t connect"
					echo -e "su \t passwd \t finger \t write"
					echo -e "host -a  host -d         users -a \t users -d\nafinger\n"
					;;
		esac
	done

#2. rvsh avec l'option "-connect" est les corrects paramètres

elif [[ $# == 3 && $1 == "-connect" ]]; then
	machine_verifier $2
	login $3 $2
	utilisateur=$3
	machine=$2
	bash ~/proprescripts/write.sh $2 $3 &
	pid_write=$!		# $! = le pid de "write.sh"
	clear
	
	echo === MODE CONNECT ===
	echo ${utilisateur_env}
	echo -e "Bienvenu ! Ce mode vous permet de vous connecter à une machine virtuelle. \n"
	echo -e "\t-- Les commandes disponibles --"
	echo -e "who \t rusers \t rhost \t\t connect"
	echo -e "su \t passwd \t finger \t write\n"
	souscommande=0

	while [[ souscommande!="Q" || souscommande!="q" ]]; do
		write_adresse="0"
		read -p "${utilisateur}@${machine} > " souscommande	write_adresse		#l'option "-p" permet de présenter le "prompt" nom_utilisateur@nom_machine >
																				#sans modifier la variable PS1 prédéfinie du shell 
		case "$souscommande" in
		"who" ) 	#echo mode who
					who_shell													#Cette commande permet d’accéder à l’ensemble des utilisateurs connectés sur la machine.
																				#Elle doit renvoyer le nom de chaque utilisateur, l’heure et la date de sa connexion.
																				#Attention, un même utilisateur peut se connecter plusieurs fois sur la même machine à partir de plusieurs terminaux.
					;;

		"rusers" )	#echo mode rusers
					nombre_utilisateur=`users_shell | wc -w`					#Cette commande permet d’accéder à la liste des utilisateurs connectés sur le réseau.
																				#Elle doit renvoyer le nom de chaque utilisateur et le nom de la machine où il est connecté,
																				#ainsi que l’heure et la date de sa connexion.
					for (( i = 1; i <= nombre_utilisateur; i++ )); do
						#statements
						utilis_current=`users_shell | cut -f$i -d' '`
						echo "---${utilis_current}---"
						who_shell | grep ${utilis_current} | tr '\t' ' ' | tr -s ' ' | cut -d ' ' -f2-5
					done
					;;

		"rhost" ) 	#echo mode rhost
					echo "Des machines rattachées :"
					cat ~/proprescripts/rvsh/rhost
					echo
																				#Cette commande doit renvoyer la liste des machines rattachées au réseau virtuel.
					;;

		"connect" )	#echo mode connect
					read -p "Sur quelle machine ? " nom_machine
					machine_verifier ${nom_machine}
					droit_verifier ${utilisateur} ${nom_machine}
					((resulta=$?))

					if [[ ${resulta} == 0 ]]; then
						echo "L'utilisateur ${utilisateur} na pas de droit !"
						echo "Vérifier de nouveau !"
					else
						machine=${nom_machine}
						machine_env=${nom_machine}
						month=`date +%b` #(Jan..Dec)
						day=`date +%d` #(01..31)
						time=`date +%l:%M` #%l:(1..12) %M:(00..59)
						nb_tty=`cat ~/proprescripts/rvsh/who_liste | grep -w -c ${utilisateur}`
						((nb_tty++))
						echo -e "${utilisateur}\tttys${nb_tty}\t${month} ${day}\t${time}\t${machine}" >> ~/proprescripts/rvsh/who_liste
						echo Changé !
						kill ${pid_write}
						bash ~/proprescripts/write.sh ${machine} ${utilisateur} &
						pid_write=$!		# $! = le pid de "write.sh"
						
					fi

					if [[ `grep -c -w ${machine} ~/proprescripts/rvsh/rhost` == 0 ]]; then
						printf "${machine} " >> ~/proprescripts/rvsh/rhost
					fi
																				#Cette commande permet à l’utilisateur de se connecter à une autre machine du réseau
																				#(il faut préalablement vérifier que l’utilisateur a le droit de se connecter sur cette machine).
					;;

		"su" ) 		#echo mode su

					while [[ 1 ]]; do
						read -p "À quel utilisateur voulez-vous passez ? " utilisateur_passer

						if [[ `grep -c -w ${utilisateur_passer} ~/proprescripts/rvsh/passwd` == 0 ]]; then
						echo "Utilisateur ${utilisateur_passer} n'existe pas !"
						echo "Vérifier de nouveau !"
						else
							break
						fi

					done

					login ${utilisateur_passer} ${machine}
					utilisateur=${utilisateur_passer}
					kill ${pid_write}
					bash ~/proprescripts/write.sh $2 ${utilisateur} &
					pid_write=$!		# $! = le pid de "write.sh"
					echo
					;;

		"passwd" )	#echo mode passwd
					read -p "Mot de passe actuel : " -s motdepasseactue			#Cette commande permet à l’utilisateur de changer de mot de passe sur l’ensemble du réseau virtuel
																				#(Cf. commande passwd de Linux)
																				# armandxu hai xu yao xiu gai ！
					echo
					mot=`densifier ${motdepasseactue}`
					mot_reference=`cat ~/proprescripts/rvsh/passwd | grep ${utilisateur} | cut -f2 -d ':'`

					if [[ ${mot} == ${mot_reference} ]]; then
						read -p "Nouveau mot de passe : " -s motdepassenouveau
						echo
						read -p "Retapez le nouveau mot de passe : " -s motdepassenouveau1
						echo

						if [[ ${motdepassenouveau} == ${motdepassenouveau1} ]]; then
							mot=`densifier ${motdepassenouveau1}`
							sed -i -e '/^'"${utilisateur}"'/s/\(.*\):.*:\(.*\):\(.*\):\(.*\):\(.*\)/\1:'"${mot}"':\2:\3:\4:\5/g' ~/proprescripts/rvsh/passwd
							echo DONE !
						else
							echo "Vous devez saisr le meme mot de passe deux fois pour le confirmer !"
						fi

					elif [[ ${mot} != ${mot_reference} ]]; then
						echo "Votre mot de passe est incorrect !"
					fi
					;;

		"finger" ) 	#echo mode finger
					cat ~/proprescripts/rvsh/passwd | grep "${utilisateur}" | cut -f5 -d':'
					;;

		"write" )	#echo mode write
					if [[ ${write_adresse} ]]; then
						read -p "Saisissez le message : " write_mes
						echo "${write_adresse} ${write_mes}" >> ~/proprescripts/rvsh/write
					fi
					;;
					
		"Q"|"q" )	echo "Au revoir !"											#Taper Q ou q pour sortir ce mode.
					cat /dev/null > ~/proprescripts/rvsh/who_liste
					cat /dev/null > ~/proprescripts/rvsh/rhost
					cat /dev/null > ~/proprescripts/rvsh/users
					#echo ${pid_write}
					kill ${pid_write}

					exit 0
					;;
					
		*)			echo Bad commande !											#Affichier l'erreur et le usage.
					echo -e "\t-- Les commandes disponibles --"
					echo -e "who \t rusers \t rhost \t\t connect"
					echo -e "su \t passwd \t finger \t write"
					;;
		esac
	done

#3. rvsh avec quoi d'autre qui ne peut pas permet de s'exécuter.

else
	echo "bad commande !"														#Affichier l'erreur et le usage.
	echo "Usage :"
	echo -e "\trvsh -connect nom_machine nom_utilisateur"
	echo -e "\trvsh -admin"
fi
