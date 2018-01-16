#!/bin/bash

# clean file system and database
$DMAC_CLEANER

# dump database
/usr/bin/pg_dump $PG_URL > $DMAC_ROOT/backup/db.dump

# backup users
awk -v LIMIT=$UGIDLIMIT -F: '($3>LIMIT) && ($3!=65534)' /etc/passwd > $DMAC_ROOT/backup/users/passwd.mig
awk -v LIMIT=$UGIDLIMIT -F: '($3>LIMIT) && ($3!=65534)' /etc/group > $DMAC_ROOT/backup/users/group.mig
awk -v LIMIT=$UGIDLIMIT -F: '($3>LIMIT) && ($3!=65534) {print $1}' /etc/passwd | tee - |egrep -f - /etc/shadow > $DMAC_ROOT/backup/users/shadow.mig
cat /etc/gshadow > $DMAC_ROOT/backup/users/gshadow.mig

# transfer to attic
$GLOBUS_BIN transfer -r -s checksum --delete $GLOBUS_DMAC:~/dmac-root $GLOBUS_ATTIC:~/dmac-root
