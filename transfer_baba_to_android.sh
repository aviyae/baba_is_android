set -e

# for windows get adb from: https://developer.android.com/studio/releases/platform-tools and add it to PATH

echo "WARNING!"
echo "This script **will replace the save files of your phone** (hopefully by those on your PC)."
echo "You may want to backup the phone save files by running:"
echo "\$adb backup -noapk org.hempuli.baba"
echo "Maybe in the future we'll add an option to save a backup of your phone..."
echo "Until then, use it on your own risk :)"
echo ""
echo "do you want to continue? (y/N)"
read cont
if [[ "$cont" != [yY] ]]; then
	echo "exiting..."
	exit 1
fi

# on windows (WSL) change this to where %APPDATA% points
PATH_TO_APP_DATA=$HOME/.local/share

# install prerequisites
sudo apt install default-jre
sudo apt install pax
sudo apt install android-tools-adb

# create temp folder
TEMP_DIR=$(mktemp -d)
pushd $TEMP_DIR

# get backup file (ab file) from the device and use it as a template
### run the ADB commands on PS if you run this script on WSL and don't have ADB configured
### use -s option if some devices are attached
adb backup -noapk org.hempuli.baba
###

# convert ab file to tar file
wget https://github.com/nelenkov/android-backup-extractor/releases/download/20210609062341-4c55371/abe.jar
cp $PATH_TO_APP_DATA/Baba_Is_You/*ba.ba .
java -jar abe.jar unpack backup.ab backup.tar # give a password if needed

# open tar file and copy save files from PC to it
tar -xvf backup.tar
cp *.ba apps/org.hempuli.baba/f/

# change "baba" to "baba_m" in all the brackets in the save files
sed -E -i "s/(\[.*?)(baba)(.*?\])/\1baba_m\3/" apps/org.hempuli.baba/f/*ba.ba

# repack all the files together to a tar file (files order is important therefore the list)
cat << 'EOF' > p.list
apps/org.hempuli.baba/_manifest
apps/org.hempuli.baba/f/SettingsC.txt
apps/org.hempuli.baba/f/0ba.ba
apps/org.hempuli.baba/f/1ba.ba
apps/org.hempuli.baba/f/2ba.ba
apps/org.hempuli.baba/f/ba.ba
EOF
cat p.list | pax -wd > backup_new.tar

# and convert to ab file format
java -jar abe.jar pack backup_new.tar backup_new.ab

# restore data to phone - THIS IS THE PART WHERE YOUR DATA IS OVERRIDDEN
### run the ADB commands on PS if you run this script on WSL and don't have ADB configured
### use -s option if some devices are attached
# we don't use a password here - enter empty password in the phone if requested
adb restore ./backup_new.ab
###

# clean and return the system to previous state
popd
rm -rf $TEMP_DIR
