#!/bin/bash

echo "Create directories"
sudo mkdir -p /data/opt
sudo mkdir -p /data/log
# sudo chmod -R g+w /data/log
# sudo chmod -R g+w /data/opt
# sudo mkdir -p /data/users

echo "Partition data disk sdc"
# sudo parted /dev/sdc --script mklabel gpt mkpart OPT xfs 0% 32GiB mkpart LOG xfs 32GiB 56GiB mkpart USERS xfs 56GiB 100%
sudo parted /dev/sdc --script mklabel gpt mkpart OPT xfs 0% 40GiB mkpart LOG xfs 40GiB 100%

echo "Create XFS filesystem"
sudo mkfs.xfs /dev/sdc1
sudo mkfs.xfs /dev/sdc2
# mkfs.xfs /dev/sdc3

echo "Inform the OS of partition table changes"
sudo partprobe /dev/sdc1
sudo partprobe /dev/sdc2
# partprobe /dev/sdc3

echo "Mount partitions"
sudo mount /dev/sdc1 /data/opt
sudo mount /dev/sdc2 /data/log
# mount /dev/sdc3 /data/users

echo "Add entries to fstab"
echo -e "# Data disk entries" >> /etc/fstab
UUID=$(blkid | grep '/dev/sdc1' | cut -d" " -f2 | cut -d"\"" -f2)
sudo echo -e "UUID=${UUID}\t/data/opt\txfs\tdefaults,nofail\t1\t2" >> /etc/fstab

UUID=$(blkid | grep '/dev/sdc2' | cut -d" " -f2 | cut -d"\"" -f2)
sudo echo -e "UUID=${UUID}\t/data/log\txfs\tdefaults,nofail\t1\t2" >> /etc/fstab

# UUID=$(blkid | grep '/dev/sdc3' | cut -d" " -f2 | cut -d"\"" -f2)
# sudo echo -e "UUID=${UUID}\t/data/users\txfs\tdefaults,nofail\t1\t2" >> /etc/fstab
