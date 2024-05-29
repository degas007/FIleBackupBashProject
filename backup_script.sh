#!/bin/bash

# Log file
LOG_FILE="backup_log.txt"

# Function to log messages
log_message() {
    echo "$(date +"%Y-%m-%d %H:%M:%S") - $1" >> "$LOG_FILE"
}

# Function to cleanup old backups
cleanup_old_backups() {
    local backup_dir="$1"
    local max_backups="$2"
    local backups

    backups=$(ls -dt "$backup_dir"/backup_* | tail -n +$(($max_backups + 1)))
    for backup in $backups; {
        rm -rf "$backup"
        log_message "Old backup removed: $backup"
    }
}

# User input
read -rp "Enter the source directory: " source_dir
read -rp "Enter the backup directory: " backup_dir
read -rp "Do you want to compress the backup? (yes/no): " compress
compress=${compress,,} # Convert to lowercase

# Check if source directory exists
if [[ ! -d "$source_dir" ]]; then
    echo "Error: Source directory does not exist."
    log_message "Error: Source directory does not exist: $source_dir"
    exit 1
fi

# Create new backup directory with timestamp
timestamp=$(date +"%Y%m%d_%H%M%S")
new_backup_dir="$backup_dir/backup_$timestamp"
mkdir -p "$new_backup_dir"

# Copy contents from source to backup directory
cp -r "$source_dir/"* "$new_backup_dir/"
log_message "Backup created: $new_backup_dir"

# Compress the backup if requested
if [[ "$compress" == "yes" ]]; then
    zip_filename="$new_backup_dir.zip"
    zip -r "$zip_filename" "$new_backup_dir"
    rm -rf "$new_backup_dir"
    log_message "Backup compressed: $zip_filename"
fi

# Cleanup old backups, keeping only the most recent 5 backups
cleanup_old_backups "$backup_dir" 5

echo "Backup completed successfully."

# End of script

