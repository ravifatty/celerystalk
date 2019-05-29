#!/usr/bin/env bash

DISTRO=`grep "^ID=" /etc/os-release | cut -d\= -f2`

if [[ $EUID -ne 0 ]]; then
   echo " [!]This script must be run as root" 1>&2
   exit 1
fi

if [ ! -f ../config.ini ]; then
    cp config_default.ini ../config.ini
fi

# https://stackoverflow.com/questions/4023830/how-to-compare-two-strings-in-dot-separated-version-format-in-bash
verlte() {
    [  "$1" = "`echo -e "$1\n$2" | sort -V | head -n1`" ]
}

verlt() {
    [ "$1" = "$2" ] && return 1 || verlte $1 $2
}


echo ""
echo "**************************************"
echo "*      Updating apt sources          *"
echo "**************************************"
echo ""

apt update -y

echo ""
echo "*************************************************"
echo "*  Installing redis-server, gobuster, seclists, *"
echo "*  chromium python3-pip, wpscan, jq             *"
echo "*************************************************"
echo ""
if [ "$DISTRO" == "kali" ]; then
    apt install gobuster nikto cewl whatweb sqlmap nmap sslscan sslyze hydra medusa dnsrecon enum4linux ncrack crowbar onesixtyone smbclient redis-server seclists chromium python3-pip wpscan jq -y
elif [ "$DISTRO" == "ubuntu" ]; then
    apt install python-pip python3-pip unzip redis-server chromium jq -y
fi






CELERYSTALK_DIR=`pwd`

echo ""
echo "**************************************"
echo "*      Starting redis-server          *"
echo "**************************************"
echo ""
/etc/init.d/redis-server start

echo ""
echo "******************************************"
echo "* Installing python requirements via pip *"
echo "******************************************"
echo ""
pip install -r requirements.txt --upgrade


#if [ ! -f /usr/bin/geckodriver ]; then
#    echo ""
#    echo "**************************************"
#    echo "*    Installing geckodriver          *"
#    echo "**************************************"
#    echo ""
#    #From: https://github.com/FortyNorthSecurity/EyeWitness/blob/master/setup/setup.sh
#    MACHINE_TYPE=`uname -m`
#    if [ ${MACHINE_TYPE} == 'x86_64' ]; then
#      wget https://github.com/mozilla/geckodriver/releases/download/v0.22.0/geckodriver-v0.22.0-linux64.tar.gz
#      tar -xvf geckodriver-v0.22.0-linux64.tar.gz
#      rm geckodriver-v0.22.0-linux64.tar.gz
#      mv geckodriver /usr/sbin
#      ln -s /usr/sbin/geckodriver /usr/bin/geckodriver
#    else
#      wget https://github.com/mozilla/geckodriver/releases/download/v0.22.0/geckodriver-v0.22.0-linux32.tar.gz
#      tar -xvf geckodriver-v0.22.0-linux32.tar.gz
#      rm geckodriver-v0.22.0-linux64.tar.gz
#      mv geckodriver /usr/sbin
#      ln -s /usr/sbin/geckodriver /usr/bin/geckodriver
#    fi
#
#
#    # https://gist.github.com/cgoldberg/4097efbfeb40adf698a7d05e75e0ff51#file-geckodriver-install-sh
#    install_dir="/usr/bin"
#    json=$(curl -s https://api.github.com/repos/mozilla/geckodriver/releases/latest)
#    if [[ $(uname) == "Linux" ]]; then
#        url=$(echo "$json" | jq -r '.assets[].browser_download_url | select(contains("linux64"))')
#        echo $url
#    else
#        echo "can't determine OS"
#        exit 1
#    fi
#    curl -s -L "$url" | tar -xz
#    chmod +x geckodriver
#    mv geckodriver "$install_dir"
#    echo "installed geckodriver binary in $install_dir"
#fi


if [ ! -f /opt/amass/amass ]; then
    echo ""
    echo "****************************************"
    echo "* Installing Amass to /opt/amass/amass *"
    echo "****************************************"
    echo ""
    mkdir -p /opt/amass
    wget https://github.com/OWASP/Amass/releases/download/v2.5.0/amass_2.5.2_linux_386.zip -O /opt/amass/amass_2.5.2_linux_386.zip
    unzip /opt/amass/amass_2.5.2_linux_386.zip -d /opt/amass
fi


if [ ! -f /opt/aquatone/aquatone ]; then
    echo ""
    echo "*******************************************************"
    echo "* Installing Aquatone to /opt/aquatone/aquatone       *"
    echo "*******************************************************"
    echo ""
    echo "[+] Downloading Aquatone to /opt/aquatone/aquatone"
    mkdir -p /opt/aquatone
    wget https://github.com/michenriksen/aquatone/releases/download/v1.7.0/aquatone_linux_amd64_1.7.0.zip -O /opt/aquatone/aquatone_linux_amd64_1.7.0.zip
    unzip -o /opt/aquatone/aquatone_linux_amd64_1.7.0.zip -d /opt/aquatone
else
    CURRENT_VERSION=`/opt/aquatone/aquatone -version | cut -dv -f2`
    DESIRED_MINIMUM_VERSION="1.7.0"
    IS_LESS_THAN_DESIRED=`verlt $CURRENT_VERSION $DESIRED_MINIMUM_VERSION`

    if [ $? == "0" ]; then
        echo ""
        echo "**********************************************"
        echo "*           Updating Aquatone                *"
        echo "**********************************************"
        echo ""
        cd /opt/aquatone
        wget https://github.com/michenriksen/aquatone/releases/download/v1.7.0/aquatone_linux_amd64_1.7.0.zip -O /opt/aquatone/aquatone_linux_amd64_1.7.0.zip
        unzip -o /opt/aquatone/aquatone_linux_amd64_1.7.0.zip -d /opt/aquatone
    fi
fi


if [ ! -f /opt/Sublist3r/sublist3r.py ]; then
    echo ""
    echo "*******************************************************"
    echo "* Installing sublist3r to /opt/Sublist3r/sublist3r.py *"
    echo "*******************************************************"
    echo ""

    cd /opt/
    git clone https://github.com/aboul3la/Sublist3r.git
    cd Sublist3r/
    pip install -r requirements.txt
else
    echo ""
    echo "**********************************************"
    echo "*           Updating sublist3r               *"
    echo "**********************************************"
    echo ""
    cd /opt/Sublist3r/
    git pull
    pip install -r requirements.txt
fi

if [ ! -f /opt/Photon/photon.py ]; then
    echo ""
    echo "**********************************************"
    echo "* Installing Photon to /opt/Photon/photon.py *"
    echo "**********************************************"
    echo ""
    cd /opt/
    git clone https://github.com/s0md3v/Photon.git
    cd Photon
    pip3 install -r requirements.txt
else
    echo ""
    echo "**********************************************"
    echo "*           Updating Photon                  *"
    echo "**********************************************"
    echo ""
    cd /opt/Photon
    git pull
    pip install -r requirements.txt
fi

#if [ ! -f /opt/CMSmap/cmsmap.py ]; then
#    echo ""
#    echo "**********************************************"
#    echo "* Installing CMSmap to /opt/CMSmap/cmsmap.py *"
#    echo "**********************************************"
#    echo ""
#    cd /opt/
#    git clone https://github.com/Dionach/CMSmap.git
#    cd CMSmap
#    pip3 install .
#    echo "y" | cmsmap -U P
#else
#    echo ""
#    echo "**********************************************"
#    echo "*           Updating CMSmap                  *"
#    echo "**********************************************"
#    echo ""
#    cd /opt/CMSmap
#    git pull
#    pip3 install .
#    echo "y" | cmsmap -U P
#fi

cd $CELERYSTALK_DIR
cp bash_completion_file /etc/bash_completion.d/celerystalk.sh
cd .. && ./celerystalk -h
echo ""
echo "[+] Back up a directory and you are ready to go."
echo "[+]"
echo "[+] To use the fancy bash completion right away, copy/paste the following (you'll only need to do this once):"
echo "[+]   . /etc/bash_completion.d/celerystalk.sh"