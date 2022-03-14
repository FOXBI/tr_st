#!/bin/bash
ver="0.9.0-b01"
#
# Made by FOXBI
# 2022.03.12
#
# ver : 
CURDIR=`pwd`
echo ""
echo "For Tinycore rploader ESXi Disk Setting Support Tool"
echo ""
$CURDIR/rploader.sh update now
echo ""
echo "Redpill Clean repository ..."
$CURDIR/rploader.sh clean now
echo ""
if [ "$1" = "DS3615xs" ] || [ "$1" = "DS3617xs" ] || [ "$1" = "DS916+" ] || [ "$1" = "DS918+" ] || [ "$1" = "DS920+" ] || [ "$1" = "DS3622xs+" ] || [ "$1" = "FS6400" ] || [ "$1" = "DVA3219" ] || [ "$1" = "DVA3221" ] || [ "$1" = "DS1621+" ]
then
    CMODEL=$1

    if [ ! -d $CURDIR/redpill-load ]
    then
        VCNT=
        echo "Select Platform...."
        while read LINE_V;
        do
            VCNT=$(($VCNT + 1))
            V_LIST=`echo -e $V_LIST $VCNT\) $LINE_V \z`
            export VL_LIST$VCNT=$LINE_V
        done < <($CURDIR/rploader.sh | grep - | grep -v ^- | grep -v rploader)
        echo ""
        echo " "$V_LIST | sed 's/z/\n/g'
        read -n1 -p " -> select version : " V_O
        for (( i = 1; i <= $VCNT; i++)); do
            if [ "$V_O" == $i ]
            then
                export SVERSION=`echo $(eval echo \\$VL_LIST${i})`
            fi
        done
        echo ""
        echo "rploader update..."
        echo ""
        $CURDIR/rploader.sh download $SVERSION
    fi

    VCHECK=`ls $CURDIR/redpill-load/config/$CMODEL | wc -l`
    CNT=

    while read LINE_D;
    do
        CNT=$(($CNT + 1))
        D_LIST=`echo $D_LIST $CNT\) $LINE_D `
        export L_LIST$CNT=$LINE_D
    done < <(ls -l $CURDIR/redpill-load/config/$CMODEL | grep -v total | awk '{print $9}')

    if [ "$VCHECK" -gt "1" ]
    then
        echo ""
        echo "Slect again $CMODEL detail version"
        echo ""
        echo " "$D_LIST
        read -n1 -p " -> select number : " S_O
        for (( i = 1; i <= $CNT; i++)); do
            if [ "$S_O" == $i ]
            then
                CVERSION=`echo $(eval echo \\$L_LIST${i})`
            fi
        done
    else
        CVERSION=`ls $CURDIR/redpill-load/config/$CMODEL`
    fi

    echo ""
    echo "Backup Original File...."
    mkdir -p $CURDIR/ESXi_backup
    tar cvfP  $CURDIR/ESXi_backup/$CMODEL.tar $CURDIR/redpill-load/config/$CMODEL/$CVERSION/config.json $CURDIR/rploader.sh > /dev/null 2>&1
    sleep 1
    echo ""
    echo "Change Config File....."
    CNT_DK=`fdisk -l /dev/sda | grep fd | wc -l`

    if [ "$CNT_DK" -eq "2" ]
    then
        grep -r "hd0,msdos" --exclude=\*.img --exclude=\*.tar ./ | egrep "latestrploader.sh|rploader.sh|$CMODEL" | grep -v "tr_st" | awk -F: '{ print "sed -i \"s\/hd0,msdos\/hd1,msdos\/g\" "$1 }' | sh
    else
        grep -r "hd1,msdos" --exclude=\*.img --exclude=\*.tar ./ | egrep "latestrploader.sh|rploader.sh|$CMODEL" | grep -v "tr_st" | awk -F: '{ print "sed -i \"s\/hd1,msdos\/hd0,msdos\/g\" "$1 }' | sh
    fi
    sleep 2
    echo ""
    echo "Change Boot Squence...."
    ACHECK1=`cat -n $CURDIR/redpill-load/config/$CMODEL/$CVERSION/config.json | grep "loglevel" | head -1 | awk '{print $1}'`
    ACHECK2=`cat -n $CURDIR/redpill-load/config/$CMODEL/$CVERSION/config.json | grep "loglevel" | tail -1 | awk '{print $1}'`
    BCHECK1=`cat -n $CURDIR/redpill-load/config/$CMODEL/$CVERSION/config.json | grep "log_buf_len" | head -1 | awk '{print $1}'`
    BCHECK2=`cat -n $CURDIR/redpill-load/config/$CMODEL/$CVERSION/config.json | grep "log_buf_len" | tail -1 | awk '{print $1}'`

    SCHECK1=`cat -n $CURDIR/redpill-load/config/$CMODEL/$CVERSION/config.json | grep "SATA" | head -1 | awk '{print $1}'`
    UCHECK1=`cat -n $CURDIR/redpill-load/config/$CMODEL/$CVERSION/config.json | grep "USB" | head -1 | awk '{print $1}'`

    RCHECKA=$(($BCHECK1 - $ACHECK1))
    RCHECKB=$(($BCHECK2 - $ACHECK2))

    if [ "$SCHECK1" -gt "$UCHECK1" ]
    then
        if [ "$RCHECKB" -gt "$RCHECKA" ]
        then
            sed -i "s/SATA/SATA1/g" $CURDIR/redpill-load/config/$CMODEL/$CVERSION/config.json
            sed -i "s/USB/SATA/g" $CURDIR/redpill-load/config/$CMODEL/$CVERSION/config.json
            sed -i "s/SATA1/USB/g" $CURDIR/redpill-load/config/$CMODEL/$CVERSION/config.json

            BCHECKN=$(($BCHECK2 - 1))
            sed -i "${BCHECKN}d" $CURDIR/redpill-load/config/$CMODEL/$CVERSION/config.json
            
            ACHECKN=$(($ACHECK1 + 1))
            sed -i "${ACHECKN} i\                    \"synoboot_satadom\": 1," $CURDIR/redpill-load/config/$CMODEL/$CVERSION/config.json
        fi
    fi
    sleep 2
    echo ""
    echo "Delete extension file"
    rm -rf $CURDIR/redpill-load/custom/extensions/*
    echo ""
    echo "Completed !! Run to rploader.sh"
    sleep 1
    echo ""
    echo "Select N/n newer version exists on the repo !!"
    $CURDIR/rploader.sh build $SVERSION
    echo ""
    echo "Backup Config file"
    $CURDIR/rploader.sh backup now 
else
    echo "Available Models : DS3615xs DS3617xs DS916+ DS918+ DS920+ DS3622xs+ FS6400 DVA3219 DVA3221 DS1621+"
    exit 0
fi
