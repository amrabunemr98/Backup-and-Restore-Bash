# Secure Backup and Restore Scripts

## Overview

This document explains the usage of the `backup.sh` and `restore.sh` scripts, designed to securely back up and restore directories using encryption. These scripts can be scheduled with cron for periodic backups and use SCP for remote transfers.

## Prerequisites

- Linux environment
- Bash shell
- GnuPG (`gpg`) for encryption and decryption
- SSH access to a remote server
- Cron for scheduling tasks

## Files Included

- `backup.sh`: Script for performing secure backups.
- `restore.sh`: Script for restoring backups.
- `backup_restore_lib.sh`: Library containing common functions used by both scripts.

## Usage

### [backup.sh](https://github.com/amrabunemr98/Backup-and-Restore-Bash/blob/main/Bash-Scripts/backup.sh)

#### Command-line Arguments

```bash
./backup.sh <source_directory> <backup_directory> <encryption_key> <days_threshold>
```

- **source\_directory**: The directory to be backed up.
- **backup\_directory**: The directory on the remote server where the backup will be stored.
- **encryption\_key**: The key used for encrypting the backup.
- **days\_threshold**: Number of days to consider files as modified and include them in the backup.

#### Example

```bash
./backup.sh /home/user/documents /remote/backup/path my-encryption-key 7
```

### [restore.sh](https://github.com/amrabunemr98/Backup-and-Restore-Bash/blob/main/Bash-Scripts/restore.sh)

#### Command-line Arguments

```bash
./restore.sh <backup_directory> <restore_directory> <decryption_key>
```

- **backup\_directory**: The directory containing the backup.
- **restore\_directory**: The directory where the backup will be restored.
- **decryption\_key**: The key for decrypting the backup.

#### Example

```bash
./restore.sh /remote/backup/path /home/user/restore my-decryption-key
```

## Scheduling the Backup Script

To schedule the `backup.sh` script to run daily, use the following cron configuration:

```bash
crontab -e
```

Add the line:

```bash
0 2 * * * /path/to/backup.sh /home/user/documents /remote/backup/path my-encryption-key 7
```

This schedules the script to run at 2:00 AM every day.

## Library Functions

### [backup_restore_lib.sh](https://github.com/amrabunemr98/Backup-and-Restore-Bash/blob/main/Bash-Scripts/backup_restore_lib.sh)

- **validate\_backup\_params**: Validates input parameters for `backup.sh`.
- **backup**: Handles the backup process, including compression and encryption.
- **validate\_restore\_params**: Validates input parameters for `restore.sh`.
- **restore**: Handles the restoration process, including decryption and extraction.

## Results

Below are screenshots demonstrating the successful execution of the [backup.sh](https://github.com/amrabunemr98/Backup-and-Restore-Bash/blob/main/Bash-Scripts/backup.sh) script:
![Screenshot from 2024-11-18 01-39-43](https://github.com/user-attachments/assets/286f2a75-3b73-433b-a063-e5ba78547cfe)
![Screenshot from 2024-11-18 01-40-09](https://github.com/user-attachments/assets/88b788b0-8444-4343-a104-e8ed19c1e665)

Below are screenshots demonstrating the successful execution of the [restore.sh](https://github.com/amrabunemr98/Backup-and-Restore-Bash/blob/main/Bash-Scripts/restore.sh) script:
![Screenshot from 2024-11-18 01-43-10](https://github.com/user-attachments/assets/113f99fe-9f30-4976-a267-06d3904b59fc)
![Screenshot from 2024-11-18 01-43-32](https://github.com/user-attachments/assets/aa19be93-e83e-4e3b-9800-88c1bae0ea75)

## Assumptions

- The encryption key is already available in the GPG keyring.
- SSH access to the remote server is set up and configured.
- The remote server has sufficient permissions to create and store backup files.

## Security Considerations

- The encryption key should be kept secure and not hardcoded.
- Use a secure method to transfer the encryption key for decryption.
- Ensure only authorized users have access to run the scripts.

## Notes

- The scripts include error handling to validate input and ensure directories exist.
- Temporary files created during the process are deleted after use.



