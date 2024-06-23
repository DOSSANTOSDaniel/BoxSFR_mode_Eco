#!/usr/bin/env bash

#--------------------------------------------------#
# Script_Name: auto_eco_box.fr
#
# Author:  'dossantosjdf@gmail.com'
#
# Date: dim. 23 juin 2024 15:27:23 CEST
# Version: 1.0
# Bash_Version: 5.2.15(1)-release
#--------------------------------------------------#
# Description:
# Ce script permet:
# - d'automatiser l'activation et la désactivation
#   du mode ECO sur une box SFR.
# - Création de messages de logs et notifications.
#
# Usage: avec cron
# 0 2 * * * /chemin/vers/le/script/auto_eco_box.sh
# 0 18 * * * /chemin/vers/le/script/auto_eco_box.sh
#

# Variables
# Logins
url_login="http://192.168.1.1/login"
url_eco="http://192.168.1.1/eco"

secrets_box="$HOME/.secrets/sfrbox"
secrets_ntfy="$HOME/.secrets/ntfy"

temp_token="$(awk -F: '/token/ {print $2}' "$secrets_ntfy")"
tortue_topic="$(awk -F: '/topic/ {print $2}' "$secrets_ntfy")"
user_sfrbox="$(awk -F: '/user/ {print $2}' "$secrets_box")"
pass_sfrbox="$(awk -F: '/pass/ {print $2}' "$secrets_box")"
data_login="login=${user_sfrbox}&password=${pass_sfrbox}"

# Heure courante et à quelle heure désactiver le mode ECO
current_hour="$(date +"%H")"
disable_hour='18'

cookie_file=$(mktemp)

# Fonction permettant de supprimer le fichier de cookies temporaire
cleanup() {
  rm -f "$cookie_file"
}

# Fonction permettant d'activer ou de désactiver le mode ECO
#Activer le mode ECO : "eco_enable=on&ecomode_activate="
#Désactiver le mode ECO : "eco_enable=off&ecomode_activate="
modify_ecomode() {
  eco_mode="$1"
  data_req_eco="eco_enable=${eco_mode}&ecomode_activate="

  # Connexion à la BOX
  curl -s -L -c "$cookie_file" -X POST -d "$data_login" "$url_login" --header 'Content-Type: application/x-www-form-urlencoded'

  # Vérifier si la connexion a réussi en accédant à la page principale
  login_status=$(curl -s -L -b "$cookie_file" "$url_login")
  if [[ $login_status != *"index"* ]]
  then
    logger -t "$0" 'SFR ECO --- Échec de la connexion à la BOX SFR (192.168.1.1)'
    error_sfrbox='Échec de la connexion à la BOX SFR (192.168.1.1)'
    exit 1
  fi

  # Modification du mode ECO
  curl -s -L -b "$cookie_file" -X POST -d "$data_req_eco" "$url_eco" --header 'Content-Type: application/x-www-form-urlencoded'
  response=$(curl -s -L -b "$cookie_file" "$url_eco" --header 'Content-Type: application/x-www-form-urlencoded')

  # Vérification de la réponse
  if echo "$response" | grep -q "enabled"
  then
    notify_sfrbox="Mode ECO : Activé"
    logger -t "$0" "Mode ECO : Activé"
  elif echo "$response" | grep -q "disabled"
  then
    notify_sfrbox="Mode ECO : Désactivé"
    logger -t "$0" "Mode ECO : Désactivé"
  else
    logger -t "$0" "Mode ECO : état inconnu !"
    error_sfrbox="Mode ECO : état inconnu !"
  fi
}

### Main
trap cleanup EXIT

if [ "$current_hour" -ge $disable_hour ]
then
  modify_ecomode off
else
  modify_ecomode on
fi

## Notifications avec NTFY
curl "https://noti.dsjdf.fr/$tortue_topic" \
  -H "Authorization: Bearer $temp_token" \
  -H "Title: Modification du mode ECO " \
  -H "Priority: default" \
  -H "Tags: herb" \
  -H "Icon: https://icons.iconarchive.com/icons/oxygen-icons.org/oxygen/128/Devices-network-wired-icon.png" \
  -d "
SFR BOX
==========================

$notify_sfrbox
==========================

# Erreurs
----------------
$error_sfrbox
==========================
"
daniel@tortue:~/Scripts$
