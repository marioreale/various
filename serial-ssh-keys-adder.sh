#!/bin/bash
#
#assuming you are using ssh-ageant and do not need to type in each time your private key password to login on the remote VMs
# eval $(ssh-agent)
# ssh-add ./id_rsa  
#
# assuming the list of IPs of the VMs is stored on a local file called list-of-IPs-VMs-students
#
 let i=3
 for line in `cat list-of-IPs-VMs-students`
   do 
  let i=i+1
   echo "working on VM n. $i whose IP address is" $line
    echo 
    ssh root@$line "echo 'ssh-ed25519 <YOUR ELLIPTIC KEY HERE>  <YOUR EMAIL ADDRESS HERE>' >> ~/.ssh/authorized_keys"

    ssh root@$line "echo 'ssh-rsa <YOUR RSA KEY HERE>  <YOUR EMAIL ADDRESS HERE>' >> ~/.ssh/authorized_keys"
  
  echo "added the 2 keys on VM n. $i"
  echo
  echo "##################################################################################"

 done
