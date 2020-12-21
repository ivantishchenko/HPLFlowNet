#!/bin/bash
# install bare minimum packages to run HPLFN

module load python_gpu/3.6.4

pip3 install torch torchvision
pip3 install numba --user
pip3 install cffi
pip3 install imageio --user
pip3 install tensorboard --user