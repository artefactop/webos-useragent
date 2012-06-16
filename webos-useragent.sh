#!/bin/sh 
# Edited by Binglong to run from within Touchpad (sell does not like: elif, case, and empty lines) 
# Edited by Ncinerate to provide HULU support for the HP TouchPad, webOS 3.0.2 
# User Agent Spoofer for webOS devices (universal) 
# Copyright 2009-2010 Carl E. Thompson (devel-webos [at] carlthompson.net) 
# Much help from hofs1 and wtgreen at PreCentral.net . Thank you. 
PATCH_VERSION="2.5.2" 
# these must be the same length 
# these are for webOS 3.0.5 append version by jln 
OLD_UA_3_0_5='Mozilla/5.0 (%s; Linux; %s/%s; U; %s) AppleWebKit/534.6 (KHTML, like Gecko) %s/234.83 Safari/534.6 %s/%s' 
NEW_UA_3_0_5='Mozilla/5.0 (iPad; U; es-Es) AppleWebKit/534.6 (KHTML, like Gecko) wOSBrowser/234.83 Safari/534.6 011/07' 
# these are for webOS 3.0.2 
OLD_UA_3_0_2='Mozilla/5.0 (%s; Linux; %s/%s; U; %s) AppleWebKit/534.6 (KHTML, like Gecko) %s/234.40.1 Safari/534.6 %s/%s' 
NEW_UA_3_0_2='Mozilla/5.0 (Windows NT 5.1.1; U; en) AppleWebKit/535.2 (KHTML, like Gecko) xp/234.40.1 Safari/535.2 01/07' 
# these are for webOS 2.0 
OLD_UA_2_0='Mozilla/5.0 (webOS/%s; U; %s) AppleWebKit/532.2 (KHTML, like Gecko) Version/1.0 Safari/532.2 %s' 
NEW_UA_2_0='Mozilla/5.0 (iPhone; U; en)(webOS/%s; U; %s) AppleWebKit/532.2 Version/1.0 Safari/532.2 %s -CET' 
# these are for webOS 1.2 and 1.3 
OLD_UA_1_2='Mozilla/5.0 (webOS/%s; U; %s) AppleWebKit/525.27.1 (KHTML, like Gecko) Version/1.0 Safari/525.27.1 %s' 
NEW_UA_1_2='Mozilla/5.0 (iPhone; U; en)(webOS/%s; U; %s) AppleWebKit/525.27.1 Version/1.0 Safari/525.27.1 %s -CET' 
# these are for webOS 1.1 
OLD_UA_1_1='Mozilla/5.0 (webOS/1.1; U; %s) AppleWebKit/525.27.1 (KHTML, like Gecko) Version/1.0 Safari/525.27.1 Pre/1.0' 
NEW_UA_1_1='Mozilla/5.0 (iPhone; U; en)(webOS/1.1; U; %s) AppleWebKit/525.27.1 Version/1.0 Safari/525.27.1 Pre/1.0 -CET' 
WEBOS_VERSION=$(cat /etc/palm-build-info | sed -nre "s/^PRODUCT_VERSION_STRING\s*=\s*HP webOS\s*(.*)/\1/p") 
FILE="/usr/lib/libWebKitLuna.so" 
BACKUP_FILE="/usr/lib/libWebKitLuna.so-iphone_user_agent-${WEBOS_VERSION}.bak" 
TEMP_FILE="/tmp/libWebKitLuna.so-iphone_user_agent.patched" 
do_error() { while [ -n "$1" ]; do echo "ERROR: $1" >&2; shift; done; exit 1; } 
options() { echo "Available command line options: i, u, s, h"; } 
clear_browser_cookies() 
{ 
    cp -f /var/palm/data/browser-cookies.db . || do_error "Could not copy browser cookies database" 
    sqlite3 browser-cookies.db "delete from Cookies;" || do_error "Could not clear browser cookies" 
    mv -f browser-cookies.db /var/palm/data/browser-cookies.db || do_error "Could not update browser cookies database" 
} 
remove_all_backups() { rm -f /usr/lib/libWebKitLuna.so-iphone_user_agent*; } 
sedify() { echo "$1" | sed -e 's/\//\\\//g' -e 's/(/\\(/g' -e 's/)/\\)/g'; } 
do_patch() 
{ 
    if grep -Fq "$2" $FILE 
    then 
        echo "User agent already in desired state so no action appears necessary. Exiting." 
        exit 0 
    fi 
    grep -Fq "$1" $FILE || do_error "Could not find area to patch (unknown file version?)" 
    OLD=$(sedify "$1") 
    NEW=$(sedify "$2") 
    sed -re "s/$OLD/$NEW/" $FILE > $TEMP_FILE || do_error "Could not patch file" 
    mv -f $TEMP_FILE $FILE || do_error "Could not rename patched file to original name" 
} 
remount() { mount / -oremount,rw || do_error "Could not remount root filesystem read/write"; } 
echo 
echo "User Agent Spoofer version HULU for HP touchpad" 
echo "Copyright 2009 – 2010 Carl E. Thompson (devel-webos [at] carlthompson.net)" 
echo "Much help from hofs1 and wtgreen at PreCentral.net . Thank you." 
echo "Edited a hair by Ncinerate for Hulu compatibility" 
echo "Edited a hair by Binglong for running in TouchPad Xecutah/XServer/XTerm" 
echo "This program patches the web browser on the touchpad to enable Hulu and other websites" 
echo $0         — install the UA spoof patch 
echo $0 i       — install the UA spoof patch 
echo $0 u       — uninstall the UA spoof patch 
echo $0 r       — restore from initial backup 
echo $0 h       — print help message 
echo Installing the patch allows you to watch Hulu, check hotmail.com and so on. 
echo Uninstalling it to restore access to HP App Catalog 
echo Restoring it to revert to original setup 
echo 
echo 
echo Your WebOS Version: $WEBOS_VERSION 
echo 
[ -n "$WEBOS_VERSION" ] || do_error "This patch only runs on Palm webOS devices" 
# if this is webOS 1.2 or 1.3 
if echo "$WEBOS_VERSION" | grep -Eq "^1\.[23]($|[^0-9])" 
then 
    OLD_UA="$OLD_UA_1_2" 
    NEW_UA="$NEW_UA_1_2" 
fi 
# if this is webOS 1.1 
if echo "$WEBOS_VERSION" | grep -Eq "^1\.1($|[^0-9])" 
then 
    OLD_UA="$OLD_UA_1_1" 
    NEW_UA="$NEW_UA_1_1" 
fi 
# if this is webOS 2.0 
if echo "$WEBOS_VERSION" | grep -Eq "^2\.0($|[^0-9])" 
then 
    OLD_UA="$OLD_UA_2_0" 
    NEW_UA="$NEW_UA_2_0" 
fi 
# if this is webOS 3.0.5 
if echo "$WEBOS_VERSION" | grep -Eq "^3\.0\.5$" ;
then 
    OLD_UA=$OLD_UA_3_0_5 
    NEW_UA=$NEW_UA_3_0_5 
fi
echo "New user-agent: $NEW_UA"
# Make sure user agent strings are the same length 
 [ "${#OLD_UA}" = "${#NEW_UA}" ] || do_error "Old and new user agent strings are not the same length" 
 [ -n "$1" ] && OPT="$1" || OPT="i" 
OPT_RECOG="n"
if [ $OPT = "u" ] 
then 
    echo "Removing user agent spoof patch." 
    remount 
    do_patch "$NEW_UA" "$OLD_UA" 
    echo "Patch uninstalled." 
    remove_all_backups 
    OPT_RECOG="y" 
fi 
if [ $OPT = "i" ] 
then 
    echo "Applying user agent spoof patch." 
    remount 
    remove_all_backups 
    cp -f $FILE $BACKUP_FILE || do_error "Could not copy original file to backup" 
    do_patch "$OLD_UA" "$NEW_UA" 
    echo "Patch installed." 
    OPT_RECOG="y" 
fi        
if [ $OPT = "r" ] 
then 
    echo "Restoring library file from backup." 
    [ -r $BACKUP_FILE ] || do_error "Backup file for this version of webOS not found (not installed?)" 
    remount 
    mv -f $BACKUP_FILE $FILE || do_error "Restoring from backup failed" 
    remove_all_backups 
    echo "Patch restored." 
    OPT_RECOG="y" 
fi        
if [ $OPT = "c" ] 
then 
    echo "Clearing browser cookies only." 
    OPT_RECOG="y" 
fi 
if [ $OPT = "h" ]
then 
    options 
    exit 0 
    OPT_RECOG="y" 
fi 
if [ $OPT_RECOG = "n" ] 
then 
    do_error "Unknown option: $OPT" "$(options)" 
fi 
clear_browser_cookies 
echo "Browser cookies cleared." 
sync 
pkill -HUP BrowserServer$ 
echo "Browser Server reinitialized." 
echo "Done."


