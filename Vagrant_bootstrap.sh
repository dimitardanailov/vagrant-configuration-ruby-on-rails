# Application Setup
echo "Application name: $1"

sudo apt-get update
sudo apt-get install -y git

echo "Installing node.js"
# https://www.digitalocean.com/community/tutorials/how-to-install-node-js-with-nvm-node-version-manager-on-a-vps
sudo curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.29.0/install.sh | bash
source ~/.bashrc
nvm install 0.12.7
nvm use v0.12.7
# Set node to be global
n=$(which node);n=${n%/bin/node}; chmod -R 755 $n/bin/*; sudo cp -r $n/{bin,lib,share} /usr/local
which node

echo "Installing ruby with rbenv"
# https://cbednarski.com/articles/installing-ruby/
sudo apt-get install -y libssl-dev zlib1g-dev libreadline-dev

# https://github.com/welaika/jenkins-vagrant/blob/master/provision.sh
sudo -u vagrant git clone git://github.com/sstephenson/rbenv.git /home/vagrant/.rbenv
sudo -u vagrant echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> /home/vagrant/.profile
sudo -u vagrant echo 'eval "$(rbenv init -)"' >> /home/vagrant/.profile
sudo -u vagrant git clone git://github.com/sstephenson/ruby-build.git /home/vagrant/.rbenv/plugins/ruby-build

# no rdoc for installed gems
sudo -u vagrant echo 'gem: --no-ri --no-rdoc' >> /home/vagrant/.gemrc

# install required ruby versions
sudo -u vagrant -i rbenv install 2.1.5
sudo -u vagrant -i rbenv global 2.1.5
sudo -u vagrant -i ruby -v
sudo -u vagrant -i gem install bundler --no-ri --no-rdoc
sudo -u vagrant -i rbenv rehash

echo "Installing Postgresql"
# Create the file /etc/apt/sources.list.d/pgdg.list, and add a line for the repository
rm /etc/apt/sources.list.d/pgdg.list
echo 'deb http://apt.postgresql.org/pub/repos/apt/ wheezy-pgdg main' > /etc/apt/sources.list.d/pgdg.list
echo 'Content: /etc/apt/sources.list.d/pgdg.list'
cat /etc/apt/sources.list.d/pgdg.list

# Import the repository signing key, and update the package lists
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
sudo apt-get -y update

sudo apt-get install -y postgresql-9.4 postgresql-client-9.4 libpq-dev postgresql-server-dev-9.4 postgresql-contrib-9.4
psql --version

echo 'Restart postgresql'
sudo /etc/init.d/postgresql restart

echo "Installing nginx..."
sudo apt-get install -y nginx

echo "Making necessary links..."
# Remove default nginx file.
sudo rm /etc/nginx/sites-enabled/default 
sudo ln -s /vagrant/config/nginx.conf /etc/nginx/sites-enabled/$1.conf

echo "Copying configuration..."
sudo service nginx restart

echo 'Setup project'
cd /vagrant/

sudo -u vagrant -i rbenv global 2.1.5
sudo -u vagrant -i rbenv rehash
sudo -u vagrant -i ruby -v

# Create necessary folders and give us necessary permissions
sudo mkdir tmp/cache/
sudo mkdir tmp/pids/
sudo chmod 777 -R /vagrant/log/
sudo chmod 777 -R /vagrant/tmp/

# install gems
sudo bundle install --without development test

# Run migrations for production database
# If you have any problems with database check this resource: 
# http://stackoverflow.com/questions/18664074/getting-error-peer-authentication-failed-for-user-postgres-when-trying-to-ge/29517454#29517454
# rake db:migrate RAILS_ENV=production

# Unicorn Setup
chmod +x /vagrant/config/unicorn-init.sh
sudo ln -s /vagrant/config/unicorn-init.sh /etc/init.d/$1
sudo /etc/init.d/$1 stop
sudo /etc/init.d/$1 start
