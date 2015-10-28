== README

### Vagrant setup

##### Generate rails secret key

```bash
vagrant ssh
cd /vagrant/
chmod +x config/config/generate_secret_code.sh
./config/config/generate_secret_code.sh

printenv | grep SECRET_KEY_BASE
```