
own='devops'
mnt='/var/data'

if [ $# < 3 ]; then
    echo 'raid0.sh md-seq sd-seq ...'
else
    rmd=$1; shift
    rno=$#; rsd=''
    while (($#)); do
        (   echo o  # clear partition
            echo n  # new partition
            echo p  # primary partition
            echo 1  # partition number
            echo    # default first sector 
            echo    # default last sector
            echo t  # change partition type
            echo da # NoFS for raid
            echo w  # write changes
        ) | fdisk /dev/$1
        rsd=${rsd}' /dev/'$1'1'
        shift
    done

    if mdadm --create --verbos /dev/${rmd} --level=stripe \
        --raid-devices=${rno} ${rsd}; then
        mkfs.ext4 -v -m .1 -b 4096 /dev/${rmd}
        mdadm --detail --scan | tee -a /etc/mdadm/mdadm.conf
        uid=$(blkid /dev/${rmd} | grep -o 'UUID="[^"]+"')
        echo ${uid//\"/}'   ext4    '${mnt}'    defaults    0   2'\
            | tee -a /etc/fstab

        mkdir -p ${mnt}
        touch ${mnt}/WARNING
        chown ${own}:${own} ${mnt}
        mount -a
    fi
fi
