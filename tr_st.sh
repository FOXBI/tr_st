#!/bin/bash
ver="0.9.9-r01"
#
# Made by FOXBI
# 2022.03.15
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
MCNT=
cecho c "Select Xpenology Model..."
while read LINE_M;
do
    MCNT=$(($MCNT + 1))
    M_LIST=`echo -e $M_LIST $MCNT\) $LINE_M \z`
    export ML_LIST$MCNT=$LINE_M
done < <(cat $CURDIR/rploader.sh | grep "Available Models" | awk -F: '{print $2}' | sed "s/\"//g" | sed "s/^\s//g" | sed "s/\s/\\n/g")
echo ""
echo " "$M_LIST | sed 's/z/\n/g'
read -n3 -p " -> Select Number Enter : " M_O
for (( i = 1; i <= $MCNT; i++)); do
    if [ "$M_O" == $i ]
    then
        export CMODEL=`echo $(eval echo \\$ML_LIST${i})`
    fi
done

if [ ! -d $CURDIR/redpill-load ]
then
    VCNT=
    echo ""
    echo ""
    cecho c "Select Platform...."
    while read LINE_V;
    do
        VCNT=$(($VCNT + 1))
        V_LIST=`echo -e $V_LIST $VCNT\) $LINE_V \z`
        export VL_LIST$VCNT=$LINE_V
    done < <($CURDIR/rploader.sh | grep - | grep -v ^- | grep -v rploader)
    echo ""
    echo " "$V_LIST | sed 's/z/\n/g'
    read -n3 -p " -> Select Number Enter : " V_O
    for (( i = 1; i <= $VCNT; i++)); do
        if [ "$V_O" == $i ]
        then
            export SVERSION=`echo $(eval echo \\$VL_LIST${i})`
        fi
    done
    echo ""
    cecho c "rploader update..."
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
    cecho c "Slect again $CMODEL detail version..."
    echo ""
    echo " "$D_LIST
    echo ""
    read -n1 -p " -> Select Number : " S_O
    echo ""
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
cecho c "Backup Original File...."
mkdir -p $CURDIR/ESXi_backup
tar cvfP  $CURDIR/ESXi_backup/$CMODEL.tar $CURDIR/redpill-load/config/$CMODEL/$CVERSION/config.json $CURDIR/rploader.sh > /dev/null 2>&1
sleep 1
echo ""

cecho c "Change Config File....."
CNT_DK=`fdisk -l /dev/sda | grep fd | wc -l`
CNT_TC=`fdisk -l | grep "*" | grep sda1 | wc -l`

if [ "$CNT_DK" -eq "2" ] || [ "$CNT_TC" -eq "0" ]
then
    grep -r "hd0,msdos" --exclude=\*.img --exclude=\*.tar ./ | egrep "latestrploader.sh|rploader.sh|$CMODEL" | grep -v "tr_st" | awk -F: '{ print "sed -i \"s\/hd0,msdos\/hd1,msdos\/g\" "$1 }' | sh
else
    grep -r "hd1,msdos" --exclude=\*.img --exclude=\*.tar ./ | egrep "latestrploader.sh|rploader.sh|$CMODEL" | grep -v "tr_st" | awk -F: '{ print "sed -i \"s\/hd1,msdos\/hd0,msdos\/g\" "$1 }' | sh
fi
sleep 2
echo ""

cecho c "Change Boot Squence...."
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
cecho c "Delete extension file..."
rm -rf $CURDIR/redpill-load/custom/extensions/*
echo ""
cecho c "Completed !! Run to rploader.sh !!"
sleep 1
echo ""
cecho r "Add to Driver Repository..."
echo ""
READ_YN "Do you want Add Driver? Y/N :  "
echo ""
EPCHK=$Y_N
while [ "$EPCHK" == "y" ] || [ "$EPCHK" == "Y" ]
do
    ECNT=
    while read LINE_E;
    do
            ECNT=$(($ECNT + 1))
            E_LIST=`echo -e $E_LIST $ECNT\) $LINE_E \z`
            export EL_LIST$ECNT=$LINE_E
    done < <(curl --no-progress-meter https://github.com/pocopico/rp-ext | grep "raw.githubusercontent.com" | awk '{print $2}' | awk -F= '{print $2}' | sed "s/\"//g" | awk -F/ '{print $7}')
        echo ""
        echo " "$E_LIST | sed 's/z/\n/g'
        read -n3 -p " -> Select Number Enter : " E_O
        for (( i = 1; i <= $ECNT; i++)); do
            if [ "$E_O" == $i ]
            then
                export EPEXT=`echo $(eval echo \\$EL_LIST${i})`
            fi
        done
    $CURDIR/rploader.sh ext $SVERSION add https://raw.githubusercontent.com/pocopico/rp-ext/master/$EPEXT/rpext-index.json
    echo ""
    READ_YN "Do you want add driver? Y/N :  "
    EPCHK=$Y_N
done
cecho r "Select N/n newer version exists on the repo !!"
echo ""
cecho r "Select N/n newer version exists on the repo !!"
echo ""
cecho r "Select N/n newer version exists on the repo !!"
echo ""
sleep 2
$CURDIR/rploader.sh build $SVERSION
echo ""
cecho c "Backup Config file"
echo ""
$CURDIR/rploader.sh backup now 
echo ""
cecho c "Completed !! After reboot Install DSM."
echo ""
READ_YN "Do you want reboot ? Y/N : "
RCHECK=$Y_N
if [ "$RCHECK" == "y" ] || [ "$RCHECK" == "Y" ]
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
