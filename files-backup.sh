#!/bin/bash
#start
#-----------------------------------------------------------------------

green=$(tput setaf 2);
magenta=$(tput setaf 5);
normal=$(tput sgr0);
OK=$(echo -e "[ ${green}DONE${normal} ]")
OUTTO="/root/hs-backup.log"

# verify directory structure exists prior to running this job
# if you are using the standalone, modify this according to
# your current and/or future directory structures preferred paths
DIRBfiles="/srv/www /etc /root";

# Where to backup to.
DIRDest="/backup/directories/";

# Create archive filename.
DIRDay=$(date +%b-%d-%y);
DIRHostname=$(hostname -s);
DIRAfile="$DIRHostname-$DIRDay.tgz";

# Print start status message.
  echo -n "Backing up ${magenta}$DIRBfiles${normal} to ${magenta}$DIRDest$DIRAfile${normal} ... ";
  date >>"${OUTTO}" 2>&1;
  echo >>"${OUTTO}" 2>&1;

# Backup the files using tar.
  tar -cpzf $DIRDest$DIRAfile $DIRBfiles >>"${OUTTO}" 2>&1 &&
    echo -n "${OK}"
    echo

# This gets pushed to the vs-backup command
# Print end status message.
  echo >>"${OUTTO}" 2>&1;
  echo "Backup finished" >>"${OUTTO}" 2>&1;
  date >>"${OUTTO}" 2>&1;

# Long listing of files in $dest to check file sizes.
  ls -lh $DIRDest >>"${OUTTO}" 2>&1;
#-----------------------------------------------------------------------
#end

# Example Schedule
# Backup Website Files Daily @ 12:45 AM
# 45 00 * * * root /etc/cron.daily/backup-website-files