#!/bin/bash

# Backup script for databases
# Monetdb restore backup: xzcat file.sql.lz | mclient -d database

BACKUP_DIR="/old-c3sldb/backup_semanal"
BACKUP_FILE="$BACKUP_DIR/simcaq-dump-$(date +'%Y-%m-%d').sql.lz "
DUMP_COMMAND="msqldump"
FLAG="-d"
DATNAME="simcaq"
COMPRESSER="lzma"

# Run the backup if the file does not exist
if ! [ -e "$BACKUP_FILE" ]; then
  mkdir -p $BACKUP_DIR
  $DUMP_COMMAND $FLAG $DATNAME | $COMPRESSER > $BACKUP_FILE
fi

# Delete the oldest file if has more than 5 files
FILE_COUNT=$(find "$BACKUP_DIR" -maxdepth 1 -type f | wc -l)
if [ "$FILE_COUNT" -gt 5 ]; then
  rm $(find $BACKUP_DIR -maxdepth 1 -type f | sort | head -n 1)
fi
