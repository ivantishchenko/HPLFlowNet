#!/bin/bash

# create constants.env in the same folder
# KITTI_PATH=
# FLYING_THINGS_3D_PATH=
# REFRESH_PATH=

# Before launching
# conda activate hplfn

# Example usage:
# Params:
# -d  Training dataset name FlyingThings3D or RefRESH
# -r  Absolute path to the checkpoint

# Training from scratch:
#   ./train.sh -d FlyingThings3D

# Training from an existing checkpoint
#   ./train.sh 
#   -d FlyingThings3D \
#   -r /checkpoints/train/leon_FlyingThings3D/model_best.pth.tar

# export logdir
export LOG_DIR=$HOME'/master/logs'
mkdir -p $LOG_DIR'/board'
mkdir -p $LOG_DIR'/checkpoints'
mkdir -p $LOG_DIR'/configs/train'

. constants.env
export CHECKPOINT_PATH=False
DATASET=
while getopts r:d: opt; do
  case $opt in
  r)
      export CHECKPOINT_PATH=$(realpath -s $OPTARG)
      ;;
  d)
      export DATASET=$OPTARG
      ;;
  esac
done

shift $((OPTIND - 1))

HPLFLOWNET_ROOT='../../../third_party/hplflownet'

# Set datadir
case $DATASET in
     FlyingThings3DPoses)
          if [ -z "$FLYING_THINGS_3D_POSES_PATH" ]
          then
              printf "\nFLYING_THINGS_3D_POSES_PATH not set\n\n"
              exit 1
          fi
          printf "\nData dir is FlyingThings3DPoses PC dataset\n\n"
          export DATA_DIR=$FLYING_THINGS_3D_POSES_PATH
          ;;
     FlyingThings3D)
          if [ -z "$FLYING_THINGS_3D_PATH" ]
          then
              printf "\nFLYING_THINGS_3D_PATH not set\n\n"
              exit 1
          fi
          printf "\nData dir is FlyingThings3D PC dataset\n\n"
          export DATA_DIR=$FLYING_THINGS_3D_PATH
          ;;
     RefRESH)
          if [ -z "$REFRESH_PATH" ]
          then
            printf "\nREFRESH_PATH not set\n\n"
            exit 1
          fi
          printf "\nData dir RefRESH PC dataset\n\n"
          export DATA_DIR=$REFRESH_PATH
          ;; 
     *)
          printf "\nDataset is not supported. Select -d [RefRESH, FlyingThings3D]\n\n"
          exit 1
          ;;
esac

# generate timestamp
#export DATE=$(date '+%Y-%m-%d_%H-%M-%S')
export DATE=$(date +%s)
export HOSTNAME=$(hostname)

TRAIN_CONFIG=$LOG_DIR'/configs/train/'$DATASET'_'$DATE'.yaml'
# Prepare TRAIN config file
# Substitute all templates with ENV variables
perl -p -i -e 's/\$\{([^}]+)\}/defined $ENV{$1} ? $ENV{$1} : $&/eg' < $HPLFLOWNET_ROOT'/configs/train_local_'$DATASET'_temp.yaml' > $TRAIN_CONFIG

# Train
(cd $HPLFLOWNET_ROOT'/models' && python build_khash_cffi.py)
(cd $HPLFLOWNET_ROOT && python main.py $TMPDIR'/'$TRAIN_CONFIG)