#!/bin/bash

# Définition des variables
REPERTOIRE_SAUVEGARDE="home/lucasmcn/Documents"
DEST_USER="lucasmcn"
DEST_HOST="192.168.37.130"
DEST_DIR="/home/lucasmcn/dev/Sauvegarde-Infra-SI/database"
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

# Récupérer la liste des répertoires de sauvegarde disponibles sur le serveur distant
fichiers_sauvegarde=$(ssh "$DEST_USER@$DEST_HOST" "ls -d $REPERTOIRE_SAUVEGARDE_SUR_SERVEUR/*/")

# Afficher les répertoires de sauvegarde disponibles
echo "Répertoires de sauvegarde disponibles :"
echo "$fichiers_sauvegarde"
echo

# Afficher une interface utilisateur pour sélectionner le fichier à restaurer
PS3="Choisissez le fichier à restaurer : "
select fichier in "$REPERTOIRE_SAUVEGARDE"/*; do
    if [ ! -z "$fichier" ]; then
        echo "Vous avez sélectionné $fichier pour la restauration."
        # Ajoutez ici la logique de restauration du fichier sélectionné
        # Par exemple, vous pouvez copier le fichier vers un répertoire de restauration sur le serveur distant
        scp "$fichier" "$DEST_USER@$DEST_HOST:$DEST_DIR/"
        if [ $? -eq 0 ]; then
            log_message "Restauration réussie : $fichier vers $DEST_USER@$DEST_HOST:$DEST_DIR/"
        else
            log_message "Erreur lors de la restauration de $fichier vers $DEST_USER@$DEST_HOST:$DEST_DIR/"
        fi
        break
    else
        echo "Option invalide, veuillez choisir un numéro de fichier valide."
    fi
done
