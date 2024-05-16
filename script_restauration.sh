#!/bin/bash

# Définition des variables
SOURCE_DIR="/home/lucasmcn/dev/Sauvegarde-Infra-SI/database"
DEST_USER="lucasmcn" # remplacer par l'utilisateur de la VM de sauvegarde
DEST_HOST="192.168.37.130" # remplacer par l'IP de la VM de sauvegarde
DEST_DIR="/home/lucasmcn/Documents/backup"
LOG_FILE="/home/lucasmcn/dev/Sauvegarde-Infra-SI/log/restauration.log"

# Fonction pour journaliser les messages
log_message() {
    local timestamp=$(date +"%Y-%m-%d %T")
    echo "[$timestamp] $1" >> "$LOG_FILE"
}

# Vérification de la connexion SSH vers le serveur de destination
if ! ssh -q "$DEST_USER@$DEST_HOST" exit; then
    log_message "Erreur : Connexion SSH vers $DEST_HOST impossible."
    exit 1
fi

# Récupération de la liste des sauvegardes disponibles
BACKUP_LIST=$(ssh "$DEST_USER@$DEST_HOST" "ls -1 $DEST_DIR")
if [ $? -ne 0 ]; then
    log_message "Erreur : Impossible de récupérer la liste des sauvegardes disponibles sur $DEST_HOST."
    exit 1
fi

# Conversion de la liste des sauvegardes en tableau
BACKUP_ARRAY=($BACKUP_LIST)

# Interface de sélection de la sauvegarde
PS3="Choisissez le fichier à restaurer : "
select BACKUP in "${BACKUP_ARRAY[@]}"; do
    if [ -n "$BACKUP" ]; then
        echo "Vous avez sélectionné $BACKUP pour la restauration."
        break
    else
        echo "Sélection invalide. Veuillez choisir un numéro valide."
    fi
done

# Demande de confirmation
read -p "Voulez-vous vraiment restaurer la sauvegarde $BACKUP ? (oui/non) : " CONFIRMATION
if [[ "$CONFIRMATION" != "oui" ]]; then
    log_message "Restauration annulée par l'utilisateur."
    exit 1
fi

# Création du répertoire source si nécessaire
if [ ! -d "$SOURCE_DIR" ]; then
    mkdir -p "$SOURCE_DIR"
fi

# Restauration des données
rsync -av --delete "$DEST_USER@$DEST_HOST:$DEST_DIR/$BACKUP/" "$SOURCE_DIR/"

# Vérification du succès de la restauration
if [ $? -eq 0 ]; then
    log_message "Restauration réussie : $DEST_USER@$DEST_HOST:$DEST_DIR/$BACKUP vers $SOURCE_DIR"
    echo "Restauration réussie."
else
    log_message "Erreur lors de la restauration de $DEST_USER@$DEST_HOST:$DEST_DIR/$BACKUP vers $SOURCE_DIR"
    echo "Erreur lors de la restauration."
fi
