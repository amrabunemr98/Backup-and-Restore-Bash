#!/bin/bash

# Variables for the remote server that will perform backup and restore on/from it. In this case, it is an EC2 instance on AWS
export server_username='ubuntu' 
export server_ip='54.151.87.144'
export server_key='/home/abu-nemr/task-bash.pem'

# Function to validate the 4 parameter of backup.sh script
validate_backup_params() {
    if [ $# -ne 4 ]; then
        echo "Usage: $0 source_directory backup_directory encryption_key days_threshold"
        echo "1- source_directory: The path of the directory to be backed up."
        echo "2- backup_directory: The destination directory on the remote server where the backup will be stored."
        echo "3- encryption_key: The key used to encrypt the backup directory."
        echo "4- days_threshold: The number of days (n) to consider when backing up files modified within the last n days."
        exit 1    
    fi

    # Store the 4 parameters in variables
    source_directory="$1"    
    backup_directory="$2"
    encryption_key="$3"
    days_threshold="$4"

    # Check if source directory exist
    if [ ! -d "$source_directory" ]; then
        echo "Error: $source_directory does not exist, Please make to enter the correct directory."
        exit 1
    fi

    # Check if backup directory exists on the remote server. if not, create it
    ssh_check_result=$(ssh -i $server_key $server_username@$server_ip "[ -d '$backup_directory' ] && echo 'exists' || echo 'notexists'")

    if [ "$ssh_check_result" = "notexists" ]; then
        echo "$backup_directory does not exist on the remote server. Creating it..."

        # Create backup directory in the remote server to store the backup files
        ssh -i $server_key $server_username@$server_ip "sudo mkdir -p '$backup_directory' && sudo chown ubuntu:ubuntu '$backup_directory' && sudo chmod 775 '$backup_directory'"
        echo "$backup_directory is successfully created on the remote server."
    fi

    # Check if encryption key is valid
    if ! gpg --list-keys | grep -q "$encryption_key"; then
        echo "Error: GPG key '$encryption_key' not found. Please make sure to enter the correct key"
        exit 1
    fi

    # Check if days_threshold is a valid positive integer
    if ! [[ "$days_threshold" =~ ^[1-9][0-9]*$ ]]; then
        echo "Error: Invalid number of days."
        exit 1
    fi   
}

# function to perform backup
backup() {
    # Capture the current date
    snapshot_date=$(date +"%d_%m_%Y")        # %d:day, %m:month, %Y:year , example: snapshot_date: 24_8_2023

    # Create a directory to store all modified files within the source directory to be backed up
    backup_dir="${snapshot_date}"
    mkdir -p $backup_dir

    # Find modified files in the source directory within the last 'days_threshold' days
    modified_files=$(find "$source_directory" -type f -mtime -$days_threshold)

    # If there are modified files, proceed with the backup
    if [ -n "$modified_files" ]; then
        echo "Found modified files. Starting backup..."

        # Loop over the modified files and back them up
        for file in $modified_files; do
            subdir=$(dirname "$file")
            dir_name=$(basename "$subdir")
            file_name=$(basename "$file")

            # Create a .tgz archive for each modified file and encrypt it
            tar -czf "${backup_dir}/${dir_name}_${file_name}_${snapshot_date}.tgz" -C "$subdir" "$file_name"
            gpg --encrypt --recipient "$encryption_key" "${backup_dir}/${dir_name}_${file_name}_${snapshot_date}.tgz"
            rm "${backup_dir}/${dir_name}_${file_name}_${snapshot_date}.tgz"  # Remove the unencrypted .tgz file
        done

        # Create the combined tar of encrypted files
        combined_tar="${backup_dir}/all_files_${snapshot_date}.tar"
        first_encrypted=0
        for encrypted_file in "${backup_dir}"/*.tgz.gpg; do
            file_name=$(basename "${encrypted_file%.tgz.gpg}")
            if [ $first_encrypted -eq 0 ]; then
                tar -cf "$combined_tar" -C "$backup_dir" "$file_name.tgz.gpg"
                first_encrypted=1
            else
                tar -rf "$combined_tar" -C "$backup_dir" "$file_name.tgz.gpg"
            fi
        done

        # Compress and encrypt the combined tar file
        gzip "$combined_tar"
        gpg --encrypt --recipient "$encryption_key" "${combined_tar}.gz"
        rm "${combined_tar}.gz"

        # Clean up the individual encrypted files
        rm "${backup_dir}"/*.tgz.gpg

        # Copy the backup directory to the remote server
        scp -i $server_key -r ${backup_dir} $server_username@$server_ip:"$backup_directory"

        # Clean up - remove the backup_dir locally after copying it to the remote server
        rm -r "${backup_dir}"

    else
        echo "There are no modified files in $source_directory within the last $days_threshold day(s) to be backed up."
        rmdir $backup_dir
    fi
}


# Function to validate the 3 parameters of restore.sh script
validate_restore_params () {
    # Check if the script received the correct number of parameters
    if [ $# -ne 3 ]; then
        echo "Usage: $0 backup_directory restored_directory decryption_key"
        echo " 1- backup_directory: Path of the directory on the remote server that contains the backup files to restore."
        echo " 2- restored_directory: Path of the directory that the backup should be restored to."
        echo " 3- decryption_key: Key that will be used to decrypt the backup files."
        exit 1
    fi

    # Store the 3 parameters in variables
    backup_directory="$1"
    restored_directory="$2"
    decryption_key="$3"

    # Check if backup directory exists on the remote server
    ssh_check_result=$(ssh -i $server_key $server_username@$server_ip "[ -d '$backup_directory' ] && echo 'exists' || echo 'notexists'")
    if [ "$ssh_check_result" = "notexists" ]; then
        echo "Error: Backup directory does not exist on the remote server. Please make sure to enter the correct directory."
        exit 1
    fi

    # Check if restored directory exists, if not, create it
    if [ ! -d "$restored_directory" ]; then
        echo "Restored directory does not exist. Creating it..."
        mkdir -p $restored_directory
        echo "$restored_directory successfully created."
    fi

    # Check if decryption key is valid
    if ! gpg --list-keys "$decryption_key" > /dev/null 2>&1; then
        echo "Error: GPG key '$decryption_key' not found. Please make sure to enter the correct key."
        exit 1
    fi
}

# Function to restore backup files
restore () {
    # Create a temporary directory within the restored directory
    mkdir -p "$restored_directory/temp_restore"

    # Restore the files inside the backup_directory on the remote server to the temp_restore directory
    scp -i $server_key -r $server_username@$server_ip:"$backup_directory"/* "$restored_directory/temp_restore"

    # Check if files were successfully transferred
    if [ -z "$(ls -A "$restored_directory/temp_restore")" ]; then
        echo "Error: No files were transferred from the remote backup directory."
        exit 1
    fi

    # Check and decrypt the encrypted backup files inside temp_restore
    encrypted_files=("$restored_directory/temp_restore"/*.tar.gz.gpg)
    if [ ${#encrypted_files[@]} -gt 0 ]; then
        for encrypted_file in "${encrypted_files[@]}"; do
            decrypted_file="${encrypted_file%.gpg}"
            if ! gpg --output "$decrypted_file" --decrypt --recipient "$decryption_key" "$encrypted_file"; then
                echo "Error: Decryption of file $encrypted_file failed."
                exit 1
            fi

            # Extract the decrypted tar file
            tar -xzf "$decrypted_file" -C "$restored_directory/temp_restore"

            # Remove the decrypted tar file and the encrypted file
            rm "$decrypted_file" "$encrypted_file"
        done
    fi

    # Loop over the extracted files and handle .tgz files
    for content in "$restored_directory/temp_restore"/*; do
        if [ -f "$content" ]; then
            decrypted_file="${content%.gpg}"
            if ! gpg --output "$decrypted_file" --decrypt --recipient "$decryption_key" "$content"; then
                echo "Error: Decryption of file $content failed."
                exit 1
            fi

            # Check if the decrypted file is a tar.gz file
            if [[ "$decrypted_file" == *.tgz ]]; then
                extraction_dir="${decrypted_file%.tgz}"
                mkdir -p "$extraction_dir"

                tar -xzf "$decrypted_file" -C "$extraction_dir"
                rm "$decrypted_file" "$content"
            fi
        fi
    done


}

