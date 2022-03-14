# tr_st
Tinycore Redpill Support Tool

# VMWare ESXi Setting
SATA Controller 0:0 -> DATA Disk Iamge<br>
SATA Controller 1:0 -> Tinycore Disk Image


# Howto Run

1. Download attached file on your PC (tr_st.tar)

2. Upload file to your Tinycore for redpill (by sftp....)

3. Connect to ssh by tc account.

4. Switch user to root:

   > sudo su
   
   (not required input password)

5. Check Directory location

   > pwd<br>
   > /home/tc

6. Decompress file & check file:

   > tar xvf tr_st.tar<br>
   > ls -lrt
   > chmod 755 tr_st.sh

   (check root’s run auth)

7. Run to Source file

   > ./tr_st.sh <br>
 
8. When you execute it, proceed according to the description that is output.

9. After reboot you install DSM keep going


# Reference URL

https://github.com/pocopico/tinycore-redpill


# Reference Screeshot


