# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure('2') do |config|
  # Box
  config.vm.box = 'bento/ubuntu-20.04'

  # Network
  config.vm.network 'private_network', ip: '192.168.33.10'
  config.vm.network 'forwarded_port', guest: 3000, host: 3000

  # Provision
  config.vm.provision 'shell', inline: <<-SHELL
    apt update
    apt install -y ruby ruby-dev libsqlite3-dev imagemagick ffmpeg firefox libxslt1-dev zlib1g-dev build-essential linux-headers-$(uname -r)
    git clone https://github.com/umlaeute/v4l2loopback.git /v4l2loopback
    cd /v4l2loopback
    make KCPPFLAGS="-DMAX_DEVICES=64"
    make install-all
    depmod -a
    modprobe v4l2loopback devices=0

    for i in `seq 0 63`; do
      v4l2loopback-ctl add -n "video$i" /dev/video$i
      v4l2loopback-ctl set-caps /dev/video$i "YU12:1280x720"
      ffmpeg -i /vagrant/public/assets/img/aika.jpg -f v4l2 -vcodec rawvideo -vf format=pix_fmts=yuv420p /dev/video$i > /dev/null 2>&1
    done

    echo "vagrant ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/vagrant
    usermod -aG video vagrant
    gem install bundler
    wget https://github.com/mozilla/geckodriver/releases/download/v0.28.0/geckodriver-v0.28.0-linux64.tar.gz
    tar xvf geckodriver-v0.28.0-linux64.tar.gz
    chmod 755 geckodriver
    mv geckodriver /usr/bin
    rm geckodriver-v0.28.0-linux64.tar.gz
    cd /vagrant
    bundle config set system 'true'
    bundle install --without production
    echo 'cd /vagrant' >> /home/vagrant/.bashrc
    echo 'export PORT=3000' >> /home/vagrant/.bashrc
    echo "export RUBYOPT='-W:no-deprecated -W:no-experimental'" >> /home/vagrant/.bashrc
  SHELL
end
