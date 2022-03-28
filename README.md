# Requirement
=============================================================<br>
VM SATA Controller Config

# Case1. New Create VM

    Create SATA controller 2ea

    SATA Controller 0:0 -> DATA Disk Iamge
    SATA Controller 1:0 -> Tinycore Disk Image
![image](https://user-images.githubusercontent.com/42568682/158375978-cea33a04-4292-4d4c-abd9-8d531b203721.png)


# Case2. Already Use VM

    Add to SATA Controller 1ea

AS-IS<br>
 SATA Controller 0 (0:0) -> Tinycore Disk Image <br>
 SATA Controller 0 (0:1) -> DATA Disk Iamge<br>	 
TO-BE <br>
 SATA Controller 0 (0:0) -> DATA Disk Iamge<br>
 SATA Controller 1 (1:0) -> Tinycore Disk Image<br> 
 
 Change to Bios Boot Squence<br>
![image](https://user-images.githubusercontent.com/42568682/158376024-af59cd26-688c-462e-b7fb-64ab2e681568.png)


# Case3. Use VMWare Paravirtual

   Create SATA Controller 1ea, SCIS Controller 1ea

    SATA Controller 0:0 -> Tinycore Disk Image<br>
    SCSI Controller 0:0 -> DATA Disk Iamge<br>
![image](https://user-images.githubusercontent.com/42568682/158376093-1d02a323-0cc0-4ff2-9e70-8a20ce026605.png)

After setting to all case an error occurs when entering Tinycore.<br>
![image](https://user-images.githubusercontent.com/42568682/158376130-2505c4b3-adce-4975-a7dc-a41f993154fb.png)<Br>
enter 'e' Edit GRUB menu <br>
change  ![image](https://user-images.githubusercontent.com/42568682/158376183-90f7b886-50ca-4df9-abe1-a694070497a5.png) to ![image](https://user-images.githubusercontent.com/42568682/158376227-cfb222f8-05fd-45b0-8259-af824b170caa.png)<br>
enter 'F10' Continue Tinycore booting.


If you set up VM like this and proceed, Data Disk will be defined as drive 1 in the DSM storage later. (In case of SCSI, define from drive 2)

made a video of the config process. 

[![tr_st](http://img.youtube.com/vi/6MyYtv1X52g/0.jpg)](https://youtu.be/6MyYtv1X52g) 


# Howto Run
=============================================================
 

1. Download attached file on your PC (tr_st.tar)

    or See the source page on github -> http://github.com/FOXBI/tr_st
 

2. Start up your Tinycore and upload it. (using sftp....)

    Alternatively, you can paste the source directly from the shell.
 

3. Connect to ssh by tc account.
 

4. Switch user to root:

   sudo su 

   (No password required)
 

5. Edit user_config.json

    Serial, MAC, Sataportmap, diskidxmap etc...

    recommand value..

Only use SATA<br>
    "SataPortMap": "9",<br>
    "DiskIdxMap": "0"

Use SATA + SCSI<br>
    "SasIdxMap": "0",<br>
    "SataPortMap": "1",<br>
    "DiskIdxMap": "0"

 
6. Check Directory location

   pwd
   /home/tc
 

7. Decompress file & check file:

   tar xvf tr_st.tar
   ls -lrt 
   chmod 755 tr_st.sh

   (check root’s run auth)

 
8. Run to Source file

   ./tr_st.sh


When you execute it, proceed according to the description that is output.

After reboot you install DSM keep going
   
Follow the instructions to install (DS3622xs+ example)

made a video of the setup process.
   
[![tr_st](http://img.youtube.com/vi/yRTcdOK6-Ok/0.jpg)](https://youtu.be/yRTcdOK6-Ok) 
   
