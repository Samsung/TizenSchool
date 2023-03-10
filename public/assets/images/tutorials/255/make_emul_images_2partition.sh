#!/bin/sh -e
# SeokYeon Hwang (syeon.hwang@samsung.com)
# Sooyoung Ha    (yoosah.ha@samsung.com)

SCRIPT=$(readlink -f $0)
BASEDIR=$(dirname $SCRIPT)

IMAGE_COUNT=0
IMAGE_LIST=""
IMAGE_SIZE=5G
PARTITION_SIZE=2G

if [ ! -z $1 ]; then
    SRC_IMG_FILE=$1
fi
EMUL_IMG_RAW_FILE=emul_img.raw
EMUL_IMG_QCOW2_FILE=emulimg.x86
PARTITIONIZED=0

TEMP=""

check_util() {
    TEMP=`which $1`
    if [ -z $TEMP ]; then
        if [ $2 = 1 ]; then
            echo "'$1' is required."
            exit 1
        fi
        return 1
    fi
    return 0
}

check_e2fsck_result() {
    if [ $1 = 1 ]; then
        echo "e2fsck catched file system errors, but corrected well."
        return 0
    else
        echo "e2fsck failed $1"
        return $1
    fi
}

gen_parted_raw_image() {
    # generate space for partition table
    dd if=/dev/zero of=temp_img.raw bs=1 count=0 seek=1M

    # concatenate raw images into a single image
    cat $* >> temp_img.raw

    # convert raw image to sparse type
    cp --sparse=always temp_img.raw $EMUL_IMG_RAW_FILE
    rm -f temp_img.raw

    TMP_CMD=""
    TMP_CNT=1
    while [ $TMP_CNT -lt $# ]; do
        TMP_CMD="${TMP_CMD}n\np\n${TMP_CNT}\n\n+${PARTITION_SIZE}\n"
        TMP_CNT=`expr $TMP_CNT + 1`
    done
    TMP_CMD="${TMP_CMD}n\np\n${TMP_CNT}\n\n\nw\n"
    /bin/echo -ne "$TMP_CMD" | fdisk $EMUL_IMG_RAW_FILE
}

# check prerequsite utils
check_util e2fsck 1
check_util resize2fs 1
check_util dd 1
check_util /bin/echo 1
check_util qemu-img 0 || check_util $HOME/tizen-studio/tools/emulator/bin/qemu-img 1
QEMU_IMG=$TEMP

# resize raw images
if [ ! -z $SRC_IMG_FILE ]; then
    e2fsck -f $SRC_IMG_FILE
    IMAGE_LIST=$SRC_IMG_FILE
    IMAGE_COUNT=1
else
    for TMP_IMG in `ls *.img`; do
        if [ $IMAGE_COUNT = 3 ]; then
            echo "The maximum partition is 3!"
            echo "Skip $TMP_IMG!"
            continue
        fi
        IMAGE_COUNT=`expr $IMAGE_COUNT + 1`
        echo "$IMAGE_COUNT: found $TMP_IMG"
        e2fsck -f $TMP_IMG || check_e2fsck_result $?
        resize2fs $TMP_IMG $PARTITION_SIZE
        IMAGE_LIST="${IMAGE_LIST}${TMP_IMG} "
    done
fi

if [ $IMAGE_COUNT = 0 ]; then
    echo "No rootfs image."
    exit 1
elif [ $IMAGE_COUNT = 1 ]; then
    resize2fs $IMAGE_LIST $IMAGE_SIZE
    EMUL_IMG_RAW_FILE=$IMAGE_LIST
else
    gen_parted_raw_image $IMAGE_LIST
fi

# generate compressed qcow2 image
$QEMU_IMG convert -c -O qcow2 $EMUL_IMG_RAW_FILE $EMUL_IMG_QCOW2_FILE
