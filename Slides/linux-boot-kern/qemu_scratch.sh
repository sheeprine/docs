#!/bin/sh

CDROM_IMG_FILE=/mnt/data/VM/lfslivecd-x86_64-6.3-r2145-min.iso
IMG_FILE=/mnt/data/VM/qemu_scratch.img
IMG_SIZE=2G

function usage()
{
    echo "usage: $0 <command> [options]"
    echo "  see: \"$0 help\" for more informations."
}

function help()
{
    echo "usage: $0 <command> [options]"
    echo "Commands:"
    echo "  snap <snap_name> :   Use this qemu snapshot"
    echo "  snap-list        :   List all the snapshots"
    echo "  snap-del         :   Delete a snapshots"
    echo "  create-img       :   Create the qemu img"
    echo "  connect-base     :   Load the qemu img in /dev/nbd0"
    echo "  disconnect-base  :   Unload the qemu img from /dev/nbd0"
    echo "  start-vm         :   Start the virtual machine"
    echo "  start-vm-nosav   :   Start the virtual machine without committing changes to images."
    echo "  start-vm-cd      :   Start the virtual machine with the live CD"
}

if [ $# -ge 1 ]; then
    case $1 in
        snap)
            if [ -z $2 ]; then
                echo "usage: $0 snap <snap_name>"
                exit 1
            fi
            qemu-img snapshot -a $2 $IMG_FILE 2> /dev/null
            if [ $? -eq 0 ]; then
                echo "Set snapshot to $2."
            else
                qemu-img snapshot -c $2 $IMG_FILE
                echo "Created snapshot $2."
            fi
            ;;
        snap-list)
            if [ `qemu-img snapshot -l $IMG_FILE | wc -c` -gt 0 ]; then
                qemu-img snapshot -l $IMG_FILE
            else
                echo "No snapshot."
            fi
            ;;
        snap-del)
            if [ -z $2 ]; then
                echo "usage: $0 snap-del <snap_name>"
                exit 1
            fi
            qemu-img snapshot -d $2 $IMG_FILE 2> /dev/null
            if [ $? -eq 0 ]; then
                echo "Snapshot $2 deleted" 
            else
                echo "Unable to delete snapshot."
                exit 1
            fi
            ;;
        create-img)
            if [ ! -f $IMG_FILE ]; then
                echo "Creating image:"
                qemu-img create -f qcow2 $IMG_FILE $IMG_SIZE
            else
                echo "Image already exists."
                exit 1
            fi
            ;;
        connect-base)
            lsmod | grep nbd > /dev/null || echo "Loading NBD module" && sudo modprobe nbd max_part=8
            echo "Exposing drive"
            sudo qemu-nbd --connect /dev/nbd0 $IMG_FILE
            sudo fdisk -l /dev/nbd0
            ;;
        disconnect-base)
            echo "Unloading drive"
            sudo qemu-nbd -d /dev/nbd0
            sleep 1
            lsmod | grep nbd > /dev/null && echo "Unloading NBD module" && sudo rmmod nbd
            ;;
        start-vm)
            qemu-kvm -boot c -m 1048 -vga none -cpu host -k fr -redir tcp:1337::22 -hda $IMG_FILE
            ;;
        start-vm-nosav)
            qemu-kvm -boot c -m 1048 -vga none -cpu host -k fr -redir tcp:1337::22 -hda $IMG_FILE -snapshot
            ;;
        start-vm-cd)
            qemu-kvm -boot d -m 1048 -vga std -cpu host -k fr -redir tcp:1337::22 -cdrom $CDROM_IMG_FILE -hda $IMG_FILE
            ;;
        help)
            help
            ;;
        *)
            usage
    esac
fi

