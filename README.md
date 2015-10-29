# Example project with setup of Vagrant and Ruby on Rails

### Vagrant setup

##### Generate rails secret key

```bash
vagrant ssh
cd /vagrant/
chmod +x config/config/generate_secret_code.sh
./config/config/generate_secret_code.sh

printenv | grep SECRET_KEY_BASE
```

##### Amazon

We use [vagrant-aws](https://github.com/mitchellh/vagrant-aws)

```bash
vagrant plugin install vagrant-aws

vagrant up --provider=aws
```
