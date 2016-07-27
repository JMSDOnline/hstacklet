#!/bin/bash
#
# [HStacklet HipHop VM LEMP Stack Prep Script]
#
# GitHub:   https://github.com/JMSDOnline/hstacklet
# Author:   Jason Matthews
# URL:      https://jmsolodesigns.com
#

PROGNAME="HStacklet"
PROGDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
VERSION="1.0"
FILES=()

#Script Console Colors
black=$(tput setaf 0);red=$(tput setaf 1);green=$(tput setaf 2);yellow=$(tput setaf 3);blue=$(tput setaf 4);magenta=$(tput setaf 5);cyan=$(tput setaf 6);white=$(tput setaf 7);on_red=$(tput setab 1);on_green=$(tput setab 2);on_yellow=$(tput setab 3);on_blue=$(tput setab 4);on_magenta=$(tput setab 5);on_cyan=$(tput setab 6);on_white=$(tput setab 7);bold=$(tput bold);dim=$(tput dim);underline=$(tput smul);reset_underline=$(tput rmul);standout=$(tput smso);reset_standout=$(tput rmso);normal=$(tput sgr0);alert=${white}${on_red};title=${standout};sub_title=${bold}${yellow};repo_title=${black}${on_green};


# Create vstacklet & backup directory strucutre
mkdir -p hstacklet /backup/{directories,databases}
cd hstacklet

# Download the needed scripts for VStacklet
curl -LO https://raw.githubusercontent.com/JMSDOnline/hstacklet/master/hstacklet-ubuntu-stack.sh >/dev/null 2>&1;
curl -LO https://raw.githubusercontent.com/JMSDOnline/hstacklet/master/files-backup.sh >/dev/null 2>&1;
curl -LO https://raw.githubusercontent.com/JMSDOnline/hstacklet/master/database-backup.sh >/dev/null 2>&1;
curl -LO https://raw.githubusercontent.com/JMSDOnline/hstacklet/master/package-backups.sh >/dev/null 2>&1;
curl -LO https://raw.githubusercontent.com/JMSDOnline/hstacklet/master/backup-cleanup.sh >/dev/null 2>&1;

# Convert all shell scripts to executable
chmod +x *.sh
cd

# Download VStacklet System Backup Executable
curl -LO https://raw.githubusercontent.com/JMSDOnline/hstacklet/master/hs-backup >/dev/null 2>&1;
chmod +x hs-backup
mv hs-backup /usr/local/bin

function _string() { perl -le 'print map {(a..z,A..Z,0..9)[rand 62] } 0..pop' 15 ; }

function _askhstacklet() {
  echo
  echo
  echo "${title} Welcome to the HStacklet LEMP stack install kit for HHVM! ${normal}"
  echo " version: ${VERSION}"
  echo
  echo "${bold} Enjoy the simplicity one script can provide to deliver ${normal}"
  echo "${bold} you the essentials of a finely tuned server environment.${normal}"
  echo "${bold} Nginx, HHVM, CSF, MariaDB w/ phpMyAdmin to name a few.${normal}"
  echo "${bold} Actively maintained and quality controlled.${normal}"
  echo
  echo
  echo -n "${bold}${yellow}Are you ready to install HStacklet for Ubuntu 15.x-16.04 ?${normal} (${bold}${green}Y${normal}/n): "
  read responce
  case $responce in
    [yY] | [yY][Ee][Ss] | "" ) hstacklet=yes ;;
    [nN] | [nN][Oo] ) hstacklet=no ;;
  esac
}

clear

function _hstacklet() {
  if [[ ${hstacklet} == "yes" ]]; then
    DIR="hstacklet"
    if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
      . "$DIR/hstacklet-ubuntu-stack.sh"
  fi
}

function _nohstacklet() {
  if [[ ${hstacklet} == "no" ]]; then
    echo "${cyan}Cancelling install. If you would like to run this installer in the future${normal}"
    echo "${cyan}type${normal} ${green}${bold}./hstacklet.sh${normal} - ${cyan}followed by tapping Enter on your keyboard.${normal}"
  fi
}

_askhstacklet;if [[ ${hstacklet} == "yes" ]]; then echo -n "${bold}Installing HStacklet Kit for 15.04 and 15.10 support${normal} ... ";_hstacklet; elif [[ ${hstacklet} == "no" ]]; then _nohstacklet;  fi
