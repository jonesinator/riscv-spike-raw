$buildscript = <<SCRIPT
apt-get update
apt-get install -y autoconf automake autotools-dev bc bison build-essential \
  curl device-tree-compiler flex gawk git gperf libgmp-dev libmpc-dev \
  libmpfr-dev libtool libusb-1.0-0-dev patchutils pkg-config texinfo zlib1g-dev
export RISCV=/usr/local
cd /home/vagrant
git clone --recursive https://github.com/riscv/riscv-tools.git
cd riscv-tools
./build-rv32ima.sh
chown -R vagrant:vagrant /home/vagrant
SCRIPT
Vagrant.configure("2") do |config|
  config.vm.box = "bento/debian-9.0"
  config.vm.provision "shell", inline: $buildscript
end
