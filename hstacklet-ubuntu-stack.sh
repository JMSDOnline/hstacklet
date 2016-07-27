#!/bin/bash
#
# [HStacklet HipHopVM LEMP Stack Installation Script]
#
# GitHub:   https://github.com/JMSDOnline/hstacklet
# Author:   Jason Matthews
# URL:      https://jmsolodesigns.com
#
# find server IP and server hostname for nginx configuration
server_ip=$(ifconfig | sed -n 's/.*inet addr:\([0-9.]\+\)\s.*/\1/p' | grep -v 127 | head -n 1);
hostname1=$(hostname -s);

#Script Console Colors
black=$(tput setaf 0);red=$(tput setaf 1);green=$(tput setaf 2);yellow=$(tput setaf 3);blue=$(tput setaf 4);magenta=$(tput setaf 5);cyan=$(tput setaf 6);white=$(tput setaf 7);on_red=$(tput setab 1);on_green=$(tput setab 2);on_yellow=$(tput setab 3);on_blue=$(tput setab 4);on_magenta=$(tput setab 5);on_cyan=$(tput setab 6);on_white=$(tput setab 7);bold=$(tput bold);dim=$(tput dim);underline=$(tput smul);reset_underline=$(tput rmul);standout=$(tput smso);reset_standout=$(tput rmso);normal=$(tput sgr0);alert=${white}${on_red};title=${standout};sub_title=${bold}${yellow};repo_title=${black}${on_green};

# Color Prompt
sed -i.bak -e 's/^#force_color/force_color/' \
 -e 's/1;34m/1;35m/g' \
 -e "\$aLS_COLORS=\$LS_COLORS:'di=0;35:' ; export LS_COLORS" /etc/skel/.bashrc


function _string() { perl -le 'print map {(a..z,A..Z,0..9)[rand 62] } 0..pop' 15 ; }

# intro function (1)
function _intro() {
  echo
  echo
  echo "  [${repo_title}hstacklet${normal}] ${title} HHVM LEMP Stack Installation ${normal}  "
  echo "  ${alert} Configured and tested for Ubuntu 15.04 - 16.04 ${normal}  "
  echo
  echo

  echo "${green}Checking distribution ...${normal}"
  if [ ! -x  /usr/bin/lsb_release ]; then
    echo 'You do not appear to be running Ubuntu.'
    echo 'Exiting...'
    exit 1
  fi
  echo "$(lsb_release -a)"
  echo
  dis="$(lsb_release -is)"
  rel="$(lsb_release -rs)"
  if [[ "${dis}" != "Ubuntu" ]]; then
    echo "${dis}: You do not appear to be running Ubuntu"
    echo 'Exiting...'
    exit 1
  elif [[ ! "${rel}" =~ ("15.04"|"15.10"|"16.04") ]]; then
    echo "${bold}${rel}:${normal} You do not appear to be running a supported Ubuntu release."
    echo 'Exiting...'
    exit 1
  fi
}

# check if root function (2)
function _checkroot() {
  if [[ $EUID != 0 ]]; then
    echo 'This script must be run with root privileges.'
    echo 'Exiting...'
    exit 1
  fi
  echo "${green}Congrats! You're running as root. Let's continue${normal} ... "
  echo
}

# check if create log function (3)
function _logcheck() {
  echo -ne "${bold}${yellow}Do you wish to write to a log file?${normal} (Default: ${green}${bold}Y${normal}) "; read input
    case $input in
      [yY] | [yY][Ee][Ss] | "" ) OUTTO="hstacklet.log";echo "${bold}Output is being sent to /root/hstacklet.log${normal}" ;;
      [nN] | [nN][Oo] ) OUTTO="/dev/null 2>&1";echo "${cyan}NO output will be logged${normal}" ;;
    *) OUTTO="hstacklet.log";echo "${bold}Output is being sent to /root/hstacklet.log${normal}" ;;
    esac
  echo
  echo "Press ${standout}${green}ENTER${normal} when you're ready to begin" ;read input
  echo
}

# system packages and repos function (4)
# Update packages and add MariaDB, Varnish 4, and Nginx 1.9.9 (mainline) repositories
function _softcommon() {
  # package and repo addition (a) _install common properties_
  apt-get -y install software-properties-common python-software-properties >>"${OUTTO}" 2>&1;
  echo "${OK}"
  echo
}

# package and repo addition (b) _install softwares and packages_
function _depends() {
  apt-get -y install nano unzip dos2unix htop iotop bc libwww-perl >>"${OUTTO}" 2>&1;
  echo "${OK}"
  echo
}

# package and repo addition (c) _add signed keys_
function _keys() {
  # this key is one way to add hhvm but it's block adds more mess, i.e; apache, mysql ... etc.
  apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0x5a16e7281be7a449 >>"${OUTTO}" 2>&1;
  apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xcbcb082a1bb943db >>"${OUTTO}" 2>&1;
  curl -s http://dl.hhvm.com/conf/hhvm.gpg.key | apt-key add - > /dev/null 2>&1;
  curl -s http://nginx.org/keys/nginx_signing.key | apt-key add - > /dev/null 2>&1;
  echo "${OK}"
  echo
}

# package and repo addition (d) _add respo sources_
function _repos() {
  cat >/etc/apt/sources.list.d/mariadb.list<<EOF
deb http://mirrors.syringanetworks.net/mariadb/repo/10.2/ubuntu/ $(lsb_release -sc) main
EOF
  cat >/etc/apt/sources.list.d/hhvm.list<<EOF
deb http://dl.hhvm.com/ubuntu $(lsb_release -sc) main
EOF
  cat >/etc/apt/sources.list.d/nginx-mainline-$(lsb_release -sc).list<<EOF
deb http://nginx.org/packages/mainline/ubuntu/ $(lsb_release -sc) nginx
deb-src http://nginx.org/packages/mainline/ubuntu/ $(lsb_release -sc) nginx
EOF
  echo "${OK}"
  echo
}

# package and repo addition (e) _update and upgrade_
function _updates() {
  export DEBIAN_FRONTEND=noninteractive &&
  apt-get -y update >>"${OUTTO}" 2>&1;
  apt-get -y upgrade >>"${OUTTO}" 2>&1;
# apt-get -y autoremove >>"${OUTTO}" 2>&1; ### I'll let you decide
  echo "${OK}"
  echo
}

# setting main web root directory function (5)
function _asksitename() {
#################################################################
# You may now optionally name your main web root directory.
# If you choose to not name your main websites root directory,
# then your servers hostname will be used as a default.
#################################################################
  echo "  You may now optionally name your main web root directory."
  echo "  If you choose to not name your main websites root directory,"
  echo "  then your servers hostname will be used as a default."
  echo "  Default: /srv/www/${green}${hostname1}${normal}/public/"
  echo
  echo -n "${bold}${yellow}Would you like to name your main web root directory?${normal} (${bold}${green}Y${normal}/n): "
  read responce
  case $responce in
    [yY] | [yY][Ee][Ss] | "" ) sitename=yes ;;
    [nN] | [nN][Oo] ) sitename=no ;;
  esac
}

function _sitename() {
  if [[ ${sitename} == "yes" ]]; then
    read -p "${bold}Name for your main websites root directory ${normal} : " sitename
    echo
    echo "Your website directory has been set to /srv/www/${green}${bold}${sitename}${normal}/public/"
    echo
  fi
}

function _nositename() {
  if [[ ${sitename} == "no" ]]; then
    echo
    echo "Your website directory has been set to /srv/www/${green}${bold}${hostname1}${normal}/public/"
    echo
  fi
}

# install nginx function (6)
function _nginx() {
  apt-get -y install nginx >>"${OUTTO}" 2>&1;
  update-rc.d nginx defaults >>"${OUTTO}" 2>&1;
  service nginx stop >>"${OUTTO}" 2>&1;
  mv /etc/nginx /etc/nginx-previous >>"${OUTTO}" 2>&1;
  wget https://github.com/JMSDOnline/hstacklet/raw/master/hstacklet-server-configs.tar.gz >/dev/null 2>&1;
  tar -zxvf hstacklet-server-configs.tar.gz >/dev/null 2>&1;
  mv hstacklet-server-configs /etc/nginx >>"${OUTTO}" 2>&1;
  rm -rf hstacklet-server-configs*
  cp /etc/nginx-previous/uwsgi_params /etc/nginx-previous/fastcgi_params /etc/nginx >>"${OUTTO}" 2>&1;
  # rename default.conf template
  if [[ $sitename -eq yes ]];then
    cp /etc/nginx/conf.d/default.conf.save /etc/nginx/conf.d/$sitename.conf
    # build applications web root directory if sitename is provided
    mkdir -p /srv/www/$sitename/logs >/dev/null 2>&1;
    mkdir -p /srv/www/$sitename/ssl/certs >/dev/null 2>&1;
    mkdir -p /srv/www/$sitename/ssl/keys >/dev/null 2>&1;
    mkdir -p /srv/www/$sitename/public >/dev/null 2>&1;
    sed -i "s/sitename/$sitename/" /etc/nginx/conf.d/$sitename.conf
    sed -i "s/sitename_access.log/$sitename_access.log/" /etc/nginx/conf.d/$sitename.conf
    sed -i "s/sitename_error.log/$sitename_error.log/" /etc/nginx/conf.d/$sitename.conf
  else
    cp /etc/nginx/conf.d/default.conf.save /etc/nginx/conf.d/$hostname1.conf
    # build applications web root directory if no sitename is provided
    mkdir -p /srv/www/$hostname1/logs >/dev/null 2>&1;
    mkdir -p /srv/www/$hostname1/ssl/certs >/dev/null 2>&1;
    mkdir -p /srv/www/$hostname1/ssl/keys >/dev/null 2>&1;
    mkdir -p /srv/www/$hostname1/public >/dev/null 2>&1;
    sed -i "s/sitename/$hostname1/" /etc/nginx/conf.d/$hostname1.conf
    sed -i "s/sitename_access.log/$hostname1_access.log/" /etc/nginx/conf.d/$hostname1.conf
    sed -i "s/sitename_error.log/$hostname1_error.log/" /etc/nginx/conf.d/$hostname1.conf
  fi
  echo "${OK}"
  echo
}

# adjust permissions function (7)
function _perms() {
  chgrp -R www-data /srv/www/*
  chmod -R g+rw /srv/www/*
  sh -c 'find /srv/www/* -type d -print0 | sudo xargs -0 chmod g+s'
  echo "${OK}"
  echo
}

# install varnish function (8)
function _hhvm() {
  apt-get -y install hhvm >>"${OUTTO}" 2>&1;
  /usr/share/hhvm/install_fastcgi.sh >>"${OUTTO}" 2>&1;
  update-rc.d hhvm defaults >>"${OUTTO}" 2>&1;
  /usr/bin/update-alternatives --install /usr/bin/php php /usr/bin/hhvm 60 >>"${OUTTO}" 2>&1;
  # get off the port and use socket - HStacklet nginx configurations already know this
  sed -i "s/hhvm.server.port = 9000/hhvm.server.file_socket = \/var\/run\/hhvm\/hhvm.sock/" /etc/hhvm/server.ini
  # make an additional request for memory limit
  echo "memory_limit = 512M" >> /etc/hhvm/php.ini
  echo "expose_php = off" >> /etc/hhvm/php.ini
  if [[ $sitename -eq yes ]];then
    echo '<?php phpinfo(); ?>' > /srv/www/$sitename/public/checkinfo.php
  else
    echo '<?php phpinfo(); ?>' > /srv/www/$hostname1/public/checkinfo.php
  fi
  echo "${OK}"
  echo
}

# install mariadb function (9)
function _mariadb() {
  export DEBIAN_FRONTEND=noninteractive
  apt-get -q -y install mariadb-server >>"${OUTTO}" 2>&1;
  echo "${OK}"
  echo
}

# install phpmyadmin function (10)
function _askphpmyadmin() {
  echo -n "${bold}${yellow}Do you want to install phpMyAdmin?${normal} (${bold}${green}Y${normal}/n): "
  read responce
  case $responce in
    [yY] | [yY][Ee][Ss] | "" ) phpmyadmin=yes ;;
    [nN] | [nN][Oo] ) phpmyadmin=no ;;
  esac
}

function _phpmyadmin() {
  if [[ ${phpmyadmin} == "yes" ]]; then
    # generate random passwords for the MySql root user
    pmapass=$(perl -le 'print map {(a..z,A..Z,0..9)[rand 62] } 0..pop' 15);
    mysqlpass=$(perl -le 'print map {(a..z,A..Z,0..9)[rand 62] } 0..pop' 15);
    mysqladmin -u root -h localhost password "${mysqlpass}"
    echo -n "${bold}Installing MySQL with user:${normal} ${bold}${green}root${normal}${bold} / passwd:${normal} ${bold}${green}${mysqlpass}${normal} ... "
    apt-get -y install debconf-utils >>"${OUTTO}" 2>&1;
    export DEBIAN_FRONTEND=noninteractive
    # silently configure given options and install
    echo "phpmyadmin phpmyadmin/dbconfig-install boolean true" | debconf-set-selections
    echo "phpmyadmin phpmyadmin/mysql/admin-pass password ${mysqlpass}" | debconf-set-selections
    echo "phpmyadmin phpmyadmin/mysql/app-pass password ${pmapass}" | debconf-set-selections
    echo "phpmyadmin phpmyadmin/app-password-confirm password ${pmapass}" | debconf-set-selections
    echo "phpmyadmin phpmyadmin/reconfigure-webserver multiselect none" | debconf-set-selections
    apt-get -y install phpmyadmin >>"${OUTTO}" 2>&1;
    if [[ $sitename -eq yes ]];then
      # create a sym-link to live directory.
      ln -s /usr/share/phpmyadmin /srv/www/$sitename/public
    else
      # create a sym-link to live directory.
      ln -s /usr/share/phpmyadmin /srv/www/$hostname1/public
    fi
    echo "${OK}"
    # get phpmyadmin directory
    DIR="/etc/phpmyadmin";
    # show phpmyadmin creds
    echo '[phpMyAdmin Login]' > ~/.my.cnf;
    echo " - pmadbuser='phpmyadmin'" >> ~/.my.cnf;
    echo " - pmadbpass='${pmapass}'" >> ~/.my.cnf;
    echo '' >> ~/.my.cnf;
    echo "   Access phpMyAdmin at: " >> ~/.my.cnf;
    echo "   http://$server_ip/phpmyadmin/" >> ~/.my.cnf;
    echo '' >> ~/.my.cnf;
    echo '' >> ~/.my.cnf;
    # show mysql creds
    echo '[MySQL Login]' >> ~/.my.cnf;
    echo " - sqldbuser='root'" >> ~/.my.cnf;
    echo " - sqldbpass='${mysqlpass}'" >> ~/.my.cnf;
    echo '' >> ~/.my.cnf;
    # closing statement
    echo
    echo "${bold}Below are your phpMyAdmin and MySQL details.${normal}"
    echo "${bold}Details are logged in the${normal} ${bold}${green}/root/.my.cnf${normal} ${bold}file.${normal}"
    echo "Best practice is to copy this file locally then rm ~/.my.cnf"
    echo
    # show contents of .my.cnf file
    cat ~/.my.cnf
    echo
  fi
}

function _nophpmyadmin() {
  if [[ ${phpmyadmin} == "no" ]]; then
    echo "${cyan}Skipping phpMyAdmin Installation...${normal}"
    echo
  fi
}

# install and adjust config server firewall function (11)
function _askcsf() {
  echo -n "${bold}${yellow}Do you want to install CSF (Config Server Firewall)?${normal} (${bold}${green}Y${normal}/n): "
  read responce
  case $responce in
    [yY] | [yY][Ee][Ss] | "" ) csf=yes ;;
    [nN] | [nN][Oo] ) csf=no ;;
  esac
}

function _csf() {
  if [[ ${csf} == "yes" ]]; then
    echo -n "${green}Installing and Adjusting CSF${normal} ... "
    wget http://www.configserver.com/free/csf.tgz >/dev/null 2>&1;
    tar -xzf csf.tgz >/dev/null 2>&1;
    ufw disable >>"${OUTTO}" 2>&1;
    cd csf
    sh install.sh >>"${OUTTO}" 2>&1;
    perl /usr/local/csf/bin/csftest.pl >>"${OUTTO}" 2>&1;
    # modify csf blocklists - essentially like CloudFlare, but on your machine
    sed -i.bak -e "s/#SPAMDROP|86400|0|/SPAMDROP|86400|100|/" \
               -e "s/#SPAMEDROP|86400|0|/SPAMEDROP|86400|100|/" \
               -e "s/#DSHIELD|86400|0|/DSHIELD|86400|100|/" \
               -e "s/#TOR|86400|0|/TOR|86400|100|/" \
               -e "s/#ALTTOR|86400|0|/ALTTOR|86400|100|/" \
               -e "s/#BOGON|86400|0|/BOGON|86400|100|/" \
               -e "s/#HONEYPOT|86400|0|/HONEYPOT|86400|100|/" \
               -e "s/#CIARMY|86400|0|/CIARMY|86400|100|/" \
               -e "s/#BFB|86400|0|/BFB|86400|100|/" \
               -e "s/#OPENBL|86400|0|/OPENBL|86400|100|/" \
               -e "s/#AUTOSHUN|86400|0|/AUTOSHUN|86400|100|/" \
               -e "s/#MAXMIND|86400|0|/MAXMIND|86400|100|/" \
               -e "s/#BDE|3600|0|/BDE|3600|100|/" \
               -e "s/#BDEALL|86400|0|/BDEALL|86400|100|/" /etc/csf/csf.blocklists;
    # modify csf process ignore - ignore nginx, varnish & mysql
    echo >> /etc/csf/csf.pignore;
    echo "[ HStacklet Additions - These are necessary to avoid noisy emails ]" >> /etc/csf/csf.pignore;
    echo "exe:/usr/sbin/mysqld" >> /etc/csf/csf.pignore;
    echo "exe:/usr/sbin/nginx" >> /etc/csf/csf.pignore;
    echo "exe:/usr/sbin/varnishd" >> /etc/csf/csf.pignore;
    echo "exe:/usr/bin/hhvm" >> /etc/csf/csf.pignore;
    # modify csf conf - make suitable changes for non-cpanel environment
    sed -i.bak -e 's/TESTING = "1"/TESTING = "0"/' \
               -e 's/RESTRICT_SYSLOG = "0"/RESTRICT_SYSLOG = "3"/' \
               -e 's/TCP_IN = "20,21,22,25,53,80,110,143,443,465,587,993,995,2077,2078,2082,2083,2086,2087,2095,2096"/TCP_IN = "20,21,22,25,53,80,110,143,443,465,587,993,995,8080"/' \
               -e 's/TCP_OUT = "20,21,22,25,37,43,53,80,110,113,443,587,873,993,995,2086,2087,2089,2703"/TCP_OUT = "20,21,22,25,37,43,53,80,110,113,443,587,873,993,995,8080"/' \
               -e 's/TCP6_IN = "20,21,22,25,53,80,110,143,443,465,587,993,995,2077,2078,2082,2083,2086,2087,2095,2096"/TCP6_IN = "20,21,22,25,53,80,110,143,443,465,587,993,995,8080"/' \
               -e 's/TCP6_OUT = "20,21,22,25,37,43,53,80,110,113,443,587,873,993,995,2086,2087,2089,2703"/TCP6_OUT = "20,21,22,25,37,43,53,80,110,113,443,587,873,993,995,8080"/' \
               -e 's/DENY_TEMP_IP_LIMIT = "100"/DENY_TEMP_IP_LIMIT = "1000"/' \
               -e 's/SMTP_ALLOWUSER = "cpanel"/SMTP_ALLOWUSER = "root"/' \
               -e 's/PT_USERMEM = "200"/PT_USERMEM = "500"/' \
               -e 's/PT_USERTIME = "1800"/PT_USERTIME = "3600"/' /etc/csf/csf.conf;
    echo "${OK}"
    echo
    # install sendmail as it's binary is required by CSF
    echo "${green}Installing Sendmail${normal} ... "
    apt-get -y install sendmail >>"${OUTTO}" 2>&1;
    export DEBIAN_FRONTEND=noninteractive | /usr/sbin/sendmailconfig >>"${OUTTO}" 2>&1;
    # add administrator email
    echo "${magenta}${bold}Add an Administrator Email Below for Aliases Inclusion${normal}"
    read -p "${bold}Email: ${normal}" admin_email
    echo
    echo "${bold}The email ${green}${bold}$admin_email${normal} ${bold}is now the forwarding address for root mail${normal}"
    echo -n "${green}finalizing sendmail installation${normal} ... "
    # install aliases
    echo -e "mailer-daemon: postmaster
postmaster: root
nobody: root
hostmaster: root
usenet: root
news: root
webmaster: root
www: root
ftp: root
abuse: root
root: $admin_email" > /etc/aliases
    newaliases >>"${OUTTO}" 2>&1;
    echo "${OK}"
    echo
  fi
}

function _nocsf() {
  if [[ ${csf} == "no" ]]; then
    echo "${cyan}Skipping Config Server Firewall Installation${normal} ... "
    echo
  fi
}

# if you're using cloudlfare as a protection and/or cdn - this next bit is important
function _askcloudflare() {
  echo -n "${bold}${yellow}Would you like to whitelist CloudFlare IPs?${normal} (${bold}${green}Y${normal}/n): "
  read responce
  case $responce in
    [yY] | [yY][Ee][Ss] | "" ) cloudflare=yes ;;
    [nN] | [nN][Oo] ) cloudflare=no ;;
  esac
}

function _cloudflare() {
  if [[ ${cloudflare} == "yes" ]]; then
    echo -n "${green}Whitelisting Cloudflare IPs-v4 and -v6${normal} ... "
    echo -e "# BEGIN CLOUDFLARE WHITELIST
# ips-v4
103.21.244.0/22
103.22.200.0/22
103.31.4.0/22
104.16.0.0/12
108.162.192.0/18
141.101.64.0/18
162.158.0.0/15
172.64.0.0/13
173.245.48.0/20
188.114.96.0/20
190.93.240.0/20
197.234.240.0/22
198.41.128.0/17
199.27.128.0/21
# ips-v6
2400:cb00::/32
2405:8100::/32
2405:b500::/32
2606:4700::/32
2803:f800::/32
# END CLOUDFLARE WHITELIST
" >> /etc/csf/csf.allow
    echo "${OK}"
    echo
  fi
}

# install sendmail function (12)
function _asksendmail() {
  echo -n "${bold}${yellow}Do you want to install Sendmail?${normal} (${bold}${green}Y${normal}/n): "
  read responce
  case $responce in
    [yY] | [yY][Ee][Ss] | "" ) sendmail=yes ;;
    [nN] | [nN][Oo] ) sendmail=no ;;
  esac
}

function _sendmail() {
  if [[ ${sendmail} == "yes" ]]; then
    echo "${green}Installing Sendmail ... ${normal}"
    apt-get -y install sendmail >>"${OUTTO}" 2>&1;
    export DEBIAN_FRONTEND=noninteractive | /usr/sbin/sendmailconfig >>"${OUTTO}" 2>&1;
    # add administrator email
    echo "${magenta}Add an Administrator Email Below for Aliases Inclusion${normal}"
    read -p "${bold}Email: ${normal}" admin_email
    echo
    echo "${bold}The email ${green}${bold}$admin_email${normal} ${bold}is now the forwarding address for root mail${normal}"
    echo -n "${green}finalizing sendmail installation${normal} ... "
    # install aliases
    echo -e "mailer-daemon: postmaster
postmaster: root
nobody: root
hostmaster: root
usenet: root
news: root
webmaster: root
www: root
ftp: root
abuse: root
root: $admin_email" > /etc/aliases
    newaliases >>"${OUTTO}" 2>&1;
    echo "${OK}"
    echo
  fi
}

function _nosendmail() {
  if [[ ${sendmail} == "no" ]]; then
    echo "${cyan}Skipping Sendmail Installation...${normal}"
    echo
  fi
}

#################################################################
# The following security & enhancements cover basic security
# measures to protect against common exploits.
# Enhancements covered are adding cache busting, cross domain
# font support, expires tags and protecting system files.
#
# You can find the included files at the following directory...
# /etc/nginx/hstacklet/
#
# Not all profiles are included, review your $sitename.conf
# for additions made by the script & adjust accordingly.
#################################################################

# Round 1 - Location
# enhance configuration function (13)
function _locenhance() {
  if [[ $sitename -eq yes ]];then
    sed -i "s/# include hstacklet\/location\/cache-busting.conf;/include hstacklet\/location\/cache-busting.conf;/" /etc/nginx/conf.d/$sitename.conf
    sed -i "s/# include hstacklet\/location\/cross-domain-fonts.conf;/include hstacklet\/location\/cross-domain-fonts.conf;/" /etc/nginx/conf.d/$sitename.conf
    sed -i "s/# include hstacklet\/location\/expires.conf;/include hstacklet\/location\/expires.conf;/" /etc/nginx/conf.d/$sitename.conf
    sed -i "s/# include hstacklet\/location\/protect-system-files.conf;/include hstacklet\/location\/protect-system-files.conf;/" /etc/nginx/conf.d/$sitename.conf
  else
    sed -i "s/# include hstacklet\/location\/cache-busting.conf;/include hstacklet\/location\/cache-busting.conf;/" /etc/nginx/conf.d/$hostname1.conf
    sed -i "s/# include hstacklet\/location\/cross-domain-fonts.conf;/include hstacklet\/location\/cross-domain-fonts.conf;/" /etc/nginx/conf.d/$hostname1.conf
    sed -i "s/# include hstacklet\/location\/expires.conf;/include hstacklet\/location\/expires.conf;/" /etc/nginx/conf.d/$hostname1.conf
    sed -i "s/# include hstacklet\/location\/protect-system-files.conf;/include hstacklet\/location\/protect-system-files.conf;/" /etc/nginx/conf.d/$hostname1.conf
  fi
  echo "${OK}"
  echo
}

# Round 2 - Security
# optimize security configuration function (14)
function _security() {
  if [[ $sitename -eq yes ]];then
    sed -i "s/# include hstacklet\/directive-only\/sec-bad-bots.conf;/include hstacklet\/directive-only\/sec-bad-bots.conf;/" /etc/nginx/conf.d/$sitename.conf
    sed -i "s/# include hstacklet\/directive-only\/sec-file-injection.conf;/include hstacklet\/directive-only\/sec-file-injection.conf;/" /etc/nginx/conf.d/$sitename.conf
    sed -i "s/# include hstacklet\/directive-only\/sec-php-easter-eggs.conf;/include hstacklet\/directive-only\/sec-php-easter-eggs.conf;/" /etc/nginx/conf.d/$sitename.conf
    if [[ $cloudflare -eq yes ]];then
      sed -i "s/# include hstacklet\/directive-only\/cloudflare-real-ip.conf;/include hstacklet\/directive-only\/cloudflare-real-ip.conf;/" /etc/nginx/conf.d/$sitename.conf
    fi
    sed -i "s/# include hstacklet\/directive-only\/cross-domain-insecure.conf;/include hstacklet\/directive-only\/cross-domain-insecure.conf;/" /etc/nginx/conf.d/$sitename.conf
    sed -i "s/# include hstacklet\/directive-only\/reflected-xss-prevention.conf;/include hstacklet\/directive-only\/reflected-xss-prevention.conf;/" /etc/nginx/conf.d/$sitename.conf
    sed -i "s/# include hstacklet\/directive-only\/mime-type-security.conf;/include hstacklet\/directive-only\/mime-type-security.conf;/" /etc/nginx/conf.d/$sitename.conf
    sed -i "s/# include hstacklet\/directive-only\/common-exploit-prevention.conf;/include hstacklet\/directive-only\/common-exploit-prevention.conf;/" /etc/nginx/conf.d/$sitename.conf
    sed -i "s/# include hstacklet\/directive-only\/timeout-handling.conf;/include hstacklet\/directive-only\/timeout-handling.conf;/" /etc/nginx/conf.d/$sitename.conf
    sed -i "s/# include hstacklet\/directive-only\/cache-file-descriptors.conf;/include hstacklet\/directive-only\/cache-file-descriptors.conf;/" /etc/nginx/conf.d/$sitename.conf
  else
    sed -i "s/# include hstacklet\/directive-only\/sec-bad-bots.conf;/include hstacklet\/directive-only\/sec-bad-bots.conf;/" /etc/nginx/conf.d/$hostname1.conf
    sed -i "s/# include hstacklet\/directive-only\/sec-file-injection.conf;/include hstacklet\/directive-only\/sec-file-injection.conf;/" /etc/nginx/conf.d/$hostname1.conf
    sed -i "s/# include hstacklet\/directive-only\/sec-php-easter-eggs.conf;/include hstacklet\/directive-only\/sec-php-easter-eggs.conf;/" /etc/nginx/conf.d/$hostname1.conf
    if [[ $cloudflare -eq yes ]];then
      sed -i "s/# include hstacklet\/directive-only\/cloudflare-real-ip.conf;/include hstacklet\/directive-only\/cloudflare-real-ip.conf;/" /etc/nginx/conf.d/$hostname1.conf
    fi
    sed -i "s/# include hstacklet\/directive-only\/cross-domain-insecure.conf;/include hstacklet\/directive-only\/cross-domain-insecure.conf;/" /etc/nginx/conf.d/$hostname1.conf
    sed -i "s/# include hstacklet\/directive-only\/reflected-xss-prevention.conf;/include hstacklet\/directive-only\/reflected-xss-prevention.conf;/" /etc/nginx/conf.d/$hostname1.conf
    sed -i "s/# include hstacklet\/directive-only\/mime-type-security.conf;/include hstacklet\/directive-only\/mime-type-security.conf;/" /etc/nginx/conf.d/$hostname1.conf
    sed -i "s/# include hstacklet\/directive-only\/common-exploit-prevention.conf;/include hstacklet\/directive-only\/common-exploit-prevention.conf;/" /etc/nginx/conf.d/$hostname1.conf
    sed -i "s/# include hstacklet\/directive-only\/timeout-handling.conf;/include hstacklet\/directive-only\/timeout-handling.conf;/" /etc/nginx/conf.d/$hostname1.conf
    sed -i "s/# include hstacklet\/directive-only\/cache-file-descriptors.conf;/include hstacklet\/directive-only\/cache-file-descriptors.conf;/" /etc/nginx/conf.d/$hostname1.conf
  fi
  echo "${OK}"
  echo
}

# create self-signed certificate function (15)
function _askcert() {
  echo -n "${bold}${yellow}Do you want to create a self-signed SSL cert and configure HTTPS?${normal} (${bold}${green}Y${normal}/n): "
  read responce
  case $responce in
    [yY] | [yY][Ee][Ss] | "" ) cert=yes ;;
    [nN] | [nN][Oo] ) cert=no ;;
  esac
}

function _cert() {
  if [[ ${cert} == "yes" ]]; then
    if [[ $sitename -eq yes ]];then
      openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/$sitename.key -out /etc/ssl/certs/$sitename.crt
      chmod 400 /etc/ssl/private/$sitename.key
      sed -i -e "s/# listen [::]:443 ssl http2;/listen [::]:443 ssl http2;/" \
             -e "s/# listen *:443 ssl http2;/listen *:443 ssl http2;/" \
             -e "s/# include hstacklet\/directive-only\/ssl.conf;/include hstacklet\/directive-only\/ssl.conf;/" \
             -e "s/# ssl_certificate \/srv\/www\/sitename\/ssl\/certs\/sitename.crt;/ssl_certificate \/srv\/www\/sitename\/ssl\/certs\/sitename.crt;/" \
             -e "s/# ssl_certificate_key \/srv\/www\/sitename\/ssl\/keys\/sitename.key;/ssl_certificate_key \/srv\/www\/sitename\/ssl\/keys\/sitename.key;/" /etc/nginx/conf.d/$sitename.conf
      sed -i "s/sitename/$sitename/" /etc/nginx/conf.d/$sitename.conf
    else
      openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /srv/www/$hostname1/ssl/$hostname1.key -out /srv/www/$hostname1/ssl/$hostname1.crt
      chmod 400 /etc/ssl/private/$hostname1.key
      sed -i -e "s/# listen [::]:443 ssl http2;/listen [::]:443 ssl http2;/" \
             -e "s/# listen *:443 ssl http2;/listen *:443 ssl http2;/" \
             -e "s/# include hstacklet\/directive-only\/ssl.conf;/include hstacklet\/directive-only\/ssl.conf;/" \
             -e "s/# ssl_certificate \/srv\/www\/sitename\/ssl\/sitename.crt;/ssl_certificate \/srv\/www\/sitename\/ssl\/sitename.crt;/" \
             -e "s/# ssl_certificate_key \/srv\/www\/sitename\/ssl\/sitename.key;/ssl_certificate_key \/srv\/www\/sitename\/ssl\/sitename.key;/" /etc/nginx/conf.d/$hostname1.conf
      sed -i "s/sitename/$hostname1/" /etc/nginx/conf.d/$hostname1.conf
    fi
    echo "${OK}"
    echo
  fi
}

function _nocert() {
  if [[ ${cert} == "no" ]]; then
    if [[ $sitename -eq yes ]];then
      sed -i "s/sitename/$sitename/" /etc/nginx/conf.d/$sitename.conf
    else
      sed -i "s/sitename/$hostname1/" /etc/nginx/conf.d/$hostname1.conf
    fi
    echo "${cyan}Skipping SSL Certificate Creation...${normal}"
    echo
  fi
}

# finalize and restart services function (16)
function _services() {
  service apache2 stop >>"${OUTTO}" 2>&1;
  service nginx restart >>"${OUTTO}" 2>&1;
  service hhvm restart >>"${OUTTO}" 2>&1;
  if [[ $sendmail -eq yes ]];then
    service sendmail restart >>"${OUTTO}" 2>&1;
  fi
  if [[ $csf -eq yes ]];then
    service lfd restart >>"${OUTTO}" 2>&1;
    csf -r >>"${OUTTO}" 2>&1;
  fi
  echo "${OK}"
  echo
}

# function to show finished data (19)
function _finished() {
echo
echo
echo
echo '                                /\                 '
echo '                               /  \                '
echo '                          ||  /    \               '
echo '                          || /______\              '
echo '                          |||        |             '
echo '                         |  |        |             '
echo '                         |  |        |             '
echo '                         |__|________|             '
echo '                         |___________|             '
echo '                         |  |        |             '
echo '                         |__|   ||   |\            '
echo '                          |||   ||   | \           '
echo '                         /|||   ||   |  \          '
echo '                        /_|||...||...|___\         '
echo '                          |||::::::::|             '
echo "                ${standout}ENJOY${reset_standout}     || \::::::/              "
echo '                o /       ||  ||__||               '
echo '               /|         ||    ||                 '
echo '               / \        ||     \\_______________ '
echo '           _______________||______`--------------- '
echo
echo
echo "${black}${on_green}    [hstacklet] HHVM LEMP Stack Installation Completed    ${normal}"
echo
echo "${bold}Visit ${green}http://${server_ip}/checkinfo.php${normal} ${bold}to verify your install. ${normal}"
echo "${bold}Remember to remove the checkinfo.php file after verification. ${normal}"
echo
echo
echo "${standout}INSTALLATION COMPLETED in ${FIN}/min ${normal}"
echo
}

clear

S=$(date +%s)
OK=$(echo -e "[ ${bold}${green}DONE${normal} ]")

# HSTACKLET STRUCTURE
_intro
_checkroot
_logcheck
echo -n "${bold}Installing Common Software Properties${normal} ... ";_softcommon
echo -n "${bold}Installing: nano, unzip, dos2unix, htop, iotop, libwww-perl${normal} ... ";_depends
echo -n "${bold}Installing signed keys for MariaDB, Nginx, and HHVM${normal} ... ";_keys
echo -n "${bold}Adding trusted repositories${normal} ... ";_repos
echo -n "${bold}Applying Updates${normal} ... ";_updates
_asksitename;if [[ ${sitename} == "yes" ]]; then _sitename; elif [[ ${sitename} == "no" ]]; then _nositename;  fi
echo -n "${bold}Installing and Configuring Nginx${normal} ... ";_nginx
echo -n "${bold}Adjusting Permissions${normal} ... ";_perms
echo -n "${bold}Installing and Configuring HHVM${normal} ... ";_hhvm
echo -n "${bold}Installing MariaDB Drop-in Replacement${normal} ... ";_mariadb
_askphpmyadmin;if [[ ${phpmyadmin} == "yes" ]]; then _phpmyadmin; elif [[ ${phpmyadmin} == "no" ]]; then _nophpmyadmin;  fi
_askcsf;if [[ ${csf} == "yes" ]]; then _csf; elif [[ ${csf} == "no" ]]; then _nocsf;  fi
if [[ ${csf} == "yes" ]]; then
  _askcloudflare;if [[ ${cloudflare} == "yes" ]]; then _cloudflare;  fi
fi
if [[ ${csf} == "no" ]]; then
  _asksendmail;if [[ ${sendmail} == "yes" ]]; then _sendmail; elif [[ ${sendmail} == "no" ]]; then _nosendmail;  fi
fi
echo "${bold}Addressing Location Edits: cache busting, cross domain font support,${normal}";
echo -n "${bold}expires tags, and system file protection${normal} ... ";_locenhance
echo "${bold}Performing Security Enhancements: protecting against bad bots,${normal}";
echo -n "${bold}file injection, and php easter eggs${normal} ... ";_security
_askcert;if [[ ${cert} == "yes" ]]; then _cert; elif [[ ${cert} == "no" ]]; then _nocert;  fi
echo -n "${bold}Completing Installation & Restarting Services${normal} ... ";_services

E=$(date +%s)
DIFF=$(echo "$E" - "$S"|bc)
FIN=$(echo "$DIFF" / 60|bc)
_finished
