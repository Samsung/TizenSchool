#!/bin/bash

declare FORMAT=""
declare DEVICE=""
declare -i OLD_DD=0

# Binaires array for fusing
declare -a FUSING_BINARY_ARRAY
declare -i FUSING_BINARY_NUM=0

declare CONV_ASCII=""
declare -i FUS_ENTRY_NUM=0

# binary name | part number | bs | label | fs type
declare -a PART_TABLE=(
	"boot.img"			1	4M	boot			vfat
	"rootfs.img"			2	4M	rootfs			ext4
	"system-data.img"		3	4M	system-data		ext4
	"user.img"			5	4M	user			ext4
	"modules.img"			6	4M	modules			ext4
	"ramdisk.img"			7	4M	ramdisk			ext4
	"ramdisk-recovery.img"		8	4M	ramdisk-recovery	ext4
	"hal.img"			10	4M	hal			ext4
	)

declare -r -i PART_TABLE_COL=5
declare -r -i PART_TABLE_ROW=${#PART_TABLE[*]}/${PART_TABLE_COL}

# partition table support
function get_index_use_name () {
	local -r binary_name=$1

	for ((idx=0;idx<$PART_TABLE_ROW;idx++)); do
		if [ ${PART_TABLE[idx * ${PART_TABLE_COL} + 0]} == "$binary_name" ]; then
			return $idx
		fi
	done

	# return out of bound index
	return $idx
}

function print_message () {
	local color=$1
	local message=$2

	tput setaf $color
	tput bold
	echo ""
	echo $message
	tput sgr 0
}

function check_ddversion () {
	# NOTE
	# before coreutils dd 8.24, dd doesn't support "status=progress"
	# and the option causes fusing failure. For backward compatibility,
	# do not use the option for old dd
	local version=(`dd --version | head -1 | grep -o '[0-9]\+'`)
	local major=${version[0]}
	local minor=${version[1]}

	if [ $major -lt 8 ];  then
		OLD_DD=1
	elif [ $major -eq 8 -a $minor -lt 24 ];  then
		OLD_DD=1
	fi
}

function fusing_image () {
	local -r fusing_img=$1

	# get binary info using basename
	get_index_use_name $(basename "$fusing_img")
	local -r -i part_idx=$?

	if [ $part_idx -ne $PART_TABLE_ROW ];then
		local -r num=${PART_TABLE[${part_idx} * ${PART_TABLE_COL} + 1]}
		if [ "${num}" == "" ]; then
			local -r blktype=disk
		else
			local -r blktype=part
		fi
		local -r device=/dev/`lsblk ${DEVICE} -o TYPE,KNAME | grep ${blktype} | awk '{ print $2 }' | grep -G "[a-z]${num}\$"`
		local -r bs=${PART_TABLE[${part_idx} * ${PART_TABLE_COL} + 2]}
	else
		echo "Not supported binary: $fusing_img"
		return
	fi

	local -r input_size=`du -b $fusing_img | awk '{print $1}'`
	local -r input_size_mb=`expr $input_size / 1024 / 1024`

	print_message 2 "[Fusing $1 ($input_size_mb MiB)]"
	if [ "$blktype" == "part" ]; then
		local MOUNT_PART=`mount | grep $device`
		if [ "$MOUNT_PART" != "" ]; then
			umount $device
		fi
	fi
	if [ $OLD_DD == 1 ]; then
		dd if=$fusing_img | pv -s $input_size | dd of=$device bs=$bs
	else
		dd if=$fusing_img of=$device bs=$bs status=progress oflag=direct
	fi

	local -r fstype=`blkid -o value -s TYPE $device`
	if [[ "$fstype" =~ "ext" ]]; then
		resize2fs -f $device
	fi
}

function fuse_image_tarball () {
	local -r filepath=$1
	local -r temp_dir="tar_tmp"

	mkdir -p $temp_dir
	tar xvf $filepath -C $temp_dir
	cd $temp_dir

	for file in *
	do
		fusing_image $file
	done

	cd ..
	rm -rf $temp_dir
	eval sync
}

function fuse_image () {

	if [ "$FUSING_BINARY_NUM" == 0 ]; then
		return
	fi

	for ((fuse_idx = 0 ; fuse_idx < $FUSING_BINARY_NUM ; fuse_idx++))
	do
		local filename=${FUSING_BINARY_ARRAY[fuse_idx]}

		case "$filename" in
		    *.tar | *.tar.gz)
			fuse_image_tarball $filename
			;;
		    *)
			fusing_image $filename
			;;
		esac
	done
	echo ""
}

# partition format
function mkpart_3 () {
	# NOTE: if your sfdisk version is less than 2.26.0, then you should use following sfdisk command:
	# sfdisk --in-order --Linux --unit M $DISK <<-__EOF__

	# NOTE: sfdisk 2.26 doesn't support units other than sectors and marks --unit option as deprecated.
	# The input data needs to contain multipliers (MiB) instead.
	local version=(`sfdisk -v | grep -o '[0-9]\+'`)
	local major=${version[0]}
	local minor=${version[1]}
	local sfdisk_new=0
	local support_delete=0

	if [ $major -gt 2 ];  then
		sfdisk_new=1
	else
		if [ $major -eq 2 -a $minor -ge 26 ];  then
			sfdisk_new=1
			if [ $major -eq 2 -a $minor -ge 28 ]; then
				support_delete=1
			fi
		fi
	fi

	if [ $sfdisk_new == 0 ]; then
		echo "$(tput setaf 3)$(tput bold)NOTICE: Your sfidk ${version[0]}.${version[1]}  version is too old. It can do unstable behavior!"
		tput sgr 0
		echo ""

	fi

	local -r DISK=$DEVICE
	local -r SIZE=`sfdisk -s $DISK`
	local -r SIZE_MB=$((SIZE >> 10))

	local -r BOOT_SZ=64
	local -r ROOTFS_SZ=3072
	local -r DATA_SZ=1344
	local -r MODULE_SZ=32
	local -r RAMDISK_SZ=32
	local -r RAMDISK_RECOVERY_SZ=32
	local -r INFORM_SZ=8
	local -r HAL_SZ=256
	local -r RESERVED2_SZ=125
	local -r EXTEND_SZ=12

	let "USER_SZ = $SIZE_MB - $BOOT_SZ - $ROOTFS_SZ - $DATA_SZ - $MODULE_SZ - $RAMDISK_SZ - $RAMDISK_RECOVERY_SZ - $INFORM_SZ - $EXTEND_SZ - $HAL_SZ - $RESERVED2_SZ"

	local -r BOOT=${PART_TABLE[0 * ${PART_TABLE_COL} + 3]}
	local -r ROOTFS=${PART_TABLE[1 * ${PART_TABLE_COL} + 3]}
	local -r SYSTEMDATA=${PART_TABLE[2 * ${PART_TABLE_COL} + 3]}
	local -r USER=${PART_TABLE[3 * ${PART_TABLE_COL} + 3]}
	local -r MODULE=${PART_TABLE[4 * ${PART_TABLE_COL} + 3]}
	local -r RAMDISK=${PART_TABLE[5 * ${PART_TABLE_COL} + 3]}
	local -r RAMDISK_RECOVERY=${PART_TABLE[6 * ${PART_TABLE_COL} + 3]}
	local -r INFORM=inform
	local -r HAL=${PART_TABLE[7 * ${PART_TABLE_COL} + 3]}
	local -r RESERVED2=reserved2

	if [[ $USER_SZ -le 100 ]]
	then
		echo "We recommend to use more than 4GB disk"
		exit 0
	fi

	echo "================================================"
	echo "Label			dev		size"
	echo "================================================"
	echo $BOOT"			" $DISK"1	" $BOOT_SZ "MB"
	echo $ROOTFS"			" $DISK"2	" $ROOTFS_SZ "MB"
	echo $SYSTEMDATA"		" $DISK"3	" $DATA_SZ "MB"
	echo "[Extend]""		" $DISK"4"
	echo " "$USER"			" $DISK"5	" $USER_SZ "MB"
	echo " "$MODULE"		" $DISK"6	" $MODULE_SZ "MB"
	echo " "$RAMDISK"		" $DISK"7	" $RAMDISK_SZ "MB"
	echo " "$RAMDISK_RECOVERY"	" $DISK"8	" $RAMDISK_RECOVERY_SZ "MB"
	echo " "$INFORM"			" $DISK"9	" $INFORM_SZ "MB"
	echo " "$HAL"			" $DISK"10	" $HAL_SZ "MB"
	echo " "$RESERVED2"		" $DISK"11	" $RESERVED2_SZ "MB"

	local MOUNT_LIST=`mount | grep $DISK | awk '{print $1}'`
	for mnt in $MOUNT_LIST
	do
		umount $mnt
	done

	echo "Remove partition table..."
	dd if=/dev/zero of=$DISK bs=512 count=32 conv=notrunc

	if [ $sfdisk_new == 1 ]; then
		if [ $support_delete == 1 ]; then
			sfdisk --delete $DISK
		fi

		sfdisk $DISK <<-__EOF__
		4MiB,${BOOT_SZ}MiB,0xE,*
		8MiB,${ROOTFS_SZ}MiB,,-
		8MiB,${DATA_SZ}MiB,,-
		8MiB,,E,-
		,${USER_SZ}MiB,,-
		,${MODULE_SZ}MiB,,-
		,${RAMDISK_SZ}MiB,,-
		,${RAMDISK_RECOVERY_SZ}MiB,,-
		,${INFORM_SZ}MiB,,-
		,${HAL_SZ}MiB,,-
		,${RESERVED2_SZ}MiB,,-
		__EOF__
	else
		# calculate start positions for alignment for extended partitions
		let "USER_START = 4 + $BOOT_SZ + $ROOTFS_SZ + $DATA_SZ + 1"
		let "MODULE_START = $USER_START + $USER_SZ + 1"
		let "RAMDISK_START = $MODULE_START + $MODULE_SZ + 1"
		let "RAMDISK_RECOVERY_START = $RAMDISK_START + $RAMDISK_SZ + 1"
		let "INFORM_START = $RAMDISK_RECOVERY_START + $RAMDISK_RECOVERY_SZ + 1"
		let "HAL_START = $INFORM_START + $INFORM_SZ + 1"
		let "RESERVED2_START = $HAL_START + $HAL_SZ + 1"

		sfdisk --in-order --Linux --unit M $DISK <<-__EOF__
		4,$BOOT_SZ,0xE,*
		,$ROOTFS_SZ,,-
		,$DATA_SZ,,-
		,,E,-
		$USER_START,$USER_SZ,,-
		$MODULE_START,$MODULE_SZ,,-
		$RAMDISK_START,$RAMDISK_SZ,,-
		$RAMDISK_RECOVERY_START,$RAMDISK_RECOVERY_SZ,,-
		$INFORM_START,$INFORM_SZ,,-
		$HAL_START,$HAL_SZ,,-
		$RESERVED2_START,$RESERVED2_SZ,,-
		__EOF__
	fi

	for ((idx=0;idx<$PART_TABLE_ROW;idx++)); do
		local PART=/dev/`lsblk ${DISK} -o TYPE,KNAME | grep part | awk '{ print $2 }' | grep -G "[a-z]${PART_TABLE[$idx * ${PART_TABLE_COL} + 1]}\$"`
		if [ "${PART_TABLE[$idx * ${PART_TABLE_COL} + 4]}" == "vfat" ]; then
			mkfs.vfat -F 16 ${PART} -n ${PART_TABLE[$idx * ${PART_TABLE_COL} + 3]}
			if [ $? -eq 1 ]; then
				echo "Failed to format as FAT filesystem"
				exit -1
			fi
		elif [ "${PART_TABLE[$idx * ${PART_TABLE_COL} + 4]}" == "ext4" ]; then
			mkfs.ext4 -q ${PART} -L ${PART_TABLE[$idx * ${PART_TABLE_COL} + 3]} -F
		else
			echo "Skip to format for unknown filesystem type ${PART_TABLE[$idx * ${PART_TABLE_COL} + 4]} for part$idx, ${PART_TABLE[$idx * ${PART_TABLE_COL} + 3]}"
		fi
	done

	local -r PART9=/dev/`lsblk ${DISK} -o TYPE,KNAME | grep part | awk '{ print $2 }' | grep -G "[a-z]9\$"`
	mkfs.ext4 -q ${PART9} -L $INFORM -F

	# create "reboot-param.bin" file in inform partition for passing reboot parameter
	# It should be done only once upon partition format.
	if [ -d mnt_tmp ]; then
		echo "Remove the existing mnt_tmp directory!!"
		rm -rf mnt_tmp
	fi
	mkdir mnt_tmp
	mount -t ext4 ${PART9} ./mnt_tmp
	touch ./mnt_tmp/reboot-param.bin
	sync
	umount ./mnt_tmp
	rmdir mnt_tmp

	local -r PART11=/dev/`lsblk ${DISK} -o TYPE,KNAME | grep part | awk '{ print $2 }' | grep -G "[a-z]11\$"`
	mkfs.ext4 -q ${PART11} -L $RESERVED2 -F
}

function show_usage () {
	echo "- Usage:"
	echo "	sudo ./sd_fusing*.sh -d <device> [-b <path> <path> ..] [--format]"
}

function check_partition_format () {
	if [ "$FORMAT" != "2" ]; then
		echo "-----------------------"
		echo "Skip $DEVICE format"
		echo "-----------------------"
		return 0
	fi

	echo "-------------------------------"
	echo "Start $DEVICE format"
	echo ""
	mkpart_3
	echo "End $DEVICE format"
	echo "-------------------------------"
	echo ""
}

function check_args () {
	if [ "$DEVICE" == "" ]; then
		echo "$(tput setaf 1)$(tput bold)- Device node is empty!"
		show_usage
		tput sgr 0
		exit 0
	fi

	if [ "$DEVICE" != "" ]; then
		echo "Device: $DEVICE"
	fi

	if [ "$FUSING_BINARY_NUM" != 0 ]; then
		echo "Fusing binary: "
		for ((bid = 0 ; bid < $FUSING_BINARY_NUM ; bid++))
		do
			echo "  ${FUSING_BINARY_ARRAY[bid]}"
		done
		echo ""
	fi

	if [ "$FORMAT" == "1" ]; then
		echo ""
		echo "$(tput setaf 3)$(tput bold)$DEVICE will be formatted, Is it OK? [y/<n>]"
		tput sgr 0
		read input
		if [ "$input" == "y" ] || [ "$input" == "Y" ]; then
			FORMAT=2
		else
			FORMAT=0
		fi
	fi
}

function check_device () {
	if [ ! -b "$DEVICE" ]; then
		echo "No such device: $DEVICE"
		exit 0
	fi

	local REMOVABLE=`lsblk $DEVICE -nd -o RM | grep 1 | wc -l`
	if [ "$REMOVABLE" == "0" ]; then
		echo ""
		echo "$(tput setaf 3)$(tput bold)$DEVICE is not a removable disk, Is it OK? [y/<n>]"
		tput sgr 0
		read input
		if [ "$input" != "y" ] && [ "$input" != "Y" ]; then
			exit 0
		fi
	fi

	if [ ! -w "$DEVICE" ]; then
		echo "Write not permitted: $DEVICE"
		exit 0
	fi
}

function print_logo () {
	echo ""
	echo "Raspberry Pi downloader, version 2.2.1"
	echo ""
}

print_logo

function add_fusing_binary() {
	local declare binary_name=$1

	if [ "$binary_name" != "" ]; then
		if [ -f "$binary_name" ]; then
			FUSING_BINARY_ARRAY[$FUSING_BINARY_NUM]=$binary_name

			FUSING_BINARY_NUM=$((FUSING_BINARY_NUM + 1))
		else
			echo "No such file: $binary_name"
		fi
	fi
}


declare -i binary_option=0

while test $# -ne 0; do
	option=$1
	shift

	case $option in
	--f | --format)
		FORMAT="1"
		binary_option=0
		;;
	-d)
		DEVICE=$1
		binary_option=0
		shift
		;;
	-b)
		add_fusing_binary $1
		binary_option=1
		shift
		;;
	*)
		if [ $binary_option == 1 ];then
			add_fusing_binary $option
		else
			echo "Unkown command: $option"
			exit
		fi
		;;
	esac
done

check_args
check_device
check_partition_format
check_ddversion
fuse_image
