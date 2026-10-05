#!/usr/bin/env bash
# vim: ft=bash ts=2 sw=2 sts=2 noexpandtab

# set -e # Enable exit-on-error

# ------------------------------------------------------------------------------
#scriptAbsPath="$(cd "${0%/*}" &>/dev/null && echo "${PWD}/${0##*/}")"
#scriptBasePath=$(dirname "$scriptAbsPath")
umask 0007
_timestamp0="$(date +%s)"
PATH=$PATH:/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:/bin:/sbin
echoS() { echo -e "\e[32m$*\e[0m"; }
echoW() { echo -e "\e[33m$*\e[0m"; }
echoD() { echo -e "\e[31m$*\e[0m" 1>&2; }
echoI() { echo -e "\e[94m$*\e[0m"; }
echoH1() { echo -e "\e[36m\n\n\n\e[1;2m[   H1    ]\e[22;1m ------------------------------------------------------------------------------\n\e[1;2m[   H1    ]\e[22;1m \e[4m$*\e[24m\n\e[1;2m[   H1    ]\e[22;1m ------------------------------------------------------------------------------\e[0m"; }
echoH2() { echo -e "\e[36m\n\e[2m[   H2    ]\e[22m \e[4m$*\e[24m\e[0m"; }
echoIn() { echo -e "\e[94m\e[2m[  INFO   ]\e[22m $*\e[0m"; }
echoOk() { echo -e "\e[32m\e[2m[   OK    ]\e[22m $*\e[0m"; }
echoWa() { echo -e "\e[33m\e[2m[ WARNING ]\e[22m $*\e[0m"; }
echoEr() { echo -e "\e[31m\e[2m[  ERROR  ]\e[22m $*\e[0m"; }
echoCmd() { echo -e "\e[2;100m\n[   CMD   ]\e[22m \e[1;92m$*\e[0m"; }
echoAsk() { echo -n -e "\e[36m\e[2m[   ASK   ]\e[22m $*\e[0m"; }
echoCallIni() { echo -e "\e[2;35m\n\n\n[  CALL   ] $* (start)\e[0m"; }
echoCallEnd() { echo -e "\e[2;35m\n[  CALL   ] $* (ended)\e[0m"; }
sleepSecs() { echo -e "\e[2;35m\n\n\n[  sleep  ] $1 secs\e[0m"; sleep $1; }

# ------------------------------------------------------------------------------
if [[ "$(whoami)" != "root" ]]; then
  echoEr "You must be «root»"
  exit 1
fi

# ------------------------------------------------------------------------------
_isFsserver() {
  if hostname | grep -i -q 'fsserver'; then
    return 0
  else
    return 1
  fi
}

_isUbuntu18OrGreater() {
  local DISTRIB_RELEASE=
  if ! source /etc/lsb-release; then
    echoEr "Cannot get the Ubuntu version"
    exit 1
  fi

  if echo "${DISTRIB_RELEASE}" | grep -q '^8\.\|^10\.\|^12\.\|^14\.\|^16\.'; then
    return 1
  else
    return 0
  fi
}

_isUbuntu24OrGreater() {
  local DISTRIB_RELEASE=
  if ! source /etc/lsb-release; then
    echoEr "Cannot get the Ubuntu version"
    exit 1
  fi

  if echo "${DISTRIB_RELEASE}" | grep -q '^8\.\|^10\.\|^12\.\|^14\.\|^16\.\|^18\.\|^20\.\|^22\.'; then
    return 1
  else
    return 0
  fi
}

_reloadApache2() {
  echoCmd "/usr/sbin/apache2ctl configtest"
  if ! /usr/sbin/apache2ctl configtest; then
    echoEr "A configuration error has been detected in Apache2"
    exit 1
  fi

  echoCmd "systemctl reload apache2"
  systemctl reload apache2 || exit 1
  sleep 2

  echoCmd "systemctl is-active --quiet apache2"
  if ! systemctl is-active --quiet apache2; then
    echoEr "The Apache2 service is not active"
    exit 1
  else
    echoIn "The Apache2 service is active"
  fi
}

_restartApache2() {
  echoCmd "/usr/sbin/apache2ctl configtest"
  if ! /usr/sbin/apache2ctl configtest; then
    echoEr "A configuration error has been detected in Apache2"
    exit 1
  fi

  echoCmd "systemctl restart apache2"
  systemctl restart apache2 || exit 1
  sleep 2

  echoCmd "systemctl is-active --quiet apache2"
  if ! systemctl is-active --quiet apache2; then
    echoEr "The Apache2 service is not active"
    exit 1
  else
    echoIn "The Apache2 service is active"
  fi
}

_restartMySQL() {
  echoCmd "systemctl restart mysql"
  systemctl restart mysql || exit 1
  sleep 2

  echoCmd "systemctl is-active --quiet mysql"
  if ! systemctl is-active --quiet mysql; then
    echoEr "The MySQL service is not active"
    exit 1
  else
    echoIn "The MySQL service is active"
  fi
}

# ------------------------------------------------------------------------------
aptGetUpdate() {
  echoH1 "APT packages info update"

  echoCmd "apt-get -qq update"
  apt-get -qq update

  sleepSecs 2
}

configureLocaleTimezoneAndDate() {
  echoH1 "Locales, timezone & date/time"

  # ---
  echoH2 "Generating localisation files"

  echoCmd "/usr/sbin/locale-gen 'en_US.UTF-8'"
  /usr/sbin/locale-gen "en_US.UTF-8"

  echoCmd "/usr/sbin/locale-gen 'es_ES.UTF-8'"
  /usr/sbin/locale-gen "es_ES.UTF-8"

  # ---
  echoH2 "Modifing global locale settings: /etc/default/locale"

  echoCmd "/usr/sbin/update-locale LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8"
  /usr/sbin/update-locale LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8

  # ---
  echoH2 "Modifing global environment values: /etc/environment"

  echoCmd "sed -i '/^LC_.*=/d' /etc/environment"
  sed -i '/^LC_.*=/d' /etc/environment

  echoCmd "sed -i '/^LANG=/d' /etc/environment"
  sed -i '/^LANG=/d' /etc/environment

  echoCmd "echo -e \"LANG=en_US.UTF-8\\\nLC_ALL=en_US.UTF-8\" >>/etc/environment"
  echo -e "LANG=en_US.UTF-8\nLC_ALL=en_US.UTF-8" >>/etc/environment

  # ---
  echoH2 "Setting system timezone"

  local _timeZone="Europe/Madrid"
  if grep -i -q "^America/Bogota" /root/serverTZ 2>/dev/null; then
    _timeZone="America/Bogota"
  fi

  if ! timedatectl list-timezones | grep -q "^${_timeZone}$"; then
    echoEr "Invalid «${_timeZone}» timezone"
    exit 1
  else
    echoIn "Timezone selected: ${_timeZone}"
  fi

  if ! grep -q "^${_timeZone}$" /etc/timezone; then
    echo "${_timeZone}" >/etc/timezone

    echoOk "/etc/timezone has the "${_timeZone}" timezone now"
  else
    echoIn "/etc/timezone already has the "${_timeZone}" timezone"
  fi

  echoCmd "timedatectl set-timezone '${_timeZone}'"
  if ! timedatectl set-timezone "${_timeZone}"; then
    echoEr "Cannot set the ${_timeZone} timezone"
    exit 1
  fi

  echoCmd "/usr/sbin/dpkg-reconfigure --frontend=noninteractive tzdata"
  /usr/sbin/dpkg-reconfigure --frontend=noninteractive tzdata

  echoCmd "timedatectl status"
  timedatectl status

  sleepSecs 2

  # ---
  echoH2 "Configuring the ntpd service"

  # WARNING: A partir de la Ubuntu 16.04 la sincronización de la fecha y la hora se controla vía el servicio «timesyncd»
  # WARNING: que es un servicio liviano y válido para la mayoría de casos. Pero como usamos web services con JWTs,
  # WARNING: que por seguridad tenémos un férreo control de la fecha sobre ellos, podría afectarnos ligeras
  # WARNING: perturbaciones en el tiempo del sistema. Así que seguiremos apostando por el servicio «ntpd» que
  # WARNING: (aparentemente) usa técnicas más sofisticadas para mantener el tiempo del sistema constante y gradualmente
  # WARNING: sincronizado.
  echoCmd "timedatectl set-ntp no"
  if ! timedatectl set-ntp no; then
    echoWa "It is posible that the timesyncd sevice was already disabled"
  fi

  echoCmd "apt-get -qq install -y ntp"
  apt-get -qq install -y ntp

  echoCmd "ntpq -p"
  ntpq -p
  if ntpq -p | grep -q -i 'Connection refused'; then
    # The «ntpq -p» command does not exist with an error code if it fails, so...
    echoCmd "/usr/sbin/dpkg-reconfigure ntp"
    /usr/sbin/dpkg-reconfigure ntp

    sleepSecs 5

    echoCmd "ntpq -p"
    ntpq -p
    if ntpq -p | grep -q -i 'Connection refused'; then
      # The «ntpq -p» command does not exist with an error code if it fails, so...
      echoEr "Cannot get the list of peers"
      echoEr "The ntpd service must be repaired manually"
      exit 1
    fi
  fi

  sleepSecs 2
}

_existsPackage() {
  # Nos dice si existe en el repositorio cierto paquete.
  # De esta forma no se forzará la instalación de paquetes que no existan, y que provoque un error que nos haga salir.
  local _pkg="$1"
  if apt-cache search --names-only "^${_pkg}$" | grep -q "^${_pkg} "; then
    return 0
  else
    return 1
  fi
}

installBasePackages() {
  echoH1 "Install/update needed packages"

  # ---
  echoH2 "Install/update packages for protection against Ghost-Vulnerability"
  echoCmd "apt-get -qq install -y libc-bin libc-dev-bin libc6 libc6-dev"
  apt-get -qq install -y libc-bin libc-dev-bin libc6 libc6-dev

  # ---
  echoH2 "Install/update common and needed packages"
  echoCmd "apt-get -qq install -y bash"
  apt-get -qq install -y bash
  echoCmd "apt-get -qq install -y less"
  apt-get -qq install -y less
  echoCmd "apt-get -qq install -y htop"
  apt-get -qq install -y htop
  echoCmd "apt-get -qq install -y screen"
  apt-get -qq install -y screen
  echoCmd "apt-get -qq install -y mc"
  apt-get -qq install -y mc
  echoCmd "apt-get -qq install -y uptimed"
  apt-get -qq install -y uptimed
  echoCmd "apt-get -qq install -y whois"
  apt-get -qq install -y whois
  echoCmd "apt-get -qq install -y tree"
  apt-get -qq install -y tree
  echoCmd "apt-get -qq install -y convmv"
  apt-get -qq install -y convmv
  echoCmd "apt-get -qq install -y zip"
  apt-get -qq install -y zip
  echoCmd "apt-get -qq install -y unzip"
  apt-get -qq install -y unzip
  echoCmd "apt-get -qq install -y rar"
  apt-get -qq install -y rar
  echoCmd "apt-get -qq install -y unrar"
  apt-get -qq install -y unrar
  echoCmd "apt-get -qq install -y curl"
  apt-get -qq install -y curl
  echoCmd "apt-get -qq install -y w3m"
  apt-get -qq install -y w3m
  echoCmd "apt-get -qq install -y lynx"
  apt-get -qq install -y lynx
  echoCmd "apt-get -qq install -y bc"
  apt-get -qq install -y bc
  echoCmd "apt-get -qq install -y smartmontools"
  apt-get -qq install -y smartmontools
  echoCmd "apt-get -qq install -y imagemagick"
  apt-get -qq install -y imagemagick
  echoCmd "apt-get -qq install -y git"
  apt-get -qq install -y git
  echoCmd "apt-get -qq install -y pwgen"
  apt-get -qq install -y pwgen
  echoCmd "apt-get -qq install -y unison"
  apt-get -qq install -y unison
  if _existsPackage unison-all; then
    echoCmd "apt-get -qq install -y unison-all"
    apt-get -qq install -y unison-all
  fi
  echoCmd "apt-get -qq install -y rdiff-backup"
  apt-get -qq install -y rdiff-backup
  if _existsPackage rdiff-backup-fs; then
    echoCmd "apt-get -qq install -y rdiff-backup-fs"
    apt-get -qq install -y rdiff-backup-fs
  fi
  echoCmd "apt-get -qq install -y libxml2-utils"
  apt-get -qq install -y libxml2-utils
  echoCmd "apt-get -qq install -y rename"
  apt-get -qq install -y rename
  echoCmd "apt-get -qq install -y parallel"
  apt-get -qq install -y parallel

  # ---
  echoH2 "Install/update SSH server and client packages"
  echoCmd "apt-get -qq install -y openssh-server openssh-client"
  apt-get -qq install -y openssh-server openssh-client

  # ---
  echoH2 "Install/update MySQL server and client packages"
  echoCmd "apt-get -qq install mysql-server mysql-client"
  apt-get -qq install mysql-server mysql-client
  echoCmd "apt-get -qq install -y dbf2mysql libdbd-xbase-perl"
  apt-get -qq install -y dbf2mysql libdbd-xbase-perl

  sleepSecs 2
}

installApache2AndPhpPackages() {
  echoH1 "Apache2 and PHP management (depending on Ubuntu version)"

  local _packages

  if ! _isUbuntu24OrGreater; then
    echoIn "This is an Ubuntu version lower than 24.04."
    echoIn "It is assumed that the default PHP that Ubuntu has will be used,"
    echoIn "so it is not necessary to specify the PHP version in each of the packages."

    # ---
    echoH2 "Install/update Apache2"

    echoCmd "apt-get -qq install -y apache2 apache2-utils"
    apt-get -qq install -y apache2 apache2-utils

    # ---
    echoH2 "Install/update PHP packages"

    for _php in $(update-alternatives --list php 2>/dev/null | grep -i -v 'warning' | grep -o -i 'php[0-9]\+\..*'); do
      _packages=
      for _package in libapache2-mod-php php php-{common,cli,curl,gd,intl,imagick,xmlrpc,pear,gmp,sqlite3,ldap,mysql,zip,bz2,json,mbstring,xml,bcmath}; do
        if _existsPackage "${_package}"; then
          if [[ -z "${_packages}" ]]; then
            _packages="${_package}"
          else
            _packages="${_packages} ${_package}"
          fi
        fi
      done
      if [[ ! -z "${_packages}" ]]; then
        echoCmd "apt-get -qq install -y ${_packages}"
        apt-get -qq install -y ${_packages}
      fi
    done
  else
    echoIn "This is an Ubuntu version 24.04 or greater."
    echoIn "The Ondřej Surý repository «ppa:ondrej/php» is assumed to have been installed."
    echoIn "As it allows you to install different versions of PHP, the PHP version has to be specified for each package."

    # ---
    echoH2 "Install/update Apache2"

    echoCmd "apt-get -qq install -y apache2 apache2-utils"
    apt-get -qq install -y apache2 apache2-utils

    for _php in $(update-alternatives --list php 2>/dev/null | grep -i -v 'warning' | grep -o -i 'php[0-9]\+\..*'); do
      # ---
      echoH2 "Install/update PHP (${_php}) packages"

      _packages=
      for _package in ${_php} ${_php}-{common,cli,bcmath,bz2,curl,gd,gmp,imagick,intl,mbstring,mysql,sqlite3,xml,xmlrpc,zip} libapache2-mod-${_php} ; do
        if _existsPackage "${_package}"; then
          if [[ -z "${_packages}" ]]; then
            _packages="${_package}"
          else
            _packages="${_packages} ${_package}"
          fi
        fi
      done
      if [[ ! -z "${_packages}" ]]; then
        echoCmd "apt-get -qq install -y ${_packages}"
        apt-get -qq install -y ${_packages}
      fi

      if _existsPackage "${_php}-fpm"; then
        # ---
        echoH2 "Install/update PHP-FPM (${_php}-fpm) package"

        echoCmd "apt-get -qq install -y ${_php}-fpm"
        apt-get -qq install -y "${_php}-fpm"

        echoCmd "bin/systemctl start \"${_php}-fpm\""
        systemctl start "${_php}-fpm"

        echoCmd "systemctl enable \"${_php}-fpm\""
        systemctl enable "${_php}-fpm"
      fi
    done

    # ---
    echoH2 "Is there any PHP-FPM active?"

    if update-alternatives --list php-fpm.sock 2>/dev/null | grep -i -v 'warning' | grep -o -i -q 'php[0-9]\+\..*'; then

      echoIn "A PHP-FPM has been detected, so the Apache2 must have some modules enabled"

      local _restartApache2=

      echoCmd "/usr/sbin/a2query -m proxy"
      if ! /usr/sbin/a2query -m proxy ; then
        echoCmd "/usr/sbin/a2enmod -m proxy"
        /usr/sbin/a2enmod -m proxy

        _restartApache2='true'
      fi

      echoCmd "/usr/sbin/a2query -m proxy_fcgi"
      if ! /usr/sbin/a2query -m proxy_fcgi ; then
        echoCmd "/usr/sbin/a2enmod -m proxy_fcgi"
        /usr/sbin/a2enmod -m proxy_fcgi

        _restartApache2='true'
      fi

      if [[ ! -z "${_restartApache2}" ]]; then
        _restartApache2
      fi
    else
      echoWa "No PHP-FPM has been detected, so the Apache2 modules are not modified"
    fi
  fi

  sleepSecs 2
}

# ------------------------------------------------------------------------------
addWwwUser() {
  # Añade el usuario «www» al sistema si todavía no existe.
  echoH1 "Does the «www» user exist?"

  local _wwwUser='www'
  local _wwwPwd='7TvToN7Uw7AVAjEC'

  echoCmd "id '${_wwwUser}'"
  if ! id "${_wwwUser}"; then
    echoS "User «${_wwwUser}» must be created"
    # Se crea el usuario sin password para poder aprovechar el comando «passwd» y no necesitar la intervención manual.
    echoCmd "sudo /usr/sbin/adduser --disabled-password --home '/home/${_wwwUser}' --ingroup www-data --gecos '${_wwwUser},,,' '${_wwwUser}'"
    sudo /usr/sbin/adduser --disabled-password --home "/home/${_wwwUser}" --ingroup www-data --gecos "${_wwwUser},,," "${_wwwUser}" || exit 1

    echoCmd "echo -e \"${_wwwPwd}\\\n${_wwwPwd}\" | sudo passwd '${_wwwUser}'"
    echo -e "${_wwwPwd}\n${_wwwPwd}" | sudo passwd "${_wwwUser}"
  fi

  sleepSecs 2
}

# ------------------------------------------------------------------------------
configureApache2() {
  echoH1 "Apache2 configuration"

  # ---
  echoH2 "Enabling Apache2 «rewrite» module"
  if ! /usr/sbin/a2query -m rewrite ; then
    /usr/sbin/a2enmod rewrite || exit 1

    _restartApache2

    echoOk "Apache2 «rewrite» module enabled"
  else
    echoIn "Apache2 «rewrite» module already enabled"
  fi

  # ---
  echoH2 "Enabling Apache2 «ssl» module"
  if ! /usr/sbin/a2query -m ssl ; then
    /usr/sbin/a2enmod ssl || exit 1

    _restartApache2

    echoOk "Apache2 «ssl» module enabled"
  else
    echoIn "Apache2 «ssl» module already enabled"
  fi

  # ---
  echoH2 "Setting Apache2 «umask» 0007: 660 for files and 770 for directories"
  if ! grep -q '^umask 0007$' /etc/apache2/envvars; then
    sed -i '/^umask/d' /etc/apache2/envvars
    echo 'umask 0007' >>/etc/apache2/envvars

    _restartApache2

    echoOk "Apache2 «umask» changed"
  else
    echoIn "Apache2 «umask» already applied"
  fi

  # ---
  if ! id www >/dev/null; then
    echoEr "The «www» user does not exist"
    exit 1
  fi

  # ---
  if [[ ! -d "/etc/apache2/conf-available" ]]; then
    echoEr "Cannot access the Apache2 «/etc/apache2/conf-available» path"
    exit 1
  fi

  # ---
  echoH2 "Configuring Apache2 directories"

  local _datosHhtdocs="/datos/htdocs"
  mkdir -p ${_datosHhtdocs} || exit 1
  chmod 775 ${_datosHhtdocs} || exit 1
  chown root:root ${_datosHhtdocs} || exit 1
  echoIn "Owners and permissions applied to ${_datosHhtdocs}"

  local _datosHhtdocsDflabsts="/datos/htdocs/dflabsts"
  mkdir -p ${_datosHhtdocsDflabsts} || exit 1
  chmod 775 ${_datosHhtdocsDflabsts} || exit 1
  chown root:root ${_datosHhtdocsDflabsts} || exit 1
  echoIn "Owners and permissions applied to ${_datosHhtdocsDflabsts}"

  local _datosHhtdocsDflabstsLog="/datos/htdocs/dflabsts/log"
  mkdir -p ${_datosHhtdocsDflabstsLog} || exit 1
  chmod 770 ${_datosHhtdocsDflabstsLog} || exit 1
  chown root:root ${_datosHhtdocsDflabstsLog} || exit 1
  echoIn "Owners and permissions applied to ${_datosHhtdocsDflabstsLog}"

  local _datosHhtdocsDflabstsWww="/datos/htdocs/dflabsts/www"
  mkdir -p ${_datosHhtdocsDflabstsWww} || exit 1
  chmod 770 ${_datosHhtdocsDflabstsWww} || exit 1
  chown www:www-data ${_datosHhtdocsDflabstsWww} || exit 1
  echoIn "Owners and permissions applied to ${_datosHhtdocsDflabstsWww}"

  local _datosHhtdocsDflabstsWwwDflabsts="/datos/htdocs/dflabsts/www/dflabsts"
  mkdir -p ${_datosHhtdocsDflabstsWwwDflabsts} || exit 1
  chmod 770 ${_datosHhtdocsDflabstsWwwDflabsts} || exit 1
  chown www:www-data ${_datosHhtdocsDflabstsWwwDflabsts} || exit 1
  echoIn "Owners and permissions applied to ${_datosHhtdocsDflabstsWwwDflabsts}"

  # ---
  echoH2 "Configuring Apache2 pages"

  # El siguiente PHP puede usarse para comprobar la conectividad entre servidores mediante las distintas VPN.
  local _dflabstsPhp="/datos/htdocs/dflabsts/www/dflabsts/dflabsts.php"
  cat >"${_dflabstsPhp}" <<'End-of-dflabsts-php'
<?php
echo sprintf('dflabsts: %s', (new \DateTime('now'))->format('Y-m-d H:i:s'));
End-of-dflabsts-php
  chown www:www-data "${_dflabstsPhp}" || exit 1
  chmod 660 "${_dflabstsPhp}" || exit 1
  echoIn "Content, owners and permissions applied to ${_dflabstsPhp}"

  # La siguiente imagen se usará para que el javascript de los «Services» del «Ccmaster» pueda encontrar una imagen
  # que exista en todos los fsservers.
  # También podrá usarse como alternativa al PHP anterior, o cualquier otro tipo de comprobación.
  local _dflabstsTestImg="/datos/htdocs/dflabsts/www/dflabsts/1px.png"
  echo -n 'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAAAAAA6fptVAAAACklEQVR4nGP6DwABBQECz6AuzQAAAABJRU5ErkJggg==' | base64 --decode >"${_dflabstsTestImg}"
  chown www-data:www-data "${_dflabstsTestImg}"
  chmod 660 "${_dflabstsTestImg}"
  echoIn "Content, owners and permissions applied to ${_dflabstsTestImg}"

  # ---
  echoH2 "Configuring Apache2 «dflabsts» conf to apply to all sites under /datos/htdocs/dflabsts/"

  local _phpMainVersion="$(php -r 'echo preg_replace("/\..*$/", "", phpversion());')"
  if [[ ${_phpMainVersion} -lt 7 ]]; then
    echoEr "The default PHP version ${_phpMainVersion} is too old"
    exit 1
  fi

  local _phpMaxExecutionTime='1800'
  if _isFsserver; then
    _phpMaxExecutionTime='5400'
  fi

  local _timeZone="Europe/Madrid"
  if grep -i -q "^America/Bogota" /root/serverTZ 2>/dev/null; then
    _timeZone="America/Bogota"
  fi

  # WARNING: Remove the old temporal file, if exists.
  if [[ -f "/etc/apache2/conf-available/01_dflabsts.conf.tmp" ]]; then rm -f "/etc/apache2/conf-available/01_dflabsts.conf.tmp"; fi

  local _confName="01_dflabsts"
  local _a2baseConf="/etc/apache2/conf-available/${_confName}.conf"
  local _a2baseConfTmp="/tmp/apache_${_confName}.conf.tmp"

  cat >"${_a2baseConfTmp}" <<End-of-apache2-conf
ServerName localhost
AddCharset UTF-8 .utf8
AddDefaultCharset UTF-8
ServerSignature Off
MaxKeepAliveRequests 1000
LimitRequestLine 28190

<Directory /datos/htdocs/dflabsts/>
    Options FollowSymLinks
    AllowOverride All
    Require all granted

    <IfModule mod_php${_phpMainVersion}.c>
        DirectoryIndex index.php
        <IfModule mod_mime.c>
            AddType application/x-httpd-php .php
        </IfModule>
        <FilesMatch ".+\.php$">
            SetHandler application/x-httpd-php
        </FilesMatch>
        php_flag        magic_quotes_gpc    Off
        php_flag        short_open_tag      Off
        php_admin_flag  expose_php          Off
        php_admin_flag  display_errors      Off
        php_admin_flag  html_errors         Off
        php_flag        log_errors          On
        php_value       memory_limit        2048M
        php_value       max_execution_time  ${_phpMaxExecutionTime}
        php_value       max_input_vars      25000
        php_value       max_file_uploads    1000
        php_value       post_max_size       500M
        php_value       upload_max_filesize 500M
        php_admin_value date.timezone       ${_timeZone}
        php_admin_value realpath_cache_size 8M
        php_admin_value realpath_cache_ttl  7200
    </IfModule>
</Directory>

Alias /dflabsts /datos/htdocs/dflabsts/www/dflabsts

# vim: syntax=apache ts=4 sw=4 sts=4 sr noet
End-of-apache2-conf

  if [[ ! -f "${_a2baseConf}" ]]; then
    touch "${_a2baseConf}"
  fi

  chown root:root "${_a2baseConfTmp}"
  chmod 660 "${_a2baseConfTmp}"

  if ! diff -q "${_a2baseConf}" "${_a2baseConfTmp}" >/dev/null; then
    cat "${_a2baseConfTmp}" >"${_a2baseConf}"

    echoOk "Apache2 configuration updated: ${_a2baseConf}"
    echoIn "Dump…\n$(cat "${_a2baseConf}")"
  else
    echoIn "Apache2 configuration not modified: ${_a2baseConf}"
  fi

  rm -f "${_a2baseConfTmp}"

  if ! /usr/sbin/a2query -c ${_confName} >/dev/null; then
    if ! /usr/sbin/a2enconf ${_confName} ; then
      echoEr "Cannot enable the Apache2 «${_confName}» configuration"
      exit 1
    else
      echoOk "Apache2 configuration enabled: ${_confName}"
    fi

    sleep 2

    _reloadApache2
  else
    echoIn "Apache2 configuration already enabled: ${_confName}"
  fi

  sleepSecs 2
}

configureLogrotateForApache2Logs() {
  local _apache2LogsPath="/datos/htdocs/dflabsts/log"

  echoH1 "Logrotate for Apache2 logs at «${_apache2LogsPath}»"

  if [[ ! -d "${_apache2LogsPath}" ]]; then
    echoEr "Cannot access to the «${_apache2LogsPath}» path, where the ORBYS apps use to save the Apache2 logs"
    exit 1
  fi

  if ! which logrotate &>/dev/null; then
    echoEr "logrotate not found"
    exit1 1
  fi

  local _logrotateD='/etc/logrotate.d'
  if [[ ! -d "${_logrotateD}" ]]; then
    echoEr "Logrotate configuration point «${_logrotateD}» not found"
    exit 1
  fi

  local _logrotateFile="${_logrotateD}/apache2_dflabsts"
  local _logrotateFileTmp="/tmp/logrotate_apache2_dflabsts.tmp"
  if _isUbuntu24OrGreater; then
    cat >"${_logrotateFileTmp}" <<End-of-logrotate
${_apache2LogsPath}/*.log {
  daily
  missingok
  rotate 14
  compress
  delaycompress
  notifempty
  create 640 root adm
  sharedscripts
  prerotate
    if [ -d /etc/logrotate.d/httpd-prerotate ]; then
      run-parts /etc/logrotate.d/httpd-prerotate
    fi
  endscript
  postrotate
    if pgrep -f ^/usr/sbin/apache2 > /dev/null; then
      invoke-rc.d apache2 reload 2>&1 | logger -t apache2.logrotate
    fi
  endscript
}
End-of-logrotate
  else
    cat >"${_logrotateFileTmp}" <<End-of-logrotate
${_apache2LogsPath}/*.log {
  daily
  missingok
  rotate 14
  compress
  delaycompress
  notifempty
  create 640 root root
  sharedscripts
  prerotate
    if [ -d /etc/logrotate.d/httpd-prerotate ]; then \
      run-parts /etc/logrotate.d/httpd-prerotate; \
    fi; \
  endscript
  postrotate
    if invoke-rc.d apache2 status > /dev/null 2>&1; then \
      invoke-rc.d apache2 reload > /dev/null 2>&1; \
    fi;
  endscript
}
End-of-logrotate
  fi

  if [[ ! -f "${_logrotateFile}" ]]; then
    touch "${_logrotateFile}"
  fi

  chown root:root "${_logrotateFile}" || exit 1
  chmod 644 "${_logrotateFile}" || exit 1

  if ! diff -q "${_logrotateFile}" "${_logrotateFileTmp}" >/dev/null; then
    cat "${_logrotateFileTmp}" >"${_logrotateFile}"

    echoOk "Logrotate configuration file updated: ${_logrotateFile}"
    echoIn "Dump…\n$(cat "${_logrotateFile}")"
  else
    echoIn "Logrotate configuration file not modified: ${_logrotateFile}"
  fi

  rm -f "${_logrotateFileTmp}"

  echoOk "Logrotate applied"

  sleepSecs 2
}

_modifyPhpIni() {
  # Modifica el fichero ini de PHP con la etiqueta y valor pasados por parámetro.
  # No hará ninguna sustitución si no hace falta.
  # Devolverá 0 (true en SHELL) si sí ha habido alguna modificación.
  local _ini="$1"
  local _tag="$2"
  local _val="$3"

  if [[ ! -f "${_ini}" ]]; then
    echoEr "Cannot access the PHP configuration file for «cli»"
    exit 1
  fi

  if ! grep -i -q "^${_tag} .*=.*${_val}$" "${_ini}"; then
    # Se borra la posible línea que contenía la etiqueta que queremos modificar
    # y se añade al final del fichero la etiqueta con el valor correcto.
    sed -i "/^${_tag} .*=/d" "${_ini}"
    echo "${_tag} = ${_val}" >>"${_ini}"

    echoOk "${_ini} - ${_tag} = ${_val} setted"

    return 0
  fi

  # echoIn "${_ini} - ${_tag} = ${_val}"

  return 1
}

#
configurePhp() {
  echoH1 "PHP configuration"

  # ---
  echoH2 "Enabling needed PHP modules"

  for _phpModule in bcmath bz2 curl gd gmp imagick intl mbstring mysqli sqlite3 xml xmlrpc zip ; do
    /usr/sbin/phpenmod ${_phpModule}
    echoIn "PHP module ${_phpModule} enabled"
  done

  # ---
  # Modifica los valores por defecto que tiene el fichero de configuración del PHP en modo cliente (cli).
  # Para la parte de Apache2 no hace falta hacer ningún cambio ya que dicha configuración deberá ir dentro de los sites.
  #local _phpIni="$(php -i | grep -i 'cli/php.ini' | grep -o '/etc.*/php.ini')"
  local _phpMaxExecutionTime='1800'
  if _isFsserver; then
    _phpMaxExecutionTime='5400'
  fi

  local _timeZone="Europe/Madrid"
  if grep -i -q "^America/Bogota" /root/serverTZ 2>/dev/null; then
    _timeZone="America/Bogota"
  fi

  local _phpFpmService=
  local _phpBin=
  local _isPhpIniModified=
  for _basePhpPath in $(ls -1 /etc/php | grep '^[0-9]\+\.[0-9]\+'); do
    for _phpIni in "/etc/php/${_basePhpPath}/cli/php.ini" "/etc/php/${_basePhpPath}/fpm/php.ini"; do
      echoH2 "${_phpIni} configuration"

      if [[ ! -f "${_phpIni}" ]]; then
        echoWa "${_phpIni} not found"
        sleep 0.25
      else
        _isPhpIniModified=false
        _modifyPhpIni "${_phpIni}" 'short_open_tag'         'Off'                     && _isPhpIniModified=true
        _modifyPhpIni "${_phpIni}" 'expose_php'             'Off'                     && _isPhpIniModified=true
        _modifyPhpIni "${_phpIni}" 'display_errors'         'Off'                     && _isPhpIniModified=true
        _modifyPhpIni "${_phpIni}" 'html_errors'            'Off'                     && _isPhpIniModified=true
        _modifyPhpIni "${_phpIni}" 'log_errors'             'On'                      && _isPhpIniModified=true
        _modifyPhpIni "${_phpIni}" 'memory_limit'           '-1'                      && _isPhpIniModified=true
        _modifyPhpIni "${_phpIni}" 'max_input_time'         '600'                     && _isPhpIniModified=true
        _modifyPhpIni "${_phpIni}" 'max_execution_time'     "${_phpMaxExecutionTime}" && _isPhpIniModified=true
        _modifyPhpIni "${_phpIni}" 'max_input_vars'         "25000"                   && _isPhpIniModified=true
        _modifyPhpIni "${_phpIni}" 'max_file_uploads'       "1000"                    && _isPhpIniModified=true
        _modifyPhpIni "${_phpIni}" 'default_socket_timeout' '600'                     && _isPhpIniModified=true
        _modifyPhpIni "${_phpIni}" 'post_max_size'          '550M'                    && _isPhpIniModified=true
        _modifyPhpIni "${_phpIni}" 'upload_max_filesize'    '500M'                    && _isPhpIniModified=true
        _modifyPhpIni "${_phpIni}" 'date.timezone'          "${_timeZone}"            && _isPhpIniModified=true
        _modifyPhpIni "${_phpIni}" 'realpath_cache_size'    '8M'                      && _isPhpIniModified=true
        _modifyPhpIni "${_phpIni}" 'realpath_cache_ttl'     '7200'                    && _isPhpIniModified=true

        if echo "${_phpIni}" | grep -q '/fpm/'; then
          _phpFpmService="php${_basePhpPath}-fpm"
          _phpBin="/usr/sbin/php-fpm${_basePhpPath}"

          if [[ ${_isPhpIniModified} = false ]] ; then
            echoIn "${_phpIni} unmodified, so the ${_phpFpmService} service does not have to be restarted"
          else
            if ! systemctl is-active --quiet ${_phpFpmService}; then
              echoWa "The ${_phpFpmService} service is not active, and it will remain as it"
            else
              systemctl restart ${_phpFpmService} || exit 1
              sleep 1

              if ! systemctl is-active --quiet ${_phpFpmService}; then
                echoEr "The ${_phpFpmService} service is not active after restart it"
                exit 1
              else
                echoOk "The ${_phpFpmService} service has been successfully restarted"
              fi
            fi
          fi
        else
          _phpBin="/usr/sbin/php${_basePhpPath}"
          if [[ ${_isPhpIniModified} = false ]] ; then
            echoIn "${_phpIni} unmodified"
          fi
        fi

        sleep 1
      fi
    done
  done

  sleepSecs 2
}

# ------------------------------------------------------------------------------
configureMysql() {
  # TODO: Echar un ojo al comando «curl -L http://mysqltuner.pl/ | perl».
  echoH1 "MySQL configuration"

  local _anyIpEnabled=
  if [[ "$1" == '--mysql-listen-any-ip' ]]; then
    _anyIpEnabled='enabled'
  fi

  # WARNING: Como pide una password, por ahora obviamos esta comprobación.
  # Va a comprobarse que el datadir del MySQL esté bien configurado.
  # MySQL datadir=/datos/mysql.
  # if ! mysql -uroot -p -i -BN -e 'SELECT @@datadir' | grep -q '^/datos/mysql'; then
  #     echoEr "The MySQL «datadir» must be «/datos/mysql»"
  #     #exit 1
  # fi

  # Crea ficheros de configuración base del MySQL.
  local _mysqlConfDPath="/etc/mysql/mysql.conf.d"
  if [[ ! -d "${_mysqlConfDPath}" ]]; then
    echoEr "Cannot access the MySQL «${_mysqlConfDPath}» path"
    exit 1
  fi

  # Fichero con la configuración que se espera que tenga.
  local _mysqlBaseCnf="${_mysqlConfDPath}/zz_01_dflabsts.cnf"
  local _mysqlBaseCnfTmp="${_mysqlBaseCnf}.tmp"
  # Removed in MySQL 8.0:
  #query_cache_size=0
  #query_cache_type=0
  cat >"${_mysqlBaseCnfTmp}" <<'End-of-mysql-conf'
[mysqld]
character-set-server=utf8
collation-server=utf8_unicode_ci
init-connect='SET NAMES utf8'
sql-mode='IGNORE_SPACE'
max_connections=4000
connect_timeout=25
group_concat_max_len=1000000
skip-external-locking
#skip-name-resolve
max_allowed_packet=64M
End-of-mysql-conf

  if [[ ! -f "${_mysqlBaseCnf}" ]]; then
    touch "${_mysqlBaseCnf}"
  fi

  # Se ha comprobado que quien haya creado el sistema de configuración del MySQL en Ubuntu es tontito, como mínimo.
  # Debido al umask «0007» de root, los ficheros anteriores se crean con permisos «660».
  # Pues bien, si estos no tienen permiso de lectura para «others» no se van a tener en cuenta.
  # Así que hay que cambiar los permisos. Increible.
  chown root:root "${_mysqlBaseCnf}" || exit 1
  chmod 644 "${_mysqlBaseCnf}" || exit 1

  if ! diff -q "${_mysqlBaseCnf}" "${_mysqlBaseCnfTmp}" >/dev/null; then
    cat "${_mysqlBaseCnfTmp}" >"${_mysqlBaseCnf}"

    echoOk "MySQL configuration file updated: ${_mysqlBaseCnf}"
    echoIn "Dump…\n$(cat "${_mysqlBaseCnf}")"

    _restartMySQL
  else
    echoIn "MySQL configuration file not modified: ${_mysqlBaseCnf}"
  fi

  rm -f "${_mysqlBaseCnfTmp}"

  if ! _isFsserver; then
    local _mysqlAnyIpCnf="${_mysqlConfDPath}/zz_02_dflabsts_access_from_any_ip.cnf"
    if [[ -n "${_anyIpEnabled}" ]]; then
      local _mysqlAnyIpCnfTmp="${_mysqlAnyIpCnf}.tmp"

      cat >"${_mysqlAnyIpCnfTmp}" <<'End-of-mysqld-conf'
[mysqld]
bind-address=0.0.0.0
End-of-mysqld-conf

      if [[ ! -f "${_mysqlAnyIpCnf}" ]]; then
        touch "${_mysqlAnyIpCnf}"
      fi

      chown root:root "${_mysqlBaseCnf}" || exit 1
      chmod 644 "${_mysqlAnyIpCnf}" || exit 1

      if ! diff -q "${_mysqlAnyIpCnf}" "${_mysqlAnyIpCnfTmp}" >/dev/null; then
        cat "${_mysqlAnyIpCnfTmp}" >"${_mysqlAnyIpCnf}"

        echoOk "MySQL configuration file updated: ${_mysqlAnyIpCnf}"
        echoIn "Dump…\n$(cat "${_mysqlAnyIpCnf}")"

        _restartMySQL
      else
        echoIn "MySQL configuration file not modified: ${_mysqlAnyIpCnf}"
      fi

      rm -f "${_mysqlAnyIpCnfTmp}"

      # ---
      echoH2 "Checking if the MySQL server is listening from any IP"
      echoCmd "netstat -a -n | grep 'tcp.*0.0.0.0:3306.*LISTEN'"
      if ! netstat -a -n | grep "tcp.*0.0.0.0:3306.*LISTEN"; then
        echoEr "The MySQL is not listening from any IP"
        exit 1
      fi
    # else
    # Por el momento, si no se pasa el parámetro «--mysql-listen-any-ip» no se eliminará el fichero si existiese.
    fi
  fi

  sleepSecs 2
}

# ------------------------------------------------------------------------------
installComposer1() {
  echoH1 "Install/update Composer v1"

  if _isUbuntu24OrGreater; then
    echoWa "The Composer v1 is not necessary in an Ubuntu 24 or superior"

    sleepSecs 2

    return 0
  fi

  export COMPOSER_ALLOW_SUPERUSER=1;
  local _composer1='/usr/local/bin/composer'

  # WARNING: Reparación de la instalación del composer 2.
  # Lo que hacemos es detectar el composer 2 y eliminarlo para, ahora sí, bajar la versión 1.
  if [[ -x "${_composer1}" ]]; then
    echoCmd "'${_composer1}' --version | grep -q -i '^Composer version 2'"
    if "${_composer1}" --version | grep -q -i '^Composer version 2'; then
      echoCmd "rm -f '${_composer1}'"
      rm -f "${_composer1}"
    fi
  fi

  if [[ ! -x "${_composer1}" ]]; then
    echoCmd "wget -q -O - https://composer.github.io/installer.sig"
    local _composer1ExpectedSignature="$(wget -q -O - https://composer.github.io/installer.sig)"
    # if [[ -z "${_composer1ExpectedSignature}" ]]; then
    #   # Chapuza: Se ha encontrado un error en Ubuntus 12.x, que tienen problemas para aceptar el handshake de la
    #   # conexión TLS. Así que se prueba sin https.
    #   echoCmd "wget -q -O - http://composer.github.io/installer.sig"
    #   _composer1ExpectedSignature="$(wget -q -O - http://composer.github.io/installer.sig)"
    # fi
    echoCmd "php -r \"readfile('https://getcomposer.org/installer');\" >'/tmp/composer-setup.php'"
    php -r "readfile('https://getcomposer.org/installer');" >'/tmp/composer-setup.php'
    echoCmd "php -r \"echo hash_file('SHA384', '/tmp/composer-setup.php');\""
    local _composer1ActualSignature="$(php -r "echo hash_file('SHA384', '/tmp/composer-setup.php');")"
    if [[ "${_composer1ExpectedSignature}" != "${_composer1ActualSignature}" ]]; then
      echoEr "Invalid composer installer signature (expected is «${_composer1ExpectedSignature}» and actual is «${_composer1ActualSignature}»)."
      /php -r "unlink('/tmp/composer-setup.php');"

      sleepSecs 5

      return 1
    fi

    echoCmd "sudo php /tmp/composer-setup.php --1 --install-dir=/usr/local/bin --filename=composer"
    sudo php /tmp/composer-setup.php --1 --install-dir=/usr/local/bin --filename=composer
    echoCmd "php -r \"unlink('/tmp/composer-setup.php');\""
    php -r "unlink('/tmp/composer-setup.php');"

    # Comprobación de que el fichero está instalado donde toca.
    if [[ ! -f "${_composer1}" ]]; then
      echoEr "Cannot acces to the «${_composer1}» file"

      sleepSecs 5

      return 1
    fi
  fi

  echoCmd "chown root:root '${_composer1}'"
  chown root:root "${_composer1}" || exit 1

  echoCmd "chmod 775 '${_composer1}'"
  chmod 775 "${_composer1}" || exit 1

  echoCmd "'${_composer1}' self-update"
  "${_composer1}" self-update

  sleepSecs 2
}

installComposer2() {
  echoH1 "Install/update Composer v2"

  export COMPOSER_ALLOW_SUPERUSER=1;
  local _composer2='/usr/local/bin/composer2'

  if [[ ! -x "${_composer2}" ]]; then
    echoCmd "wget -q -O - https://composer.github.io/installer.sig"
    local _composer2ExpectedSignature="$(wget -q -O - https://composer.github.io/installer.sig)"
    if [[ -z "${_composer2ExpectedSignature}" ]]; then
      # Chapuza: Se ha encontrado un error en Ubuntus 12.x, que tienen problemas para aceptar el handshake de la
      # conexión TLS. Así que se prueba sin https.
      echoCmd "wget -q -O - http://composer.github.io/installer.sig"
      _composer2ExpectedSignature="$(wget -q -O - http://composer.github.io/installer.sig)"
    fi
    echoCmd "php -r \"readfile('https://getcomposer.org/installer');\" >'/tmp/composer-setup.php'"
    php -r "readfile('https://getcomposer.org/installer');" >'/tmp/composer-setup.php'
    echoCmd "php -r \"echo hash_file('SHA384', '/tmp/composer-setup.php');\""
    local _composer2ActualSignature="$(php -r "echo hash_file('SHA384', '/tmp/composer-setup.php');")"
    if [[ "${_composer2ExpectedSignature}" != "${_composer2ActualSignature}" ]]; then
      echoEr "Invalid composer installer signature (expected is «${_composer2ExpectedSignature}» and actual is «${_composer2ActualSignature}»)."
      echoCmd "php -r \"unlink('/tmp/composer-setup.php');\""
      php -r "unlink('/tmp/composer-setup.php');"

      sleepSecs 5

      return 1
    fi

    echoCmd "sudo php /tmp/composer-setup.php --2 --install-dir=/usr/local/bin --filename=composer2"
    sudo php /tmp/composer-setup.php --2 --install-dir=/usr/local/bin --filename=composer2
    echoCmd "php -r \"unlink('/tmp/composer-setup.php');\""
    php -r "unlink('/tmp/composer-setup.php');"

    # Comprobación de que el fichero está instalado donde toca.
    if [[ ! -f "${_composer2}" ]]; then
      echoEr "Cannot acces to the «${_composer2}» file"

      sleepSecs 5

      return 1
    fi
  fi

  echoCmd "chown root:root '${_composer2}'"
  chown root:root "${_composer2}" || exit 1

  echoCmd "chmod 775 '${_composer2}'"
  chmod 775 "${_composer2}" || exit 1

  echoCmd "'${_composer2}' self-update"
  "${_composer2}" self-update

  sleepSecs 2
}

# ------------------------------------------------------------------------------
configureSudoers() {
  # TODO: [2026-02-16] En el momento en que no se configuren más fsserver con versiones de Ubuntu inferiores a la 24
  # TODO: se deberá de dejar de usar este método, ya que los propios proyectos que se instalen se harán cargo de
  # TODO: configurar correctamente sus propios ficheros «sudoer» en caso de necesitarlos.
  echoH1 "Sudoers configuration"

  if ! _isFsserver; then
    echoWa "Sudoers configuration only available in the fsservers"

    sleepSecs 2

    return 0
  fi

  local includeSudoersPath="/etc/sudoers.d"
  if [[ ! -d "${includeSudoersPath}" ]]; then
    echoEr "Cannot get the sudoers «${includeSudoersPath}» path"
    exit 1
  fi

  # Comprobación de acceso al fichero del paquete contenedor de los sudoers a instalar
  local _fsserverSudoersTmp="/tmp/sudoers_fsserver"
  cat >"${_fsserverSudoersTmp}" <<'End-of-sudoers'
# Comandos disponibles para el usuario «www-data» (Apache2) para escalar a «root»:
www-data ALL=(ALL) NOPASSWD: /bin/mkdir
www-data ALL=(ALL) NOPASSWD: /bin/mv
www-data ALL=(ALL) NOPASSWD: /bin/rm
www-data ALL=(ALL) NOPASSWD: /bin/tar
www-data ALL=(ALL) NOPASSWD: /usr/bin/rename
www-data ALL=(ALL) NOPASSWD: /usr/bin/stat
www-data ALL=(ALL) NOPASSWD: /bin/chmod
www-data ALL=(ALL) NOPASSWD: /bin/chown
www-data ALL=(ALL) NOPASSWD: /bin/chgrp
www-data ALL=(ALL) NOPASSWD: /usr/bin/net getlocalsid
www-data ALL=(ALL) NOPASSWD: /usr/bin/getent
www-data ALL=(ALL) NOPASSWD: /usr/sbin/smbldap-groupadd
www-data ALL=(ALL) NOPASSWD: /usr/sbin/smbldap-groupmod
www-data ALL=(ALL) NOPASSWD: /usr/sbin/smbldap-groupdel
www-data ALL=(ALL) NOPASSWD: /usr/sbin/smbldap-groupshow
www-data ALL=(ALL) NOPASSWD: /usr/sbin/smbldap-usermod
www-data ALL=(ALL) NOPASSWD: /usr/sbin/smbldap-userdel
www-data ALL=(ALL) NOPASSWD: /usr/sbin/smbldap-usershow
www-data ALL=(ALL) NOPASSWD: /usr/sbin/smbldap-passwd
www-data ALL=(ALL) NOPASSWD: /usr/bin/mysqldump
www-data ALL=(ALL) NOPASSWD: /usr/bin/dbf2mysql
www-data ALL=(ALL) NOPASSWD: /usr/local/bin/CCFileSystem

# Comandos disponibles para el usuario «www-data» (Apache2) para escalar a «papercut»:
www-data ALL=(papercut) NOPASSWD: /datos/papercut/server/bin/linux-i686/server-command
www-data ALL=(papercut) NOPASSWD: /datos/papercut/server/bin/linux-x64/server-command

# Shutdown commands without a password for users in group 'shutdown'
Cmnd_Alias SHUTDOWN_CMDS = /sbin/shutdown, /sbin/reboot, /sbin/halt
%shutdown ALL=(ALL) NOPASSWD: SHUTDOWN_CMDS
End-of-sudoers

  local _fsserverSudoers="${includeSudoersPath}/01_fsserver"
  if [[ ! -f "${_fsserverSudoers}" ]]; then
    touch "${_fsserverSudoers}"
  fi

  chown root:root "${_fsserverSudoers}" || exit 1
  chmod 0440 "${_fsserverSudoers}" || exit 1

  if ! diff -q "${_fsserverSudoersTmp}" "${_fsserverSudoers}" >/dev/null; then
    # Si existe un backup, se elimina.
    find "${includeSudoersPath}" -type f -iname '01_fsserver.20*' -delete

    cat "${_fsserverSudoersTmp}" >"${_fsserverSudoers}"

    echoOk "Sudoers file updated: ${_fsserverSudoers}"
    echoIn "Dump…\n$(cat "${_fsserverSudoers}")"
  else
    echoIn "Sudoers file not modified: ${_fsserverSudoers}"
  fi

  rm -f "${_fsserverSudoersTmp}"

  # Sea como sea, aunque la versión no haya cambiado, se analiza la versión actual.
  if ! /usr/sbin/visudo -c -f "${_fsserverSudoers}"; then
    echoEr "Invalid sudoers file «${_fsserverSudoers}»"
    exit 1
  fi

  sleepSecs 2
}

# ------------------------------------------------------------------------------
installOhMyZshToUser() {
  local _user="$1"

  echoH1 "OhMyZsh & OhMyZshMfontc configuration for «${_user}»"

  if ! which zsh &>/dev/null; then
    echoEr "Cannot find the «zsh» shell"

    sleepSecs 5

    return 1
  else
    local _zshBinPath="$(which zsh)"
  fi

  # ---
  echoH2 "Exists the «${_user}» user?"
  echoCmd "id '${_user}'"
  if ! id "${_user}"; then
    echoEr "The user «${_user}» does not exist"

    sleepSecs 5

    return 1
  fi

  # ---
  echoH2 "Obtain the «${_user}» home path"
  echoCmd "eval echo '~${_user}'"
  local _homePath="$(eval echo "~${_user}")"
  if [[ ! -d "${_homePath}" ]]; then
    echoEr "Cannot access the «${_homePath}» home path"

    sleepSecs 5

    return 1
  else
    echoIn "${_homePath}"
  fi

  # ---
  echoH2 "Assign «zsh» as the default shell to the «${_user}» user"
  echoCmd "sudo chsh -s ${_zshBinPath} '${_user}'"
  sudo chsh -s ${_zshBinPath} "${_user}"

  # Instalación/actualización del OhMyZsh.
  local _ohMyZshPath="${_homePath}/.oh-my-zsh"
  local _ohMyZshMfontcPath="${_homePath}/.mfontc_home"

  if [[ ! -d "${_ohMyZshPath}" || ! -d "${_ohMyZshMfontcPath}" ]]; then
    echoS "OhMyZsh installation for «${_user}»"
    su -c "cd ; umask 0007 ; wget -q -O - --header='Authorization: token 6f2f86862affbc7a6596f4a8c39b79d72c3adc5f' 'https://api.github.com/repos/DFLabsTechSolutions/mfontc_home/contents/tools/install_zsh.sh' | sed -n '/\"content\"/p' | sed 's/^.*\"content\": *\"//;s/\",.*$//' | sed \"s/\\\\\\n/\\\\n/g\" | base64 -d > ~/.z.sh ; chmod u+x ~/.z.sh ; . ~/.z.sh ; rm -rf ~/.z.sh" "${_user}"
  else
    if [[ -d "${_ohMyZshPath}" ]]; then
      # ---
      echoH2 "OhMyZsh update for «${_user}»"
      if ! su -c "cd '${_ohMyZshPath}' ; /usr/bin/env /usr/bin/git pull --rebase --stat origin master" "${_user}"; then
        echoEr "An error occurred while updating OhMyZsh: Please try again later"
      fi
    fi

    if [[ -d "${_ohMyZshMfontcPath}" ]]; then
      # ---
      echoH2 "OhMyZshMfontc update for «${_user}»"
      if ! su -c "cd '${_ohMyZshMfontcPath}' ; /usr/bin/env /usr/bin/git pull --rebase --stat origin master" "${_user}"; then
        echoEr "An error occurred while updating OhMyZshMfontc: Please try again later"
      fi
    fi
  fi

  return 0
}

installZsh() {
  echoH1 "ZSH configuration"

  echoCmd "apt-get -qq install -y zsh zsh-doc"
  apt-get -qq install -y zsh zsh-doc

  # Si existe el paquete 'zsh-lovers', se intalará.
  echoCmd "dpkg -l | grep -i -q 'zsh-lovers'"
  if dpkg -l | grep -i -q 'zsh-lovers'; then
    echoCmd "apt-get -qq install -y zsh-lovers"
    apt-get -qq install -y zsh-lovers
  fi

  installOhMyZshToUser "root"
  installOhMyZshToUser "www"

  if _isFsserver; then
    installOhMyZshToUser "administrador"
    installOhMyZshToUser "_o_mfontc"
  fi

  sleepSecs 2
}

# ------------------------------------------------------------------------------
# Main
# ------------------------------------------------------------------------------
if ! _isUbuntu18OrGreater; then
  echoEr "It is required that de Ubuntu version must be 18 or superior"
  exit 1
fi

aptGetUpdate
configureLocaleTimezoneAndDate
addWwwUser
installBasePackages
installApache2AndPhpPackages
configureApache2
configureLogrotateForApache2Logs
configurePhp
configureMysql "$1"
installComposer1
installComposer2
configureSudoers
installZsh

# ------------------------------------------------------------------------------
_timestamp1="$(date +%s)"
timeDiff="$(echo "${_timestamp1}-${_timestamp0}" | bc -l)"

echoH1 "Finished in ${timeDiff} s."
