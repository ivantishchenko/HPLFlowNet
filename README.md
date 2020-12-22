# Self-Supervised Learning of Non-Rigid Residual Flow and Ego-Motion, 3DV 2020
This is the code for our [3DV 2020](http://www.3dv.org/) paper ["Self-Supervised Learning of Non-Rigid Residual Flow and Ego-Motion"](https://arxiv.org/abs/2009.10467), a method capable of supervised, hybrid and self-supervised learning of total scene flow from a pairt of point clouds. The code is developed and maintained by [Ivan Tishchenko](https://tishchenko.me/).

[[ArXiv](https://arxiv.org/abs/2009.10467)] [[Video](https://slideslive.com/38941127)]

## Citation
If you use this code for your research, please cite our paper:

**Self-Supervised Learning of Non-Rigid Residual Flow and Ego-Motion**,
*Ivan Tishchenko, Sandro Lombardi, Martin R. Oswald, Marc Pollefeys*, International Conference on 3D Vision (3DV) 2020

```bibtex
@article{tishchenko2020self,
  title={Self-Supervised Learning of Non-Rigid Residual Flow and Ego-Motion},
  author={Tishchenko, Ivan and Lombardi, Sandro and Oswald, Martin R and Pollefeys, Marc},
  journal={arXiv preprint arXiv:2009.10467},
  year={2020}
}
```

## Prerequisites
Our model is trained and tested under:
* Ubuntu 18.04
* Conda
* Python 3.6.4
* NVIDIA GPUs, CUDA 10.2, CuDNN 7.6
* PyTorch 1.5
* Numba 0.48
* You may need to install cffi.
* Mayavi for visualization. 

We provide our environement in [environment.yml](https://github.com/ivantishchenko/Self-Supervised_Flow_and_Ego-Motion/blob/master/environment.yml). After installing conda run the following commands to reproduce our environment:
```bash
conda env create -f environment.yml
conda activate hplfn
```

## Data preprocess
Our method works with 3 datasets:

### FlyingThings3D
Download and unzip the "Disparity", "Disparity Occlusions", "Disparity change", "Optical flow", "Flow Occlusions" for DispNet/FlowNet2.0 dataset subsets from the [FlyingThings3D website](https://lmb.informatik.uni-freiburg.de/resources/datasets/SceneFlowDatasets.en.html) (we used the paths from [this file](https://lmb.informatik.uni-freiburg.de/data/FlyingThings3D_subset/FlyingThings3D_subset_all_download_paths.txt), now they added torrent downloads)
. They will be upzipped into the same directory, `RAW_DATA_PATH`. Then run the following script for 3D reconstruction:

```bash
python data_preprocess/process_flyingthings3d_subset.py --raw_data_path RAW_DATA_PATH --save_path SAVE_PATH/FlyingThings3D_subset_processed_35m --only_save_near_pts
```

Next you need to match the camera posees from the full dataset to the subset DispNet/FlowNet2.0. Download the "Camera Data" for the full dataset from [FlyingThings3D website](https://lmb.informatik.uni-freiburg.de/resources/datasets/SceneFlowDatasets.en.html). Then execute the following:
```bash
tar -xvf flyingthings3d__camera_data.tar
# TAR_EXTRACT_PATH - directory where you extracted flyingthings3d__camera_data.tar
python data_preprocess/process_flyingthings3d_subset.py --poses TAR_EXTRACT_PATH --output SAVE_PATH/FlyingThings3D_subset_processed_35m 
```

**WARNING**: some frames in the full dataset are missing the corresponding camera poses. For the list of invalid frames refer to [POSE.txt](https://github.com/ivantishchenko/Self-Supervised_Non-Rigid_Flow_and_Ego-Motion/blob/master/data_preprocess/pose/POSE.txt). Our scripts discard these frames during pre-processing.

### KITTI Scene Flow 2015
Download and unzip [KITTI Scene Flow Evaluation 2015](http://www.cvlibs.net/download.php?file=data_scene_flow.zip) to directory `RAW_DATA_PATH`.
Run the following script for 3D reconstruction:

```bash
python data_preprocess/process_kitti.py RAW_DATA_PATH SAVE_PATH/KITTI_processed_occ_final
```

### RefRESH
Download ZIPs of all scenes from [RefRESH Google doc](https://drive.google.com/drive/folders/1Im1_ehSg4ALzeGctYGzvUv9KhcRlHXu_).
Unzip all of the scenes into the same directory, `RAW_DATA_PATH`. Then run the following script for 3D reconstruction:

```bash
python data_preprocess/process_refresh_rigidity.py --raw_data_path RAW_DATA_PATH --save_path SAVE_PATH/REFRESH_pc --only_save_near_pts
```

## Get started
Setup:
```bash
cd models; python build_khash_cffi.py; cd ..
```

### Train
Set `data_root` in the configuration file to `SAVE_PATH` in the data preprocess section. Then run
```bash
python main.py configs/train_xxx.yaml
```

### Test
Set `data_root` in the configuration file to `SAVE_PATH` in the data preprocess section. Set `resume` to be the path of your trained model or our trained model in `trained_models`. Then run
```bash
python main.py configs/test_xxx.yaml
```

Current implementation only supports `batch_size=1`.

### Visualization
If you set `TOTAL_NUM_SAMPLES` in `evaluation_bnn.py` to be larger than 0. Sampled results will be saved in a subdir of your checkpoint directory, `VISU_DIR`.

Use the following script to visualize:
```bash
python visualization.py -d VISU_DIR --relax
``` 

## Acknowledgments
The codebase is a fork based on an excellent work [HPLFlowNet](https://web.cs.ucdavis.edu/~yjlee/projects/cvpr2019-HPLFlowNet.pdf) by [Xiuye Gu](https://github.com/laoreja).
