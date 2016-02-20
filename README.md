HStacklet - A HHVM LEMP Stack Kit
==========

| ![HStacklet - A HHVM LEMP Stack Kit](https://github.com/JMSDOnline/hstacklet/blob/master/images/hstacklet-lemp-kit.png "hstacklet") |
|---|
| **HStacklet - A HHVM LEMP Stack Kit** |

#### Script status

  ![script version 1.0](http://b.repl.ca/v1/script_version-1.0-446CB3.png)  ![script build passed](http://b.repl.ca/v1/script_build-passed-1E824C.png)

--------

Kit to quickly install a [LEMP Stack](https://lemp.io) w/ HHVM and perform basic configurations of new Ubuntu 15.04 and 15.10 servers.

Components include a recent mainline version of Nginx (1.9.9) using configurations from the HTML 5 Boilerplate team (_and modified/customized for use with mainline and HHVM_), HHVM v.3.11, and MariaDB 10.0 (drop-in replacement for MySQL), Sendmail (PHP mail function), and CSF (Config Server Firewall).

Deploys a proper directory strucutre, optimizes Nginx to be used with HHVM, creates a PHP page for testing and more!


Script Features
--------
  * Quiet installer - no more long scrolling text vomit, just see what's important; when it's presented.
  * Script writes output to /root/hstacklet.log for additional observations.
  * Color Coding for emphasis on install processes.
  * Defaults are set to (Y) - just hit enter if you accept.
  * Nginx on port 80 with SSL terminiation on 443.
  * No Apache - Full throttle!
  * Fast and Lightweight install.
  * Full Kit functionality - backup scripts included.
  * Actively maintained w/ updates added when stable.
  * HTTP/2 Nginx ready. To view if your webserver is HTTP/2 after installing the script with SSL, check @ <a href="http://h2.nix-admin.com/" target="_blank">HTTP/2 Checker</a>
  * Everything you need to get that Nginx + HHVM server up and running!

Total script install time on a $5 <a href="https://www.digitalocean.com/?refcode=917d3ff0e1c8" target="_blank">Digital Ocean Droplet</a> sits at 10:12 installing everything. No Sendmail or Cert script installs at 04:22. This time assumes you are sitting attentively with the script running. There are a limited number of interactions to be made with the script and most of the softwares installed I have automated and logged, however, I feel it is important to have some sort of interaction... at the very least so you are familiar with what is being installed along with the options to tell it to go to hell.

 Meet the Scripts
--------

__HStacklet__ - (Full Kit) Installs and configures LEMP stack w/ HHVM supporting Website-based server environments.
  *
  * Adds repositories for the latest stable versions of MariaDB, mainline (1.9.x) versions of Nginx, and HHVM 3.x.
  * Installs and configures Nginx, HHVM and MariaDB.
  * Installs HHVM w/ Nginx and modifies for use with socket - no localhost port funk.
  * Disables php exposure
  * Installs and Auto-Configures phpMyAdmin - MySQL & phpMyAdmin credentials are stored in /root/.my.cnf
  * MariaDB 10.0 can easily switched to 5.5 or substituted for PostgreSQL.
  * Installs and Adjusts CSF (Config Server Firewall) - prepares ports used for VStacklet as well as informing your entered email for security alerts.
  * Installs and Enables (PHP) Sendmail
  * Supports IPv6 by default.
  * Optional self-signed SSL cert configuration.
  * Easy to configure & run backup executable __hs-backup__ for data-protection.

__HS-Backup__ - Installs scripts to help manage and automate server/site backups
As standalone or just use the full kit - HS-Backup is included.
  *
  * Backup your files in key locations (ex: /srv/www /etc /root)
  * Backup your databases
  * Package files & databases to one archive
  * Cleanup remaining individual archives
  * Simply configure and type '__hs-backup__' to backup important directories and databases - cron examples included.

![HS-Backup](https://github.com/JMSDOnline/hstacklet/blob/master/images/hs-backup-utility-preview.png "HStacklets HS-Backup Utility")

Getting Started
----------------
_You should read these scripts before running them so you know what they're
doing._ Changes may be necessary to meet your needs.

__Setup__ should be run as __root__ on a fresh __Ubuntu__ installation. __Stack__ should be run on a server without any existing LEMP or LAMP components.

If components are already installed, the core packages can be removed with:
```
apt-get purge apache2 mysql apache2-mpm-prefork apache2-utils apache2.2-bin apache2.2-common \
libapache2-mod-php5 libapr1 libaprutil1 libdbd-mysql-perl libdbi-perl libnet-daemon-perl \
libplrpc-perl libpq5 mysql-client-5.5 mysql-common mysql-server mysql-server-5.5 php5-common \
php5-mysql
apt-get autoclean
apt-get autoremove
```

### HStacklet FULL Kit - Installs and configures the HStacklet HHVM LEMP kit stack:
( _includes backup scripts_ )

**NOTE:** You may need to run first the following  -

```
apt-get install -y curl
```
... then run our main installer ...
```
curl -LO https://raw.github.com/JMSDOnline/hstacklet/master/hstacklet.sh
chmod +x hstacklet.sh
./hstacklet.sh
```

### HStacklet HS-Backup - Installs needed files for running complete system backups:
```
curl -LO https://raw.github.com/JMSDOnline/hstacklet/master/hstacklet-backup-standalone.sh
chmod +x hstacklet-backup-standalone.sh
./hstacklet-backup-standalone.sh
```


### Additional Notes and honorable mentions

HStacklet is a fork from my Varnish + Nginx project [VStacklet](https://github.com/JMSDOnline/vstacklet) modified for Nginx + HHVM - do enjoy!

__A word to the wise__
> At the moment HHVM, though it handles massive loads splendidly and considerably better than typical Zend OpCache, it is still under development. I suggest reviewing the [HHVM tests/passing lists](http://hhvm.com/blog/875/wow-hhvm-is-fast-too-bad-it-doesnt-run-my-code) before attempting to throw this up for hosting your particular CMS. I have several clients running Joomla! (up-to-date) sites and HHVM at the current moment does not play nice with them due to unit tests not currently running because of autoloading issues related to: [this](https://github.com/facebook/hiphop-php/pull/959).

As per any contributions, be it suggestions, critiques, alterations and on and on are all welcome!
