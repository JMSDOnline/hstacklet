#!/bin/bash
#
# [HStacklet HipHop VM LEMP Stack Prep Script]
#
# GitHub:   https://github.com/JMSDOnline/hstacklet
# Author:   Jason Matthews
# URL:      https://jmsolodesigns.com
#

#Script Console Colors
black=$(tput setaf 0);
red=$(tput setaf 1);
green=$(tput setaf 2);
on_green=$(tput setab 2);
bold=$(tput bold);
standout=$(tput smso);
normal=$(tput sgr0);
underline=$(tput smul);

sub_title=${bold}${yellow};
repo_title=${black}${on_green};

PROGNAME=${0##*/}
VERSION="0.1"

cat <<EOF
  $PROGNAME ver. $VERSION
  This is a standalone backup utility for vstacklet.
  You do not need VStacklet (full) to use this utility.

  The primary use of this script is for running 
  manual backups on user specified directories 
  and databases. 

  This script will also package your directories
  and databases into one archive and perform a 
  backup cleanup.

  Please review the following scripts and make the 
  necessary changes to ensure successful backups.

  ${underline}Directory Backup:${normal}
  /root/hstacklet/files-backup.sh

  ${underline}Database Backup:${normal}
  /root/hstacklet/database-backup.sh
EOF

# Create hstacklet & backup directory strucutre
mkdir -p hstacklet /backup/{directories,databases}
cd hstacklet

# Download the needed scripts for VStacklet
curl -LO https://raw.githubusercontent.com/JMSDOnline/hstacklet/master/files-backup.sh >/dev/null 2>&1;
curl -LO https://raw.githubusercontent.com/JMSDOnline/hstacklet/master/database-backup.sh >/dev/null 2>&1;
curl -LO https://raw.githubusercontent.com/JMSDOnline/hstacklet/master/package-backups.sh >/dev/null 2>&1;
curl -LO https://raw.githubusercontent.com/JMSDOnline/hstacklet/master/backup-cleanup.sh >/dev/null 2>&1;

# Convert all shell scripts to executable
chmod +x *.sh
cd

# Download HStacklet System Backup Executable
curl -LO https://raw.githubusercontent.com/JMSDOnline/hstacklet/master/hs-backup >/dev/null 2>&1;
chmod +x hs-backup
mv hs-backup /usr/local/bin

###############################################################################
echo
echo
echo "HS-Backup is now installed. Please make the needed changes in";
echo "the required files.";
echo
echo "Once changes are perform, you can run the script by simply typing:";
echo "${bold}${green}hs-backup${normal}";
echo
echo
###############################################################################