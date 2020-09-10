#!/bin/bash
dpkg --configure -a
apt-get -y update

# install Apache2
apt-get -y install apache2

# write some HTML
echo \<center\>\<h1\>Hello From Demo App\</h1\>\<br/\>\</center\> > /var/www/html/index.html

# restart Apache
apachectl restart
