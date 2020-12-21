#!/bin/bash

# Allocate ~ 130 GB scratch for FlyingThings3D + KITTI
# Allocate ~ 540 GB scratch for RefRESH + KITTI
# Allocate ~ 665 GB scratch for all 3 datasets

# Example usage:

# Params:
# -r  Absolute path to the checkpoint

# Training from an existing checkpoint
# bsub -W 360:00 -n2 \
#   -R rusage[mem=10000,scratch=665000,ngpus_excl_p=1] \
#   -R "select[gpu_model0==TeslaV100_SXM2_32GB]" \
#   ./test.sh -r $SCRATCH/checkpoints/train/leon_FlyingThings3D/model_best.pth.tar

. constants.env

eval "$(conda shell.bash hook)"
conda activate base

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

HPLFLOWNET_ROOT=$HOME'/ddr/third_party/hplflownet'
# Test configs
TEST_FLYING_THINGS_3D_CONFIG='test_FlyingThings3D.yaml'
TEST_KITTI_CONFIG='test_KITTI.yaml'
TEST_REFRESH_CONFIG='test_RefRESH.yaml'
TEST_FLYING_THINGS_3D_POSES_CONFIG='test_FlyingThings3DPoses.yaml'

# generate timestamp
#export DATE=$(date '+%Y-%m-%d_%H-%M-%S')
export DATE=$(date +%s)

# Extract test dataset
printf "\nExtracting KITTI PC dataset\n\n"
tar -xvf $SCRATCH/$KITTI_TAR -C $TMPDIR
printf "\nExtracting FlyingThings3D PC dataset\n\n"
tar -xvf $SCRATCH/$FLYING_THINGS_3D_TAR -C $TMPDIR
printf "\nExtracting RefRESH PC dataset\n\n"
tar -xvf $SCRATCH/$REFRESH_TAR -C $TMPDIR
printf "\nExtracting FlyingThings3DPoses PC dataset\n\n"
tar -xvf $SCRATCH/$FLYING_THINGS_3D_POSES_TAR -C $TMPDIR

# Prepare TEST configs
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