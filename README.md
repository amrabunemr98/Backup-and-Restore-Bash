<div align="center">
  <h1 style="color: red;"> Secure Backup and Restore Scripts 🔒</h1>
</div>

This repository contains scripts to securely back up and restore directories using encryption. The scripts utilize GnuPG for encryption, SCP for remote transfer, and can be scheduled using cron for periodic backups.

## Table of Contents 📚

1. [Overview](overview)
2. [Prerequisites](#prerequisites)
3. [Files Included](#files-included)
4. [Usage](#usage)
   - [Backup Script](#backup-script)
   - [Restore Script](#restore-script)
5. [Scheduling the Backup Script](#scheduling-the-backup-script)
6. [Library Functions](#library-functions)
7. [Results](#results)
8. [Assumptions](#assumptions)
9. [Security Considerations](#security-considerations)
10. [Notes](#notes)

## Overview 📄

The `backup.sh` and `restore.sh` scripts are designed to securely back up and restore directories, utilizing GPG encryption for backup security. SCP is used for remote transfer of the backup. These scripts can be scheduled with cron for regular backups.

## Prerequisites ⚙️

- Linux environment
- Bash shell
- GnuPG (`gpg`) for encryption and decryption
- SSH access to a remote server
- Cron for scheduling tasks

## Files Included 🗂️

- `backup.sh`: Script for performing secure backups.
- `restore.sh`: Script for restoring backups.
- `backup_restore_lib.sh`: Library containing common functions used by both scripts.

## Usage 📝

### [Backup Script](https://github.com/amrabunemr98/Backup-and-Restore-Bash/blob/main/Bash-Scripts/backup.sh) ⚒️

#### Command-line Arguments

```bash
./backup.sh <source_directory> <backup_directory> <encryption_key> <days_threshold>
```

- **source_directory**: Directory to back up.
- **backup_directory**: Directory on the remote server where the backup will be stored.
- **encryption_key**: Key used for encrypting the backup.
- **days_threshold**: Number of days to consider files as modified for inclusion in the backup.

#### Example

```bash
./backup.sh /home/user/documents /remote/backup/path my-encryption-key 7
```

### [Restore Script](https://github.com/amrabunemr98/Backup-and-Restore-Bash/blob/main/Bash-Scripts/restore.sh) 🔄

#### Command-line Arguments

```bash
./restore.sh <backup_directory> <restore_directory> <decryption_key>
```

- **backup_directory**: Directory containing the backup.
- **restore_directory**: Directory where the backup will be restored.
- **decryption_key**: Key for decrypting the backup.

#### Example

```bash
./restore.sh /remote/backup/path /home/user/restore my-decryption-key
```

## Scheduling the Backup Script 🗓️

To schedule the `backup.sh` script to run daily, use the following cron configuration:

```bash
crontab -e
```

Add the line:

```bash
0 2 * * * /path/to/backup.sh /home/user/documents /remote/backup/path my-encryption-key 7
```

This schedules the script to run at 2:00 AM every day.

## [Library Functions](https://github.com/amrabunemr98/Backup-and-Restore-Bash/blob/main/Bash-Scripts/backup_restore_lib.sh) 🛠️

- **validate_backup_params**: Validates input parameters for `backup.sh`.
- **backup**: Handles the backup process, including compression and encryption.
- **validate_restore_params**: Validates input parameters for `restore.sh`.
- **restore**: Handles the restoration process, including decryption and extraction.

## Results 📸

Below are screenshots demonstrating the successful execution of the [backup.sh](https://github.com/amrabunemr98/Backup-and-Restore-Bash/blob/main/Bash-Scripts/backup.sh) script:

![Screenshot from 2024-11-18 01-39-43](https://github.com/user-attachments/assets/286f2a75-3b73-433b-a063-e5ba78547cfe)

![Screenshot from 2024-11-18 01-40-09](https://github.com/user-attachments/assets/88b788b0-8444-4343-a104-e8ed19c1e665)

Below are screenshots demonstrating the successful execution of the [restore.sh](https://github.com/amrabunemr98/Backup-and-Restore-Bash/blob/main/Bash-Scripts/restore.sh) script:

![Screenshot from 2024-11-18 01-43-10](https://github.com/user-attachments/assets/113f99fe-9f30-4976-a267-06d3904b59fc)

![Screenshot from 2024-11-18 01-43-32](https://github.com/user-attachments/assets/aa19be93-e83e-4e3b-9800-88c1bae0ea75)

## Assumptions 📜

- The encryption key is available in the GPG keyring.
- SSH access to the remote server is set up and configured.
- The remote server has sufficient permissions to store backup files.

## Security Considerations 🔐

- Ensure the encryption key is kept secure and not hardcoded.
- Use secure methods for transferring the encryption key for decryption.
- Ensure only authorized users can run the scripts.

## Notes 📝

- The scripts handle errors by validating input and ensuring directories exist.
- Temporary files created during the process are deleted after use.
