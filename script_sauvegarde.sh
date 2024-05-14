#!/bin/bash

# Définition des variables
SOURCE_DIR="/home/lucasmcn/dev/Sauvegarde-InfraSI/database"
DEST_USER="ubuntu" #remplacer par l'user de la VM de sauvegarde
DEST_HOST="192.168.37.128" #remplacer par l'IP de la VM de sauvegarde 
DEST_DIR="/home/ubuntu/Documents"
DATE=$(date +"%Y%m%d")
LOG_FILE="/home/lucasmcn/dev/Sauvegarde-InfraSI/log/sauvegarde.log"

# Fonction pour journaliser les messages
log_message() {
    local timestamp=$(date +"%Y-%m-%d %T")
    echo "[$timestamp] $1" >> "$LOG_FILE"
}

# Vérification de l'existence du répertoire source
if [ ! -d "$SOURCE_DIR" ]; then
    log_message "Erreur : Le répertoire source '$SOURCE_DIR' n'existe pas."
    exit 1
fi

# Vérification de la connexion SSH vers le serveur de destination
if ! ssh -q "$DEST_USER@$DEST_HOST" exit; then
    log_message "Erreur : Connexion SSH vers $DEST_HOST impossible."
    exit 1
fi

# Création du répertoire de sauvegarde sur le serveur distant
ssh "$DEST_USER@$DEST_HOST" "mkdir -p $DEST_DIR/$DATE"

# Sauvegarde des données
rsync -av --delete "$SOURCE_DIR/" "$DEST_USER@$DEST_HOST:$DEST_DIR/$DATE/"

# Vérification du succès de la sauvegarde
if [ $? -eq 0 ]; then
    log_message "Sauvegarde réussie : $SOURCE_DIR vers $DEST_USER@$DEST_HOST:$DEST_DIR/$DATE"
else
    log_message "Erreur lors de la sauvegarde de $SOURCE_DIR vers $DEST_USER@$DEST_HOST:$DEST_DIR/$DATE"
fi


