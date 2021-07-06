set -e

#get adb from: https://developer.android.com/studio/releases/platform-tools and add it to PATH

# on windows (WSL) change this to where %APPDATA% points
PATH_TO_APP_DATA=$HOME/.local/share

sudo apt install default-jre
sudo apt install pax
TEMP_DIR=$(mktemp -d)
pushd $TEMP_DIR
### run the ADB commands on PS if you run this script on WSL and don't have ADB configured
### use -s option if some devices are attached
adb backup -noapk org.hempuli.baba
###
wget https://github.com/nelenkov/android-backup-extractor/releases/download/20210609062341-4c55371/abe.jar
cp $PATH_TO_APP_DATA/Baba_Is_You/*ba.ba .
java -jar abe.jar unpack backup.ab backup.tar # give a password if needed
cat << 'EOF' > p.list
apps/org.hempuli.baba/_manifest
apps/org.hempuli.baba/f/SettingsC.txt
apps/org.hempuli.baba/f/0ba.ba
apps/org.hempuli.baba/f/1ba.ba
apps/org.hempuli.baba/f/2ba.ba
apps/org.hempuli.baba/f/ba.ba
EOF
tar -xvf backup.tar
cp *.ba apps/org.hempuli.baba/f/
sed -E -i "s/(\[.*?)(baba)(.*?\])/\1baba_m\3/" apps/org.hempuli.baba/f/*ba.ba
cat p.list | pax -wd > backup_new.tar
java -jar abe.jar pack backup_new.tar backup_new.ab
### run the ADB commands on PS if you run this script on WSL and don't have ADB configured
### use -s option if some devices are attached
adb restore .\backup_new.ab
###
popd
rm -rf $TEMP_DIR
