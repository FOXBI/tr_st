#!/bin/bash
ver="1.3.5-r01"
#
# Made by FOXBI
# 2022.03.28
#
# ==============================================================================
# Y or N Function
# ==============================================================================
READ_YN () { # $1:question $2:default
   read -n1 -p "$1" Y_N
    case "$Y_N" in
    y) Y_N="y"
         echo -e "\n" ;;
    n) Y_N="n"
         echo -e "\n" ;;        
    q) echo -e "\n"
       exit 0 ;;
    *) echo -e "\n" ;;
    esac
}
# ==============================================================================
# Color Function
# ==============================================================================
cecho() {
    if [ -n "$3" ]
    then
        case "$3" in
            black  | bk) bgcolor="40";;
            red    |  r) bgcolor="41";;
            green  |  g) bgcolor="42";;
            yellow |  y) bgcolor="43";;
            blue   |  b) bgcolor="44";;
            purple |  p) bgcolor="45";;
            cyan   |  c) bgcolor="46";;
            gray   | gr) bgcolor="47";;
        esac        
    else
        bgcolor="0"
    fi
    code="\033["
    case "$1" in
        black  | bk) color="${code}${bgcolor};30m";;
        red    |  r) color="${code}${bgcolor};31m";;
        green  |  g) color="${code}${bgcolor};32m";;
        yellow |  y) color="${code}${bgcolor};33m";;
        blue   |  b) color="${code}${bgcolor};34m";;
        purple |  p) color="${code}${bgcolor};35m";;
        cyan   |  c) color="${code}${bgcolor};36m";;
        gray   | gr) color="${code}${bgcolor};37m";;
    esac

    text="$color$2${code}0m"
    echo -e "$text"
}
# ==============================================================================
# Process Function
# ==============================================================================
clear
CURDIR=`pwd`
if [ "$CURDIR" != "/home/tc" ]
then
    cd /home/tc
    CURDIR=`pwd`
fi
echo ""
cecho c "Tinycore Rploader Support Tool ver. \033[0;31m"$ver"\033[00m - FOXBI"
echo ""
$CURDIR/rploader.sh update now
echo ""
cecho c "Redpill Clean repository ..."
echo ""
$CURDIR/rploader.sh clean now
echo ""
# ==============================================================================
# Model Name Select
# ==============================================================================
echo -e "\033[0;31mDo you want to install using the old method?\033[00m" | tr '\n' ' '
READ_YN "Y/N : "
OLDCHK=$Y_N
if [ "$OLDCHK" == "Y" ] || [ "$OLDCHK" == "y" ]
then
    SYNOCHK=y
elif [ "$OLDCHK" == "N" ] || [ "$OLDCHK" == "n" ]
then
    SYNOCHK=`nslookup archive.synology.com 2>&1 > /dev/null`
else
    echo ""
    echo "Wrong choice. please run again..."
    echo ""    
    exit 0
fi
ACNT=
BCNT=
ARRAY=()
BRRAY=()
if [ "$SYNOCHK" == "" ]
then
    cecho c "Select Xpenology Model...\033[0;31m(Available Model Red Color)\033[00m"
    export ACHK=`curl --no-progress-meter https://archive.synology.com/download/Os/DSM | grep noreferrer | awk -Fner\"\> '{print $2}'| egrep -vi "download|os|Parent" | sed "s/<\/a>//g" | egrep "^7" | head -1`
    while IFS= read -r LINE_A;
    do
        ACNT=$(($ACNT + 1))
        BCNT=$(($ACNT%5))
        BRRAY=( `cat $CURDIR/rploader.sh | grep "Available Models" | awk -F: '{print $2}' | sed 's/\\\"//g' | sed 's/^\s//g'` )
        if [ "$BCNT" -eq "0" ]
        then
            if [[ "${BRRAY[@]}" =~ "$LINE_A" ]]
            then
                ARRAY+=("\033[0;31m$ACNT) $LINE_A\ln\033[00m");
            else
                ARRAY+=("$ACNT) $LINE_A\ln");
            fi
        else
            if [[ "${BRRAY[@]}" =~ "$LINE_A" ]]
            then
                ARRAY+=("\033[0;31m$ACNT) $LINE_A\lt\033[00m");
            else
                ARRAY+=("$ACNT) $LINE_A\lt");
            fi
        fi
    done < <(curl --no-progress-meter https://archive.synology.com/download/Os/DSM/$ACHK | grep noreferrer | awk -Fner\"\> '{print $2}'| grep "synology_" | sed "s/.pat<\/a>//g" | sed "s/synology_//g" | awk -F_ '{print $2}' | sort -u \
            | awk '{ if($0 ~ "^[0-9]") {print "DS"$0} else { if($0 ~ "^[a-z]") { print $0 } } }' \
            | sed "s/^rs/RS/g" | sed "s/^fs/FS/g" | sed "s/^ds/DS/g" | sed "s/^dva/DVA/g" | sed "s/^rc/RC/g" | sed "s/sa/SA/g" | sed "s/rpxs/RPxs/g" )
else
    if [ "$SYNOCHK" != "" ] && [ "$SYNOCHK" != "y" ]
    then
        cecho c "synology.com is not connected, proceeding the old method..."
        echo ""
    fi
    cecho c "Select Xpenology Model..."
    while read LINE_A;
    do
        ACNT=$(($ACNT + 1))
        BCNT=$(($ACNT%5))
        if [ "$BCNT" -eq "0" ]
        then
            ARRAY+=("$ACNT) $LINE_A\ln");
        else
            ARRAY+=("$ACNT) $LINE_A\lt");
        fi
    done < <(cat $CURDIR/rploader.sh | grep "Available Models" | awk -F: '{print $2}' | sed "s/\"//g" | sed "s/^\s//g" | sed "s/\s/\\n/g")
fi
echo ""
echo -e " ${ARRAY[@]}" | sed 's/\\ln/\n/g' | sed 's/\\lt/\t/g'
read -n3 -p " -> Select Number Enter : " A_O
echo ""
A_O=$(($A_O - 1))
for (( i = 0; i < $ACNT; i++)); do
    if [ "$A_O" == $i ]
    then
        export AMODEL=`echo "${ARRAY[$i]}" | sed 's/\\\ln/ /g' | sed 's/\\\lt/ /g' | awk '{print $2}'`
    fi
done   
# ==============================================================================
# DSM Model Select
# ==============================================================================
echo ""
cecho c "Select $AMODEL's DSM version..."
echo ""
CCNT=
DCNT=
CRRAY=()
if [ "$SYNOCHK" == "" ]
then
    while read LINE_B;
    do
        CCNT=$(($CCNT + 1))
        DCNT=$(($CCNT%5))
        if [ "$BCNT" -eq "0" ]
        then
            CRRAY+=("$CCNT) $LINE_B\ln");
        else
            CRRAY+=("$CCNT) $LINE_B\lt");
        fi
    done < <(curl --no-progress-meter https://archive.synology.com/download/Os/DSM | grep noreferrer | awk -Fner\"\> '{print $2}'| egrep -vi "download|os|Parent" | sed "s/<\/a>//g" | egrep "^7|^6.2.4" | awk -F- '{print $1"-"$2}' | sort -u)
    echo ""
    echo -e " ${CRRAY[@]}" | sed 's/\\ln/\n/g' | sed 's/\\lt/\t/g'
    read -n1 -p " -> Select Number Enter : " C_O
    echo ""
    C_O=$(($C_O - 1))
    for (( i = 0; i < $ACNT; i++)); do
        if [ "$C_O" == $i ]
        then
            export CVERSION=`echo "${CRRAY[$i]}" | sed 's/\\\ln/ /g' | sed 's/\\\lt/ /g' | awk '{print $2}'`
        fi
    done
else
    echo ""
    cecho c "DSM model selection proceeds after platform selection...."
    sleep 1
    echo ""
fi
# ==============================================================================
# Platform Select
# ==============================================================================
if [ ! -d $CURDIR/redpill-load ]
then
    if [ "$SYNOCHK" == "" ]
    then
        echo ""
        cecho c "Aouto Select Platform...."
        if [[ "$AMODEL" =~ ^"DS" ]]
        then
            BMODEL=`echo $AMODEL | cut -c 3- | tr '[A-Z]' '[a-z]'`
            BMODEL=`echo "_"$BMODEL"\."`
        else
            BMODEL=`echo $AMODEL | tr '[A-Z]' '[a-z]'`
            BMODEL=`echo $BMODEL"\."`
        fi
        ECHK=`echo $ACHK | awk -F- '{print $1"-"$2}'`

        EPLAT=`curl --no-progress-meter https://archive.synology.com/download/Os/DSM/$ACHK | grep noreferrer | awk -Fner\"\> '{print $2}'| grep "synology_" | sed "s/pat<\/a>//g" | sed "s/synology_//g" | grep -i "$BMODEL" | awk -F_ '{print $1}' | sed "s/$.//g"`
        EVERSION=`echo $EPLAT"-"$ECHK`

        echo ""
        cecho c "rploader update..."
        echo ""
        $CURDIR/rploader.sh download $EVERSION 2>&1 > /dev/null

        if [ $? -eq 99 ]
        then
            echo ""
            echo "$AMODEL is not supported, please run again"
            echo ""
            exit 0
        fi    
    else
        ECNT=
        FCNT=
        ERRAY=()
        echo ""
        cecho c "Select Platform...."
        while read LINE_E;
        do
            ECNT=$(($ECNT + 1))
            FCNT=$(($ECNT%3))
            if [ "$FCNT" -eq "0" ]
            then
                ERRAY+=("$ECNT) $LINE_E\ln");
            else
                ERRAY+=("$ECNT) $LINE_E\lt");
            fi
        done < <($CURDIR/rploader.sh | grep - | grep -v ^- | grep -v rploader)
        echo ""
        echo -e " ${ERRAY[@]}" | sed 's/\\ln/\n/g' | sed 's/\\lt/\t/g'
        read -n3 -p " -> Select Number Enter : " E_O
        echo ""
        E_O=$(($E_O - 1))
        for (( i = 0; i < $ECNT; i++)); do
            if [ "$E_O" == $i ]
            then
                export EVERSION=`echo "${ERRAY[$i]}" | sed 's/\\\ln//g' | sed 's/\\\lt//g' | awk '{print $2}'`
            fi
        done

        echo ""
        cecho c "rploader update..."
        echo ""
        $CURDIR/rploader.sh download $EVERSION 2>&1 > /dev/null

        CCHECK=`ls $CURDIR/redpill-load/config/$AMODEL | wc -l`
        CCNT=
        DCNT=
        CRRAY=()
        while read LINE_C;
        do
            CCNT=$(($CCNT + 1))
            DCNT=$(($CCNT%3))
            if [ "$DCNT" -eq "0" ]
            then
                CRRAY+=("$CCNT) $LINE_C\ln");
            else
                CRRAY+=("$CCNT) $LINE_C\lt");
            fi
        done < <(ls -l $CURDIR/redpill-load/config/$AMODEL | grep -v total | awk '{print $9}')

        if [ "$CCHECK" -gt "1" ]
        then
            echo ""
            cecho c "Slect again $AMODEL detail version..."
            echo ""
            echo -e " ${CRRAY[@]}" | sed 's/\\ln/\n/g' | sed 's/\\lt/\t/g'
            read -n1 -p " -> Select Number Enter : " C_O
            echo ""
            C_O=$(($C_O - 1))
            for (( i = 0; i < $CCNT; i++)); do
                if [ "$C_O" == $i ]
                then
                    export CVERSION=`echo "${CRRAY[$i]}" | sed 's/\\\ln//g' | sed 's/\\\lt//g' | awk '{print $2}'`
                fi
            done
        else
            CVERSION=`ls $CURDIR/redpill-load/config/$AMODEL`
        fi
    fi 
else
    echo ""
    echo "Empty redpil-load directory. please run again..."
    echo ""    
    exit 0
fi
# ==============================================================================
# Backup & GRUB Patch
# ==============================================================================
if [ -f "$CURDIR/redpill-load/config/$AMODEL/$CVERSION/config.json" ]
then
    echo ""
    cecho c "Backup Original File...."
    GTIME=`date +%Y%m%d%H%M%S`
    mkdir -p $CURDIR/ESXi_backup
    tar cvfP  $CURDIR/ESXi_backup/${AMODEL}_${GTIME}.tar $CURDIR/redpill-load/config/$AMODEL/$CVERSION/config.json $CURDIR/rploader.sh > /dev/null 2>&1
    sleep 1
    echo ""
    cecho c "Change Config File....."
    GCNT=`fdisk -l /dev/sda | grep fd | wc -l`
    HCNT=`fdisk -l | grep "*" | grep sda1 | wc -l`

    if [ "$GCNT" -eq "2" ] || [ "$HCNT" -eq "0" ]
    then
        grep -r "hd0,msdos" --exclude=\*.img --exclude=\*.tar ./ | egrep "latestrploader.sh|rploader.sh|$AMODEL" | grep -v "tr_st" | awk -F: '{ print "sed -i \"s\/hd0,msdos\/hd1,msdos\/g\" "$1 }' | sh
    else
        grep -r "hd1,msdos" --exclude=\*.img --exclude=\*.tar ./ | egrep "latestrploader.sh|rploader.sh|$AMODEL" | grep -v "tr_st" | awk -F: '{ print "sed -i \"s\/hd1,msdos\/hd0,msdos\/g\" "$1 }' | sh
    fi
    sleep 2
    echo ""
    cecho c "Change Boot Squence...."
    GCHECK1=`cat -n $CURDIR/redpill-load/config/$AMODEL/$CVERSION/config.json | grep "loglevel" | head -1 | awk '{print $1}'`
    GCHECK2=`cat -n $CURDIR/redpill-load/config/$AMODEL/$CVERSION/config.json | grep "loglevel" | tail -1 | awk '{print $1}'`
    HCHECK1=`cat -n $CURDIR/redpill-load/config/$AMODEL/$CVERSION/config.json | grep "log_buf_len" | head -1 | awk '{print $1}'`
    HCHECK2=`cat -n $CURDIR/redpill-load/config/$AMODEL/$CVERSION/config.json | grep "log_buf_len" | tail -1 | awk '{print $1}'`

    SCHECK1=`cat -n $CURDIR/redpill-load/config/$AMODEL/$CVERSION/config.json | grep "SATA" | head -1 | awk '{print $1}'`
    UCHECK1=`cat -n $CURDIR/redpill-load/config/$AMODEL/$CVERSION/config.json | grep "USB" | head -1 | awk '{print $1}'`

    RCHECKG=$(($HCHECK1 - $GCHECK1))
    RCHECKH=$(($HCHECK2 - $GCHECK2))

    if [ "$SCHECK1" -gt "$UCHECK1" ]
    then
        if [ "$RCHECKH" -gt "$RCHECKG" ]
        then
            sed -i "s/SATA/SATA1/g" $CURDIR/redpill-load/config/$AMODEL/$CVERSION/config.json
            sed -i "s/USB/SATA/g" $CURDIR/redpill-load/config/$AMODEL/$CVERSION/config.json
            sed -i "s/SATA1/USB/g" $CURDIR/redpill-load/config/$AMODEL/$CVERSION/config.json

            BCHECKN=$(($HCHECK2 - 1))
            sed -i "${BCHECKN}d" $CURDIR/redpill-load/config/$AMODEL/$CVERSION/config.json
            
            ACHECKN=$(($GCHECK1 + 1))
            sed -i "${ACHECKN} i\                    \"synoboot_satadom\": 1," $CURDIR/redpill-load/config/$AMODEL/$CVERSION/config.json
        fi
    fi
else
    echo ""
    echo "$AMODEL is not supported, please run again"
    echo ""
    exit 0
fi
sleep 2
echo ""
cecho c "Completed !! Run to rploader.sh !!"
sleep 1
# ==============================================================================
# Clear extension & install extension driver
# ==============================================================================
echo ""
cecho c "Delete extension file..."
rm -rf $CURDIR/redpill-load/custom/extensions/*
echo ""
cecho r "Add to Driver Repository..."
echo ""
READ_YN "Do you want Add Driver? Y/N :  "
ICHK=$Y_N
while [ "$ICHK" == "y" ] || [ "$ICHK" == "Y" ]
do
    ICNT=
    JCNT=
    IRRAY=()
    while read LINE_I;
    do
        ICNT=$(($ICNT + 1))
        JCNT=$(($ICNT%5))
        if [ "$JCNT" -eq "0" ]
        then
            IRRAY+=("$ICNT) $LINE_I\ln");
        else
            IRRAY+=("$ICNT) $LINE_I\lt");
        fi
    done < <(curl --no-progress-meter https://github.com/pocopico/rp-ext | grep "raw.githubusercontent.com" | awk '{print $2}' | awk -F= '{print $2}' | sed "s/\"//g" | awk -F/ '{print $7}')
        echo ""
        echo -e " ${IRRAY[@]}" | sed 's/\\ln/\n/g' | sed 's/\\lt/\t/g'
        echo ""
        read -n3 -p " -> Select Number Enter : " I_O
        echo ""
        I_O=$(($I_O - 1))
        for (( i = 0; i < $ICNT; i++)); do
            if [ "$I_O" == $i ]
            then
                export IEXT=`echo "${IRRAY[$i]}" | sed 's/\\\ln//g' | sed 's/\\\lt//g' | awk '{print $2}'`
            fi
        done
    $CURDIR/rploader.sh ext $EVERSION add https://raw.githubusercontent.com/pocopico/rp-ext/master/$IEXT/rpext-index.json
    echo ""
    READ_YN "Do you want add driver? Y/N :  "
    ICHK=$Y_N
done
echo ""
# ==============================================================================
# Build to boot image by rploader
# ==============================================================================
cecho r "Select N/n newer version exists on the repo !!"
echo ""
cecho r "Select N/n newer version exists on the repo !!"
echo ""
cecho r "Select N/n newer version exists on the repo !!"
echo ""
sleep 2
$CURDIR/rploader.sh build $EVERSION
echo ""
# ==============================================================================
# Backup configuration
# ==============================================================================
cecho c "Backup Config file"
echo ""
$CURDIR/rploader.sh backup now 
echo ""
cecho c "Completed !! After reboot Install DSM."
echo ""
# ==============================================================================
# Reboot
# ==============================================================================
READ_YN "Do you want reboot ? Y/N : "
KCHECK=$Y_N
if [ "$KCHECK" == "y" ] || [ "$KCHECK" == "Y" ]
then
    echo ""
    cecho r "Now System Reboot !!"
    cecho r "3"
    sleep 1
    cecho r "2"
    sleep 1
    cecho r "1"
    sleep 1
    reboot
fi
# ==============================================================================
# End
# ==============================================================================
