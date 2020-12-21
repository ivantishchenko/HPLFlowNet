#!/bin/bash

# Allocate ~ 130 GB scratch for FlyingThings3D + KITTI
# Allocate ~ 540 GB scratch for RefRESH + KITTI
# Allocate ~ 665 GB scratch for all 3 datasets

# Example usage:

# Params:
# -d  Training dataset name FlyingThings3D or RefRESH
# -r  Absolute path to the checkpoint

# Training from scratch:
# bsub -W 360:00 -n2 \
#   -R rusage[mem=10000,scratch=665000,ngpus_excl_p=1] \
#   -R "select[gpu_model0==TeslaV100_SXM2_32GB]" \
#   ./train.sh -d FlyingThings3D

# Training from an existing checkpoint
# bsub -W 360:00 -n2 \
#   -R rusage[mem=10000,scratch=665000,ngpus_excl_p=1] \
#   -R "select[gpu_model0==TeslaV100_SXM2_32GB]" \
#   ./train.sh -d FlyingThings3D \
#   -r $SCRATCH/checkpoints/train/leon_FlyingThings3D/model_best.pth.tar

. constants.env

eval "$(conda shell.bash hook)"
conda activate base

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

HPLFLOWNET_ROOT=$HOME'/ddr/third_party/hplflownet'
TRAIN_CONFIG='train_'$DATASET'.yaml'
# Test configs
TEST_FLYING_THINGS_3D_CONFIG='test_FlyingThings3D.yaml'
TEST_FLYING_THINGS_3D_POSES_CONFIG='test_FlyingThings3DPoses.yaml'
TEST_KITTI_CONFIG='test_KITTI.yaml'
TEST_REFRESH_CONFIG='test_RefRESH.yaml'

# Extract train dataset
case $DATASET in
     FlyingThings3D)
          printf "\nExtracting FlyingThings3D PC dataset\n\n"
          tar -xvf $SCRATCH/$FLYING_THINGS_3D_TAR -C $TMPDIR
          ;;
     FlyingThings3DPoses)
          printf "\nExtracting FlyingThings3D Poses PC dataset\n\n"
          tar -xvf $SCRATCH/$FLYING_THINGS_3D_POSES_TAR -C $TMPDIR
          ;;
     RefRESH)
          printf "\nExtracting RefRESH PC dataset\n\n"
          tar -xvf $SCRATCH/$REFRESH_TAR -C $TMPDIR
          ;; 
     *)
          printf "\nDataset is not supported. Select -d [RefRESH, FlyingThings3D]\n\n"
          exit 1
          ;;
esac

# generate timestamp
#export DATE=$(date '+%Y-%m-%d_%H-%M-%S')
export DATE=$(date +%s)

# Prepare TRAIN config file
# Substitute all templates with ENV variables
perl -p -i -e 's/\$\{([^}]+)\}/defined $ENV{$1} ? $ENV{$1} : $&/eg' < $HPLFLOWNET_ROOT'/configs/train_leon_'$DATASET'_temp.yaml' > $TMPDIR'/'$TRAIN_CONFIG

# Train
cd $HPLFLOWNET_ROOT'/models' && python build_khash_cffi.py
cd $HPLFLOWNET_ROOT && python main.py $TMPDIR'/'$TRAIN_CONFIG

# Extract test dataset
printf "\nExtracting KITTI PC dataset\n\n"
tar -xvf $SCRATCH/$KITTI_TAR -C $TMPDIR
case $DATASET in
     RefRESH)
          printf "\nExtracting FlyingThings3D PC dataset\n\n"
          tar -xvf $SCRATCH/$FLYING_THINGS_3D_TAR -C $TMPDIR
          ;;
     FlyingThings3D)
          printf "\nExtracting RefRESH PC dataset\n\n"
          tar -xvf $SCRATCH/$REFRESH_TAR -C $TMPDIR
          printf "\nExtracting FlyingThings3D Poses PC dataset\n\n"
          tar -xvf $SCRATCH/$FLYING_THINGS_3D_POSES_TAR -C $TMPDIR
          ;; 
     FlyingThings3DPoses)
          printf "\nExtracting RefRESH PC dataset\n\n"
          tar -xvf $SCRATCH/$REFRESH_TAR -C $TMPDIR
          printf "\nExtracting FlyingThings3D PC dataset\n\n"
          tar -xvf $SCRATCH/$FLYING_THINGS_3D_TAR -C $TMPDIR
          ;; 
esac

# Prepare TEST configs
export CHECKPOINT_PATH=${SCRATCH}'/checkpoints/train/leon_'${DATASET}'_'${DATE}'/model_best.pth.tar'
perl -p -i -e 's/\$\{([^}]+)\}/defined $ENV{$1} ? $ENV{$1} : $&/eg' < $HPLFLOWNET_ROOT'/configs/test_leon_FlyingThings3D_temp.yaml' > $TMPDIR'/'$TEST_FLYING_THINGS_3D_CONFIG
perl -p -i -e 's/\$\{([^}]+)\}/defined $ENV{$1} ? $ENV{$1} : $&/eg' < $HPLFLOWNET_ROOT'/configs/test_leon_KITTI_temp.yaml' > $TMPDIR'/'$TEST_KITTI_CONFIG
perl -p -i -e 's/\$\{([^}]+)\}/defined $ENV{$1} ? $ENV{$1} : $&/eg' < $HPLFLOWNET_ROOT'/configs/test_leon_RefRESH_temp.yaml' > $TMPDIR'/'$TEST_REFRESH_CONFIG
perl -p -i -e 's/\$\{([^}]+)\}/defined $ENV{$1} ? $ENV{$1} : $&/eg' < $HPLFLOWNET_ROOT'/configs/test_leon_FlyingThings3DPoses_temp.yaml' > $TMPDIR'/'$TEST_FLYING_THINGS_3D_POSES_CONFIG

# Test FlyingThings3D
cd $HPLFLOWNET_ROOT && python main.py $TMPDIR'/'$TEST_FLYING_THINGS_3D_CONFIG

# Test KITTI
cd $HPLFLOWNET_ROOT && python main.py $TMPDIR'/'$TEST_KITTI_CONFIG

# Test RefRESH
cd $HPLFLOWNET_ROOT && python main.py $TMPDIR'/'$TEST_REFRESH_CONFIG

# Test FlyingThings3DPoses
cd $HPLFLOWNET_ROOT && python main.py $TMPDIR'/'$TEST_FLYING_THINGS_3D_POSES_CONFIG
