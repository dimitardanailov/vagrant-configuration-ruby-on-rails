#!/bin/bash

cd /vagrant/
GENERATED_CODE="$( bash <<EOF
RAILS_ENV=production rake secret
EOF
)"
echo "$GENERATED_CODE"

sudo -u vagrant echo "export SECRET_KEY_BASE=$GENERATED_CODE" >> /home/vagrant/.profile

source /home/vagrant/.profile

printenv | grep SECRET_KEY_BASE

my_application="my_application"
sudo /etc/init.d/$my_application stop
sudo /etc/init.d/$my_application start