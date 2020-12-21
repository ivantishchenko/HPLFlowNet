#!/bin/bash

# create constants.env in the same folder
# KITTI_PATH=
# FLYING_THINGS_3D_PATH=
# REFRESH_PATH=

# Before launching
# conda activate hplfn

# Params:
# -r  Absolute path to the checkpoint

# Inference start
# ./test.sh -r /checkpoints/train/leon_FlyingThings3D/model_best.pth.tar

# export logdir
export LOG_DIR=$HOME'/master/logs'
mkdir -p $LOG_DIR'/checkpoints'
mkdir -p $LOG_DIR'/configs/test'

. constants.env

export CHECKPOINT_PATH=
while getopts r: opt; do
  case $opt in
  r)
      export CHECKPOINT_PATH=$(realpath -s $OPTARG)
      ;;
  esac
done

shift $((OPTIND - 1))

if [ -z "$CHECKPOINT_PATH" ]
then
    printf "\nCheckpoint not set. Set the checkpoint -r /path/checkpoint.pth.tar\n\n"
    exit 1
fi

if [ -z "$KITTI_PATH" ]
then
    printf "\nKITTI_PATH not set\n\n"
    exit 1
fi

if [ -z "$FLYING_THINGS_3D_PATH" ]
then
    printf "\nFLYING_THINGS_3D_PATH not set\n\n"
    exit 1
fi

if [ -z "$REFRESH_PATH" ]
then
    printf "\nREFRESH_PATH not set\n\n"
    exit 1
fi

if [ -z "$FLYING_THINGS_3D_POSES_PATH" ]
then
    printf "\nFLYING_THINGS_3D_POSES_PATH not set\n\n"
    exit 1
fi

HPLFLOWNET_ROOT='../../../third_party/hplflownet'

# generate timestamp
#export DATE=$(date '+%Y-%m-%d_%H-%M-%S')
export DATE=$(date +%s)
export HOSTNAME=$(hostname)

# Test configs
TEST_FLYING_THINGS_3D_CONFIG=$LOG_DIR'/configs/test/FlyingThings3D_'$DATE'.yaml'
TEST_KITTI_CONFIG=$LOG_DIR'/configs/test/KITTI_'$DATE'.yaml'
TEST_REFRESH_CONFIG=$LOG_DIR'/configs/test/RefRESH_'$DATE'.yaml'
TEST_FLYING_THINGS_3D_POSES_CONFIG=$LOG_DIR'/configs/test/FlyingThings3DPoses_'$DATE'.yaml'

# Prepare TEST configs
export DATA_DIR=$FLYING_THINGS_3D_PATH
perl -p -i -e 's/\$\{([^}]+)\}/defined $ENV{$1} ? $ENV{$1} : $&/eg' < $HPLFLOWNET_ROOT'/configs/test_local_FlyingThings3D_temp.yaml' > $TEST_FLYING_THINGS_3D_CONFIG
export DATA_DIR=$KITTI_PATH
perl -p -i -e 's/\$\{([^}]+)\}/defined $ENV{$1} ? $ENV{$1} : $&/eg' < $HPLFLOWNET_ROOT'/configs/test_local_KITTI_temp.yaml' > $TEST_KITTI_CONFIG
export DATA_DIR=$REFRESH_PATH
perl -p -i -e 's/\$\{([^}]+)\}/defined $ENV{$1} ? $ENV{$1} : $&/eg' < $HPLFLOWNET_ROOT'/configs/test_local_RefRESH_temp.yaml' > $TEST_REFRESH_CONFIG
export DATA_DIR=$FLYING_THINGS_3D_POSES_PATH
perl -p -i -e 's/\$\{([^}]+)\}/defined $ENV{$1} ? $ENV{$1} : $&/eg' < $HPLFLOWNET_ROOT'/configs/test_local_FlyingThings3DPoses_temp.yaml' > $TEST_FLYING_THINGS_3D_POSES_CONFIG

# Test FlyingThings3D
(cd $HPLFLOWNET_ROOT && python main.py $TEST_FLYING_THINGS_3D_CONFIG)
# Test KITTI
(cd $HPLFLOWNET_ROOT && python main.py $TEST_KITTI_CONFIG)
# Test RefRESH
(cd $HPLFLOWNET_ROOT && python main.py $TEST_REFRESH_CONFIG)
# Test FlyingThings3DPoses
(cd $HPLFLOWNET_ROOT && python main.py $TEST_FLYING_THINGS_3D_POSES_CONFIG)