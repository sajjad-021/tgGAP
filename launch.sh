#!/bin/bash

THIS_DIR=$(cd $(dirname $0); pwd)
cd $THIS_DIR

bot_config() {
  mkdir -p "$THIS_DIR"/data/telegram-cli
  printf '%s\n' "
default_profile = \"default\";

default = {
  config_directory = \"$THIS_DIR/data/telegram-cli\";
  auth_file = \"$THIS_DIR/data/telegram-cli/auth\";
  test = false;
  msg_num = true;
  log_level = 2;
};
" > "$THIS_DIR"/data/bot/bot.config
}
install_luarocks() {
 echo -e "\e[38;5;142mInstalling LuaRocks\e"
  git clone https://github.com/keplerproject/luarocks.git
  cd luarocks
  git checkout tags/v2.4.2 # Current stable

  PREFIX="$THIS_DIR/.luarocks"

  ./configure --prefix=$PREFIX --sysconfdir=$PREFIX/luarocks --force-config
   make build && make install
cd ..
  rm -rf luarocks
}

install_rocks() {
echo -e "\e[38;5;105mInstall rocks service\e"
rocks="luasocket luasec redis-lua lua-term serpent dkjson Lua-cURL multipart-post lanes xml fakeredis luaexpat luasec lbase64 luafilesystem lub lua-cjson feedparser serpent"
    for rock in $rocks; do
      ./.luarocks/bin/luarocks install $rock
    done
}
  
tg() {
echo -e "\e[38;5;099minstall telegram-cli\e"
    rm -rf ../.telegram-cli
    wget https://valtman.name/files/telegram-cli-1222
    mv telegram-cli-1222 tg
    chmod 777 tg
}
  
install2() {
echo -e "\e[38;5;034mInstalling more dependencies\e"
    sudo apt-get install screen -y
    sudo apt-get install tmux -y
    sudo apt-get install upstart -y
    sudo apt-get install libstdc++6 -y
    sudo apt-get install lua-lgi -y
    sudo apt-get install libnotify-dev -y
}

py() {
 sudo apt-get install python-setuptools python-dev build-essential 
 sudo easy_install pip
 sudo pip install redis
}

install() {
echo -e "\e[38;5;035mUpdating packages\e"
   sudo apt-get update -y
   sudo apt-get upgrade -y

echo -e "\\e[38;5;129mInstalling dependencies\e"
	sudo add-apt-repository -y ppa:ubuntu-toolchain-r/test
	sudo apt-get install g++-4.7 -y c++-4.7 -y
	sudo apt-get install libreadline-dev -y libconfig-dev -y libssl-dev -y lua5.2 -y liblua5.2-dev -y lua-socket -y lua-sec -y lua-expat -y libevent-dev -y make unzip git redis-server autoconf g++ -y libjansson-dev -y libpython-dev -y expat libexpat1-dev -y
install2
install_luarocks
install_rocks
py
tg
log
echo -e "\e[38;5;046mInstalling packages successfully\033[0;00m"
}


if [ "$1" = "install" ]; then
  install
else
COUNTER=0
  while [ $COUNTER -lt 5 ]; do
       tmux kill-session -t script
           tmux new-session -s script "./tg -s ./data/bot/bot.lua -l 1 -E -c ./data/bot/bot.config -p default "$@""
        tmux detach -s script
    sleep 1
  done
fi
