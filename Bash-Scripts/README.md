# 🗂️ Bash Scripts Files

This document offers an overview of the **backup.sh**, **restore.sh**, and **backup_restore_lib.sh** scripts. These scripts automate the backup and restore processes for files on a remote server while using GPG encryption to ensure file security.

## 📝 Prerequisites

- 🌐 A remote server (e.g., an AWS EC2 instance).
- ⚙️ Modify the variables in **backup_restore_lib.sh** to reflect your server details:
  ```bash
  # Variables for the remote server where backup and restore actions will be performed
  export server_username='ubuntu' 
  export server_ip='54.151.87.144'
  export server_key='/home/abu-nemr/task-bash.pem'
  ```

- 🔑 Generate a GPG key pair for file encryption and decryption:
  ```bash
  gpg --full-generate-key
  ```

---

## 📦 [backup.sh](https://github.com/amrabunemr98/Backup-and-Restore-Bash/blob/main/Bash-Scripts/backup.sh)

### 🔄 Invokes Two Functions from **backup_restore_lib.sh**

1. ### ✅ `validate_backup_params`
   - Checks that the correct number of parameters (4) are provided when executing **backup.sh**.
   - Verifies that the source directory (the directory to be backed up) exists.
   - Confirms that the backup directory exists on the remote server. If it does not, it will be created.
   - Validates the provided GPG key by checking the list of available GPG keys.
   - Ensures that the `days_threshold` value is a positive integer.

2. ### 💾 `backup`
   - Once the parameters are validated, the backup process proceeds.
   - The current date is captured for naming the backup file.
   - A new backup directory is created locally to hold the encrypted and compressed files from sub-directories in the source directory.
   - The script iterates over the sub-directories in the source directory, compressing and encrypting files that have been modified within the specified `days_threshold`. These files are moved to the backup directory.
   - If any files are found in the backup directory, they are grouped into a single compressed and encrypted file and copied to the remote server.
   - If no files meet the criteria, the script will output a message indicating no modified files within the specified time frame.

---

## 🔄 [restore.sh](https://github.com/amrabunemr98/Backup-and-Restore-Bash/blob/main/Bash-Scripts/restore.sh)

### 🔄 Invokes Two Functions from **backup_restore_lib.sh**

1. ### ✅ `validate_restore_params`
   - Checks that the correct number of parameters (3) are provided when running **restore.sh**.
   - Verifies the existence of the backup directory on the remote server.
   - Confirms that the restore directory exists or creates it if necessary to hold the restored files.
   - Ensures the provided GPG decryption key is valid by listing available GPG keys.

2. ### 📥 `restore`
   - After parameter validation, the restoration process begins.
   - A temporary directory is created within the restore directory to hold the restored files.
   - The backup files are fetched from the remote server's backup directory and placed in the temporary directory.
   - The backup files are then decrypted and extracted.
   - Each file is processed to decrypt and extract the content.

---

## 🔧 [backup_restore_lib.sh](https://github.com/amrabunemr98/Backup-and-Restore-Bash/blob/main/Bash-Scripts/backup_restore_lib.sh)

This script contains the shared functions used by both **backup.sh** and **restore.sh**:

- **`validate_backup_params`**: Ensures the backup parameters are valid.
- **`backup`**: Handles the backup process by compressing, encrypting, and uploading files to the remote server.
- **`validate_restore_params`**: Validates the restore parameters.
- **`restore`**: Manages the restore process by fetching, decrypting, and extracting files from the remote server.

---

## ⚠️ Important Notes:

- **GPG Encryption**: The scripts rely on GPG encryption for securing the backup files. Be sure to use the appropriate GPG key for both encryption and decryption.
- **Remote Server Access**: Ensure you have SSH access configured to the remote server, and the corresponding private key (`server_key`) is available.
- **Backup Directory**: The remote server must have an accessible backup directory where backup files can be stored. If it doesn't exist, it will be created by the script.
