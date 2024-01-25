# HOWTO Install and Configure FileSender with a Shibboleth SP v3 on Debian based Linux Distribution 

Authors: Mario Reale/GÉANT - Marco Malavolti/GARR

## Table of Contents

1.  [Requirements](#requirements)
    1.  [Hardware](#hardware)
    2.  [Software](#software)
    3.  [Others](#others)
2.  [Notes](#notes)
3.  [Configure the environment](#configure-the-environment)
4.  [Configure APT Mirror](#configure-apt-mirror)
5.  [Install Shibboleth Service Provider](#install-shibboleth-service-provider)
6.  [Install Dependencies](#install-dependencies)
7.  [Install MySQL server](#Install-MySQL-server)
    1.   [Improve MySQL installation security](#Improve-MySQL-installation-security)


## Requirements

### Hardware

-   CPU: 2 Core (64 bit)
-   RAM: 2 GB (with MDQ service), 4GB (without MDQ service)
-   HDD: 10 GB
-   OS: Debian 12 / Ubuntu 22.04

### Software

-   Apache Web Server (*\<= 2.4*)
-   OpenSSL (*\<= 3.0.2*)
-   Shibboleth Service Provider (*\<= 3.4.1*)
-   PHP (*\<= 8.1*)

### Others

-   SSL Credentials: HTTPS Certificate & Private Key
-   Logo:
    -   size: 64px by 350px wide and 64px by 146px high
    -   format: PNG
    -   style: with a transparent background

[TOC](#table-of-contents)

## Notes

This HOWTO uses `example.org` and `filesender.example.org` as example values.

Please remember to **replace all occurencences** of:

-   the `example.org` value with the SP domain name
-   the `filesender.example.org` value with the Full Qualified Domain Name of the Service Provider.

[TOC](#table-of-contents)

## Configure the environment

1.  Become ROOT:

    ``` text
    sudo su -
    ```

2.  Be sure that your firewall **is not blocking** the traffic on port **443** and **80** for the SP server.

3.  Set the SP hostname:

    **!!!ATTENTION!!!**: Replace `sp.example.org` with your SP Full Qualified Domain Name and `<HOSTNAME>` with the SP hostname

    -   ``` text
        echo "<YOUR-SERVER-IP-ADDRESS> filesender.example.org <HOSTNAME>" >> /etc/hosts
        ```

    -   ``` text
        hostnamectl set-hostname <HOSTNAME>

[TOC](#table-of-contents)

## Configure APT Mirror

Debian Mirror List: <https://www.debian.org/mirror/list>

Ubuntu Mirror List: <https://launchpad.net/ubuntu/+archivemirrors>

Example with the Consortium GARR italian mirrors:

1.  Become ROOT:

    ``` text
    sudo su -
    ```

2.  Change the default mirror:

    -   Debian 12 - Deb822 file format:

        ``` text
        bash -c 'cat > /etc/apt/sources.list.d/garr.sources <<EOF
        Types: deb deb-src
        URIs: https://debian.mirror.garr.it/debian/
        Suites: bookworm bookworm-updates bookworm-backports
        Components: main

        Types: deb deb-src
        URIs: https://debian.mirror.garr.it/debian-security/
        Suites: bookworm-security
        Components: main
        EOF'
        ```

    -   Ubuntu:

        ``` text
        bash -c 'cat > /etc/apt/sources.list.d/garr.list <<EOF
        deb https://ubuntu.mirror.garr.it/ubuntu/ jammy main
        deb-src https://ubuntu.mirror.garr.it/ubuntu/ jammy main
        EOF'
        ```

3.  Update packages:

    ``` text
    apt update && apt-get upgrade -y --no-install-recommends
    ```

[TOC](#table-of-contents)

## Install Shibboleth Service Provider

``` text
https://github.com/GEANT/edugain-training/blob/main/UbuntuNet-Training-202401/tutorials/HOWTO-Install-and-Configure-a-Shibboleth-SP-v3-on-Debian-based-Linux-Distribution.md
```

and connect it to your IdP with:
``` text
https://github.com/GEANT/edugain-training/blob/main/UbuntuNet-Training-202401/tutorials/HOWTO-Install-and-Configure-a-Shibboleth-SP-v3-on-Debian-based-Linux-Distribution.md#connect-a-service-provider-directly-to-an-identity-provider
```

[TOC](#table-of-contents)

## Install Dependencies

``` text
sudo apt install php php-mbstring php-xml php-json libapache2-mod-php git
```
[TOC](#table-of-contents)

## Install MySQL server

``` text
sudo apt install default-mysql-server php-mysql
```
[TOC](#table-of-contents)

### Improve MySQL Installation Security:
```text
sudo mysql_secure_installation
```
- VALIDATE PASSWORD COMPONENT: N
- Remove anonymous users? Y
- Disallow root login remotely? Y
- Remove test database and access to it? Y
- Reload privilege tables now? Y

[TOC](#table-of-contents)

### Create FileSender Database

``` text
sudo mysql
```

``` text
> CREATE DATABASE filesender_db DEFAULT CHARACTER SET utf8mb4;
> CREATE USER "fs_db_user"@"localhost" IDENTIFIED BY "<PASSWORD>";
> GRANT ALL PRIVILEGES ON filesender_db.* TO "fs_db_user"@"localhost";
> quit
```

[TOC](#table-of-contents)

### Install FileSender 

``` text
sudo git clone --depth 1 --branch master https://github.com/filesender/filesender.git /opt/filesender    
```

``` text
cd /opt/filesender
mkdir -p tmp files log
touch config/config.php
chmod o-rwx tmp files log config/config.php
```

[TOC](#table-of-contents)

### Configure FileSender   

See the /opt/filesender/config/config_sample.php to understand changes done below:

``` text
bash -c "cat > /opt/filesender/config/config.php <<EOF
<?php

\\$config['site_url'] = 'https://$(hostname -f)/';

\\$config['admin'] = 'root@localhost.localdomain';
\\$config['admin_email'] = 'root@localhost.localdomain';

\\$config['email_reply_to'] = '';

\\$config['db_type'] ='mysql';
\\$config['db_host'] ='localhost';
\\$config['db_database'] ='filesender_db';
\\$config['db_username'] ='fs_db_user';
\\$config['db_password'] ='fs_db_pw';
\\$config['db_username_admin'] = 'fs_db_user';
\\$config['db_password_admin'] = 'fs_db_pw';

\\$config['auth_sp_type'] = 'shibboleth';
\\$config['auth_sp_shibboleth_email_attribute'] = 'mail';
\\$config['auth_sp_shibboleth_name_attribute'] = 'cn';
\\$config['auth_sp_shibboleth_uid_attribute'] = 'persistent-id';
\\$config['auth_sp_shibboleth_login_url'] = '/Shibboleth.sso/Login?return={target}';
\\$config['auth_sp_shibboleth_logout_url'] = '/Shibboleth.sso/Logout?return={target}';

\\$config['terasender_enabled'] = true;
\\$config['terasender_advanced'] = true;
\\$config['terasender_worker_count'] = 5;
\\$config['terasender_start_mode'] = 'single';

\\$config['storage_type'] = 'filesystem';
\\$config['storage_filesystem_path'] = '/opt/filesender/files';
EOF"
```

``` text
sudo chown www-data /opt/filesender/log /opt/filesender/files /opt/filesender/config/config.php
```

[TOC](#table-of-contents)

## Initialise FileSender database

``` text
cd /opt/filesender/config ; php /opt/filesender/scripts/upgrade/database.php
```
## Configure FileSender Cron

``` text
cp /opt/filesender/config-templates/cron/filesender /etc/cron.daily/filesender
chmod +x /etc/cron.daily/filesender
```

## Configure Apache

``` text
a2enmod alias headers ssl
```
``` text
bash -c 'cat > /etc/apache2/conf-available/filesender.conf <<EOF
     <Directory "/opt/filesender">
        Header always append X-Frame-Options SAMEORIGIN
        Header always edit Set-Cookie "^((?!csrfptoken).)+$" "\$0; HttpOnly"
        Header always edit Set-Cookie (.*) "\$1; SameSite=Strict "
        Header always set Strict-Transport-Security "max-age=63072000; includeSubDomains"

        Options SymLinksIfOwnerMatch
        Options -Indexes
        AllowOverride None
        Require all granted
     </Directory>

     <Location />
        Header always append X-Frame-Options SAMEORIGIN
        Header always edit Set-Cookie (.*) "\$1; SameSite=Strict"

        Authtype shibboleth
        ShibUseHeaders Off
        ShibExportAssertion On
        ShibRequestSetting requireSession false
        require shibboleth
     </Location>
EOF'
```

Replace the DocumentRoot with the correct one:

``` text
sed -i 's|DocumentRoot .*|DocumentRoot /opt/filesender/www|' /etc/apache2/sites-enabled/$(hostname -f).conf
```

``` text
chown -R www-data /opt/filesender/www
```

Enable FileSender Apache conf:

``` text
a2enconf filesender
```
``` text
systemctl restart apache2 
```

[TOC](#table-of-contents)



### Configure PHP

Ubuntu:

``` text
sudo cp /opt/filesender/config-templates/filesender-php.ini /etc/php/8.1/apache2/conf.d
```

``` text 
systemctl restart apache2.service
```


REFERENCES:

Please refer to 
https://docs.filesender.org/filesender/v2.0/install/

and to the HowTo mentioned above by Marco Malavolti for the Shib SP



    

