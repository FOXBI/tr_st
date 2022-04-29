#!/bin/bash
ver="2.9.0-r01"
#
# Made by FOXBI
# 2022.04.29
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
cecho () {
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
# Extension Driver Function
# ==============================================================================
EXDRIVER_FN () {
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
            read -n100 -p " -> Select Number Enter (To select multiple, separate them with , ): " I_O
            echo ""
            I_OCHK=`echo $I_O | grep , | wc -l`
            if [ "$I_OCHK" -gt "0" ]
            then
                while read LINE_J;
                do
                    j=$((LINE_J - 1))
                    IEXT=`echo "${IRRAY[$j]}" | sed 's/\\\ln//g' | sed 's/\\\lt//g' | awk '{print $2}'`
                    $CURDIR/rploader.sh ext $EVERSION add https://raw.githubusercontent.com/pocopico/rp-ext/master/$IEXT/rpext-index.json
                done < <(echo $I_O | tr ',' '\n')
            else
                I_O=$(($I_O - 1))
                for (( i = 0; i < $ICNT; i++)); do
                    if [ "$I_O" == $i ]
                    then
                        export IEXT=`echo "${IRRAY[$i]}" | sed 's/\\\ln//g' | sed 's/\\\lt//g' | awk '{print $2}'`
                    fi
                done
                $CURDIR/rploader.sh ext $EVERSION add https://raw.githubusercontent.com/pocopico/rp-ext/master/$IEXT/rpext-index.json
            fi
        echo ""
        READ_YN "Do you want add driver? Y/N :  "
        ICHK=$Y_N
    done
}
# ==============================================================================
# Pat Download Function 7.1-42661-1
# ==============================================================================
PATDL_FN () {
    TCHK=`sudo fdisk -l | grep -A 3 "*" | grep "sd.3" | awk '{print "df | grep "$1}' | sh | awk '{print $NF}'`
    mkdir -p $TCHK/auxfiles
    cd $TCHK/auxfiles
    DLMODEL=`echo $AMODEL | sed "s/\+/\%2B/g"`
    TPMODEL=`echo $AMODEL | sed "s/\+/p/g" | tr '[A-Z]' '[a-z]'`
    TVERSION=`echo $EVERSION | awk -F- '{print $NF}'`

    echo ""    
    cecho r "Pat file pre-download...($TCHK/auxfiles/${TPMODEL}_${TVERSION}.pat)"
    echo ""
    curl -o ${TPMODEL}_${TVERSION}.pat https://global.download.synology.com/download/DSM/release/7.1/${TVERSION}-1/DSM_${DLMODEL}_${TVERSION}.pat
    cd $CURDIR
    echo ""
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
echo -e "\033[0;31mDo you want to install \033[0;33m 7.1 \033[0;31m ?\033[00m" | tr '\n' ' '
READ_YN "Y/N : "
ACHK=$Y_N
if [ "$ACHK" == "Y" ] || [ "$ACHK" == "y" ]
then
    MGCHK=n
    DSMCHK=`sudo fdisk -l | grep fd | wc -l`
    if [ "$DSMCHK" -ge "2" ]
    then
        echo -e "\033[0;31mDSM installed detect!! \033[0;33m Continue Process...\033[00m"
        echo ""
        sleep 2
        MGCHK=n
    fi
    NEWCHK=y
elif [ "$ACHK" == "N" ] || [ "$ACHK" == "n" ]
then
    NEWCHK=n
else
    echo ""
    echo "Wrong choice. please run again..."
    echo ""    
    exit 0
fi

if [ "$NEWCHK" == "n" ]
then
    echo -e "\033[0;31mDo you want to old method?\033[0;33m(if you want 7.1.0-42621 RC choose y)\033[00m" | tr '\n' ' '
    READ_YN "Y/N : "
    OLDCHK=$Y_N
    if [ "$OLDCHK" == "Y" ] || [ "$OLDCHK" == "y" ]
    then
        SYNOCHK=y
        echo -e "\033[0;31m7.1.0-42621 RC Update in progress ?\033[00m" | tr '\n' ' '
        READ_YN "Y/N : "
        RCCHK=$Y_N
        if [ "$RCCHK" == "Y" ] || [ "$RCCHK" == "y" ]
        then
            RCCHK=y
        elif [ "$RCCHK" == "N" ] || [ "$RCCHK" == "n" ]
        then
            RCCHK=n
        else
            echo ""
            echo "Wrong choice. please run again..."
            echo ""    
            exit 0
        fi
    elif [ "$OLDCHK" == "N" ] || [ "$OLDCHK" == "n" ]
    then
        SYNOCHK=`nslookup archive.synology.com 2>&1 > /dev/null`
        RCCHK=n
    else
        echo ""
        echo "Wrong choice. please run again..."
        echo ""    
        exit 0
    fi
fi

if [ "$RCCHK" == "y" ]
then
    cecho c "Redpill 7.1.0-42621 RC update in preparation ..."
    echo ""
    sudo rm -rf /mnt/sdb3/backup/*
    $CURDIR/rploader.sh backuploader now
    echo ""
else
    cecho c "Redpill update ..."
    echo ""
    sudo rm -rf /mnt/sdb3/backup/*
    $CURDIR/rploader.sh update now    
    if [ "$NEWCHK" == "y" ]
    then
        echo ""
        cecho c "Redpill fullupgrade for 7.1-42661 ..."
        echo ""
        sudo cp $CURDIR/user_config.json /tmp/user_config.json_bak
        $CURDIR/rploader.sh fullupgrade now
        sudo cp /tmp/user_config.json_bak $CURDIR/user_config.json 
    else
        cecho c "Redpill Clean repository ..."
        echo ""    
        $CURDIR/rploader.sh clean now
    fi
    echo ""
fi
# ==============================================================================
# Model Name Select
# ==============================================================================
ACNT=
BCNT=
ARRAY=()
BRRAY=()
if [ "$SYNOCHK" == "" ]
then
    cecho c "Select Xpenology Model...\033[0;31m(Available Model Red Color)\033[00m"
    export ACHK=`curl --no-progress-meter https://archive.synology.com/download/Os/DSM | grep noreferrer | awk -Fner\"\> '{print $2}'| egrep -vi "download|os|Parent" | sed "s/<\/a>//g" | egrep "^7" | head -3 \
                | awk -F- '{ if($3 ~ "^[0-9]") {print  $1"-"$2"-"$3} }' | head -1`
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
echo ""
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
    while read LINE_C;
    do
        if [[ "$LINE_C" =~ "42661" ]] && [ "$NEWCHK" == "n" ]
        then 
            continue
        else
            CCNT=$(($CCNT + 1))
            DCNT=$(($CCNT%5))
            if [ "$BCNT" -eq "0" ]
            then
                if [[ "$LINE_C" =~ "42661" ]] && [ "$NEWCHK" == "y" ]
                then
                    CRRAY+=("\033[0;31m$CCNT) $LINE_C\ln\033[00m");
                else
                    CRRAY+=("$CCNT) $LINE_C\ln");
                fi
            else
            if [[ "$LINE_C" =~ "42661" ]] && [ "$NEWCHK" == "y" ]
                then
                    CRRAY+=("\033[0;31m$CCNT) $LINE_C\lt\033[00m");
                else        
                    CRRAY+=("$CCNT) $LINE_C\lt");
                fi
            fi
        fi
    done < <(curl --no-progress-meter https://archive.synology.com/download/Os/DSM | grep noreferrer | awk -Fner\"\> '{print $2}'| egrep -vi "download|os|Parent" | sed "s/<\/a>//g" | egrep "^7|^6.2.4" | awk -F- '{print $1"-"$2}' | sort -u)
    echo ""
    echo -e " ${CRRAY[@]}" | sed 's/\\ln/\n/g' | sed 's/\\lt/\t/g'
    echo ""
    read -n1 -p " -> Select Number Enter : " C_O
    echo ""
    C_O=$(($C_O - 1))
    for (( i = 0; i < $CCNT; i++)); do
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
if [ ! -d $CURDIR/redpill-load ] || [ "$RCCHK" == "y" ] || [ "$NEWCHK" == "y" ]
then
    if [ "$SYNOCHK" == "" ]
    then
        echo ""
        cecho c "Auto Select Platform...."
        if [[ "$AMODEL" =~ ^"DS" ]]
        then
            BMODEL=`echo $AMODEL | cut -c 3- | tr '[A-Z]' '[a-z]'`
            BMODEL=`echo "_"$BMODEL"\."`
        else
            BMODEL=`echo $AMODEL | tr '[A-Z]' '[a-z]'`
            BMODEL=`echo $BMODEL"\."`
        fi
        ECHK=`curl --no-progress-meter https://archive.synology.com/download/Os/DSM | grep noreferrer | awk -Fner\"\> '{print $2}'| egrep -vi "download|os|Parent" | sed "s/<\/a>//g" | egrep "^7" | head -1 | awk -F- '{print $1"-"$2}'`
        FCHK=`echo $ACHK | awk -F- '{print $1"-"$2}'`
        if [ "$CVERSION" == "$FCHK" ]
        then
            ECHK=`echo $FCHK`
        else
            ECHK=`echo $ECHK`
        fi

        EPLAT=`curl --no-progress-meter https://archive.synology.com/download/Os/DSM/$ACHK | grep noreferrer | awk -Fner\"\> '{print $2}'| grep "synology_" | sed "s/pat<\/a>//g" | sed "s/synology_//g" | grep -i "$BMODEL" | awk -F_ '{print $1}' | sed "s/$.//g"`
        EVERSION=`echo $EPLAT"-"$ECHK | sed "s/7.1-/7.1.0-/g"`

        echo ""
        cecho c "Rploader update..."
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
            if [[ "$LINE_E" =~ "42661" ]] && [ "$NEWCHK" == "n" ]
            then
                continue
            elif [[ "$LINE_E" =~ "42621" ]] && [ "$RCCHK" == "n" ]
            then
                continue                
            else
                ECNT=$(($ECNT + 1))
                FCNT=$(($ECNT%3))            
                if [ "$FCNT" -eq "0" ]
                then
                    ERRAY+=("$ECNT) $LINE_E\ln");
                else
                    ERRAY+=("$ECNT) $LINE_E\lt");
                fi
            fi
        done < <($CURDIR/rploader.sh | grep - | grep -v ^- | grep -v rploader)
        echo ""
        echo -e " ${ERRAY[@]}" | sed 's/\\ln/\n/g' | sed 's/\\lt/\t/g'
        echo ""
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
            if [[ "$LINE_C" =~ "42661" ]] && [ "$NEWCHK" == "n" ]
            then
                continue
            elif [[ "$LINE_C" =~ "42621" ]] && [ "$RCCHK" == "n" ]
            then
                continue                
            elif [[ "$LINE_C" =~ "template" ]] 
            then
                continue
            else
                CCNT=$(($CCNT + 1))
                DCNT=$(($CCNT%3))            
                if [ "$DCNT" -eq "0" ]
                then
                    if [[ "$LINE_C" =~ "42621" ]] && [ "$RCCHK" == "y" ]
                    then
                        CRRAY+=("\033[0;31m$CCNT) $LINE_C\ln\033[00m");
                    elif [[ "$LINE_C" =~ "42661" ]] && [ "$NEWCHK" == "y" ]
                    then
                        CRRAY+=("\033[0;31m$CCNT) $LINE_C\ln\033[00m");                          
                    else
                        CRRAY+=("$CCNT) $LINE_C\ln");
                    fi
                else
                    if [[ "$LINE_C" =~ "42621" ]] && [ "$RCCHK" == "y" ]
                    then
                        CRRAY+=("\033[0;31m$CCNT) $LINE_C\lt\033[00m");
                    elif [[ "$LINE_C" =~ "42661" ]] && [ "$NEWCHK" == "y" ]
                    then
                        CRRAY+=("\033[0;31m$CCNT) $LINE_C\lt\033[00m");
                    else
                        CRRAY+=("$CCNT) $LINE_C\lt");
                    fi            
                fi
            fi
        done < <(ls -l $CURDIR/redpill-load/config/$AMODEL | grep -v total | awk '{print $9}')

        if [ "$CCHECK" -gt "1" ]
        then
            echo ""
            cecho c "Slect again $AMODEL detail version..."
            echo ""
            echo -e " ${CRRAY[@]}" | sed 's/\\ln/\n/g' | sed 's/\\lt/\t/g'
            echo ""
            read -n1 -p " -> Select Number Enter : " C_O
            echo ""
            C_O=$(($C_O - 1))
            for (( i = 0; i < $CCNT; i++)); do
                if [ "$C_O" == $i ]
                then
                    export CVERSION=`echo "${CRRAY[$i]}" | sed 's/\\\ln/ /g' | sed 's/\\\lt/ /g' | awk '{print $2}'`
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
echo ""
cecho c "Select $AMODEL($EVERSION) Completed !! Run to rploader.sh !!"
sleep 1
# ==============================================================================
# Clear extension & install extension driver
# ==============================================================================
echo ""
cecho c "Delete extension file..."
sudo rm -rf $CURDIR/redpill-load/custom/extensions/*
echo ""
cecho c "Update ext-manager..."
$CURDIR/redpill-load/ext-manager.sh update
if [ "$NEWCHK" == "n" ]
then
    EXDRIVER_FN
    echo ""
fi
# ==============================================================================
# Build Progress
# ==============================================================================
if [ "$RCCHK" == "y" ] && [ "$NEWCHK" == "n" ]
then
    if [ "$EVERSION" == "broadwellnk-7.0.1-42218" ]
    then
        $CURDIR/rploader.sh ext $EVERSION add https://github.com/jumkey/redpill-load/raw/develop/redpill-misc/rpext-index.json
    fi
    echo ""
    cecho y "Please select Y/n for both questions !!!"
    echo ""
    cecho y "Please select Y/n for both questions !!!"
    echo ""
    cecho y "Please select Y/n for both questions !!!"
    echo ""
    sleep 3
    $CURDIR/rploader.sh postupdate $EVERSION
    echo ""
elif [[ "$EVERSION" =~ "42661" ]] && [ "$NEWCHK" == "y" ]
then
    $CURDIR/rploader.sh clean now
    EXDRIVER_FN
    PATDL_FN
    $CURDIR/rploader.sh build $EVERSION
    $CURDIR/rploader.sh clean now
    rm -rf /mnt/sdb3/auxfiles
    rm -rf $CURDIR/custom-module
    echo ""
else
    sleep 2
    $CURDIR/rploader.sh build $EVERSION
    echo ""
fi
# ==============================================================================
# Backup & GRUB Patch
# ==============================================================================
UCHK=`lsblk -So NAME,TRAN | grep usb | awk '{print $1}'`
if [ "$UCHK" == "" ]
then
    PCHK=`sudo fdisk -l | grep "*" | grep "dev" | grep -v "img" | awk '{print $1}' | sed "s/\/dev\///g"`
else
    PCHK=`sudo fdisk -l | grep "*" | grep "dev" | grep -v "img" | grep -v "$UCHK" | awk '{print $1}' | sed "s/\/dev\///g"`
fi

if [ ! -d /mnt/$PCHK/boot/grub ]
then
    sudo mount /dev/$PCHK
fi
echo ""
cecho c "Backup Original File...."
GTIME=`date +%Y%m%d%H%M%S`
mkdir -p $CURDIR/ESXi_backup
tar cvfP  $CURDIR/ESXi_backup/${AMODEL}_${GTIME}.tar /mnt/$PCHK/boot/grub/grub.cfg > /dev/null 2>&1
sleep 1
echo ""
cecho c "Change Boot Config File....."
sleep 1
GCNT=`sudo fdisk -l /dev/sda | grep fd | wc -l`
HCNT=`sudo fdisk -l | grep "*" | grep sda1 | wc -l`

if [ "$GCNT" -eq "2" ] || [ "$HCNT" -eq "0" ]
then
    sudo sed -i "s/hd0,msdos/hd1,msdos/g" /mnt/$PCHK/boot/grub/grub.cfg
else
    sudo sed -i "s/hd1,msdos/hd0,msdos/g" /mnt/$PCHK/boot/grub/grub.cfg
fi
sleep 2
# ==============================================================================
# Extra Boot image or USB Create Action
# ==============================================================================
FNAME=`cat /mnt/$PCHK/boot/grub/grub.cfg | grep menuentry | head -1 | awk '{print $3"_"$4}'`
if [ "$FNAME" == "Core_Image" ]
then
    echo ""
    echo "The built bootloader does not exist. please run again after build..."
    echo ""    
    exit 0
else    
    echo ""
    cecho c "Extra Boot image or USB Create"
    echo ""
    READ_YN "Do you want Extra boot image create ? Y/N : "
    EXCHK=$Y_N
    MCHK="/mnt/tmp"
    if [ "$EXCHK" == "y" ] || [ "$EXCHK" == "Y" ]
    then
        echo ""
        cecho c "Now Select Create *.img or USB Create"
        echo ""    
        echo "1) ${FNAME}.img   2) ${FNAME} Boot USB Create"
        echo ""
        read -n2 -p " -> Select Number Enter : " X_O
        echo ""
        RCHK=`echo $PCHK | sed "s/[0-9].*$//g"`
        if [ "$X_O" == "1" ]
        then
            echo ""
            cecho c "Create /home/tc/${FNAME}.img"
            echo "" 
            sudo umount /dev/$PCHK > /dev/null 2>&1        
            sudo dd if=/dev/$RCHK of=/home/tc/${FNAME}.img count=292500 > /dev/null 2>&1

sudo fdisk /home/tc/${FNAME}.img > /dev/null 2>&1 << EOF
d
3

wq
EOF
sudo fdisk /home/tc/${FNAME}.img > /dev/null 2>&1 << EOF
n
p
3


n
wq
EOF
            sudo chown tc:staff /home/tc/${FNAME}.img

            echo ""
            cecho c "Config grub.cfg..."
            echo "" 
            sleep 1
            SCHK=`fdisk -l ${FNAME}.img | grep "*" | grep img | awk '{print $3}'`
            sudo mkdir -p $MCHK
            sudo mount -o loop,offset=$((512*$SCHK)) ${FNAME}.img $MCHK > /dev/null 2>&1  

            LNUM=`cat $MCHK/boot/grub/grub.cfg | grep -n "Tiny Core Image Build" | awk -F: '{print $1}'`
            if [ "$LNUM" != "" ]
            then
                sudo sed -i "$LNUM,\$d" $MCHK/boot/grub/grub.cfg
            fi
            sudo umount $MCHK > /dev/null 2>&1  

            echo ""
            cecho c "Create completed /home/tc/${FNAME}.img"
            echo "" 
            read -n1 -p "When the SFTP download is complete, press any key."
            echo ""
        elif [ "$X_O" == "2" ]
        then
            if [ "$UCHK" == "" ]
            then
                echo ""
                echo "Do not Ready USB...Check Please..."
                echo ""    
            else
                echo ""
                cecho c "Create $FNAME Bootable USB(/dev/$UCHK) - Takes a few minutes..."
                echo "" 
                sudo umount /dev/$PCHK > /dev/null 2>&1   
                sudo dd if=/dev/$RCHK of=/dev/$UCHK count=292500 > /dev/null 2>&1

sudo fdisk /dev/$UCHK > /dev/null 2>&1 << EOF
d
3

wq
EOF

sudo fdisk /dev/$UCHK > /dev/null 2>&1 << EOF
n
p
3


n
wq
EOF

                echo ""
                cecho c "Config grub.cfg..."
                echo "" 

                LCHK=`find /sys -name $UCHK | grep usb`
                cd $LCHK
                cd ../../../../../../
                PID=`cat idProduct`
                VID=`cat idVendor`
                sleep 1
                BCHK=`fdisk -l /dev/$UCHK | grep "*" | grep $UCHK | awk '{print $1}'`
                sudo mkdir -p $MCHK
                sudo mount $BCHK $MCHK

                LNUM=`cat $MCHK/boot/grub/grub.cfg | grep -n "Tiny Core Image Build" | awk -F: '{print $1}'`
                if [ "$LNUM" != "" ]
                then
                    sudo sed -i "$LNUM,\$d" $MCHK/boot/grub/grub.cfg
                fi

                sudo sed -i "s/pid=0x.... earlycon/pid=0x$PID earlycon/g" $MCHK/boot/grub/grub.cfg
                sudo sed -i "s/vid=0x.... elevator/vid=0x$VID elevator/g" $MCHK/boot/grub/grub.cfg
                sudo sed -i "s/default=\"1\"/default=\"0\"/g" $MCHK/boot/grub/grub.cfg
                sudo sed -i "s/hd1,msdos/hd0,msdos/g" $MCHK/boot/grub/grub.cfg
                sudo umount $MCHK > /dev/null 2>&1   

                echo ""
                cecho c "Create completed USB"
                echo "" 
                read -n1 -p "Proceed with DSM installation using USB. press any key."
                echo ""
            fi
        else
            echo ""
            echo "Wrong choice. please run again..."
            echo ""    
            exit 0    
        fi
    fi
fi
# ==============================================================================
# Backup configuration
# ==============================================================================
echo ""
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
    sudo reboot
fi
# ==============================================================================
# End
# ==============================================================================