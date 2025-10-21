#!/bin/env bash

BACKUP_DIR=$1

TIME=$(date '+[%Y-%m-%d %H:%M:%S]')
BACKUP_FILE="$BACKUP_DIR/zabbix_backup_$(date +\%Y-%m-%d).dump"
LOGFILE=~/pgBackup.log

[[ -d "$BACKUP_DIR" ]] || { mkdir -pv $BACKUP_DIR | sed "s/^/$TIME /" |  tee -a $LOGFILE; }

PGPASSWORD="zabbix_password" pg_dump -h localhost -U zabbix -d zabbix -Fc -f "$BACKUP_FILE" | sed "s/^/$TIME /" | tee -a $LOGFILE

find "$BACKUP_DIR" -type f -name "zabbix_backup_*.dump" -mtime +7 -delete
