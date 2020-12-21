#!/bin/bash
# To upload datasets into Leonhard ./upload_datasets -u username -d /data/dir
# -u is your Leonhard username
# -d Data dir should contain KITTI_pc.tar && FlyingThings3D_pc.tar && REFRESH_pc.tar

. constants.env

user=   data_dir= 
while getopts u:d: opt; do
  case $opt in
  u)
      user=$OPTARG
      ;;
  d)
      data_dir=$OPTARG
      ;;
  esac
done

shift $((OPTIND - 1))

KITTI_PATH=$(realpath -s $data_dir)'/'$KITTI_TAR
FLYING_THINGS_3D_PATH=$(realpath -s $data_dir)'/'$FLYING_THINGS_3D_TAR
REFRESH_PATH=$(realpath -s $data_dir)'/'$REFRESH_TAR
FLYING_THINGS_3D_POSES_PATH=$(realpath -s $data_dir)'/'$FLYING_THINGS_3D_POSES_TAR

echo $KITTI_PATH
echo $FLYING_THINGS_3D_PATH
echo $REFRESH_PATH
echo $FLYING_THINGS_3D_POSES_PATH

printf "Uploading KITTI PC dataset\n\n"
rsync -r -v --progress -e ssh $KITTI_PATH $user@login.leonhard.ethz.ch:\$SCRATCH
printf "\nUploading FlyingThings3D PC dataset\n\n"
rsync -r -v --progress -e ssh $FLYING_THINGS_3D_PATH $user@login.leonhard.ethz.ch:\$SCRATCH
printf "\nUploading RefRESH PC dataset\n\n"
rsync -r -v --progress -e ssh $REFRESH_PATH $user@login.leonhard.ethz.ch:\$SCRATCH
printf "\nUploading FlyingThings3D Poses PC dataset\n\n"
rsync -r -v --progress -e ssh $FLYING_THINGS_3D_POSES_PATH $user@login.leonhard.ethz.ch:\$SCRATCH