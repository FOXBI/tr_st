# tr_est
Tinycore Redpill Esxi config Support Tool

# VMWare ESXi Setting
SATA Contoller 0:0 -> Tinycore Disk Image<br>
SATA Controller 1:0 -> DATA Disk Iamge

# Howto Run

1. Download attached file on your PC (tr_est.tar)

2. Upload file to your Tinycore for redpill (by sftp....)

3. Connect to ssh by tc account.

4. Switch user to root:

   > sudo su
   
   (not required input password)

5. Check Directory location

   > pwd<br>
   > /home/tc

6. Decompress file & check file:

   > tar xvf tr_est.tar<br>
   > ls -lrt
   > chmod 755 tr_est.sh

   (check root’s run auth)

7. Run to Source file

   > ./tr_est.sh (Moldelname<br>

   eg. ./tr_est.sh DS3622xs+
 
8. When you execute it, proceed according to the description that is output.

9. After reboot you install DSM keep going


# Reference URL

https://github.com/pocopico/tinycore-redpill


# Reference Screeshot

![image](https://user-images.githubusercontent.com/42568682/158012257-db57387d-0cc3-4610-814a-a00e2c596677.png)
