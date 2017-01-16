#!/bin/sh

echo "** shutting boot2docker down"
boot2docker down
echo "* deleting any existing boot2docker images"
boot2docker delete

echo "* quitting any running instances of VirutalBox"
osascript -e 'quit app "VirtualBox"'

DATA_DIR=/Users/Shared/data

echo "** deleting local user : jenkins"
sudo dscl . -delete "/Users/jenkins"
sudo rm /Users/jenkins

echo "** deleting directory : ~/src"
rm -rf ~/src
echo "** deleting virtual box image"
rm -rf ~/VirtualBox\ VMs/
echo "** deleting .boot2docker directory"
rm -rf ~/.boot2docker/
echo "** deleting .jenkins directory"
rm -rf ~/.jenkins/
echo "** deleting .subversion directory"
rm -rf ~/.subversion/
echo "** deleting .gemrc directory"
rm -rf ~/.gemrc
rm -rf ~/.CFUserTextEncoding
echo "** deleting homebrew-cast directory"
rm -rf /opt/homebrew-cask
echo "** deleting rubies directory"
rm -rf ~/rubies

echo "** nuking boxen install"
cd /opt/boxen/repo
./script/nuke --force --all
rm -rf /opt/boxen

cd ~
