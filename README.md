# Self-Supervised Learning of Non-Rigid Residual Flow and Ego-Motion, 3DV 2020
This is the code for our [3DV 2020](http://www.3dv.org/) paper ["Self-Supervised Learning of Non-Rigid Residual Flow and Ego-Motion"](https://arxiv.org/abs/2009.10467), a method capable of supervised, hybrid and self-supervised learning of total scene flow from a pairt of point clouds. The code is developed and maintained by [Ivan Tishchenko](https://tishchenko.me/).

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

### FlyingThings3D
Download and unzip the "Disparity", "Disparity Occlusions", "Disparity change", "Optical flow", "Flow Occlusions" for DispNet/FlowNet2.0 dataset subsets from the [FlyingThings3D website](https://lmb.informatik.uni-freiburg.de/resources/datasets/SceneFlowDatasets.en.html) (we used the paths from [this file](https://lmb.informatik.uni-freiburg.de/data/FlyingThings3D_subset/FlyingThings3D_subset_all_download_paths.txt), now they added torrent downloads)
. They will be upzipped into the same directory, `RAW_DATA_PATH`. Then run the following script for 3D reconstruction:

```bash
python3 data_preprocess/process_flyingthings3d_subset.py --raw_data_path RAW_DATA_PATH --save_path SAVE_PATH/FlyingThings3D_subset_processed_35m --only_save_near_pts
```

### KITTI Scene Flow 2015
Download and unzip [KITTI Scene Flow Evaluation 2015](http://www.cvlibs.net/download.php?file=data_scene_flow.zip) to directory `RAW_DATA_PATH`.
Run the following script for 3D reconstruction:

```bash
python3 data_preprocess/process_kitti.py RAW_DATA_PATH SAVE_PATH/KITTI_processed_occ_final
```

### RefRESH
Download ZIPs of all scenes from [RefRESH Google doc](https://drive.google.com/drive/folders/1Im1_ehSg4ALzeGctYGzvUv9KhcRlHXu_).
Unzip all of the scenes into the same directory, `RAW_DATA_PATH`. Then run the following script for 3D reconstruction:

```bash
python3 data_preprocess/process_refresh_rigidity.py --raw_data_path RAW_DATA_PATH --save_path SAVE_PATH/REFRESH_pc --only_save_near_pts
```

## Get started
Setup:
```bash
cd models; python3 build_khash_cffi.py; cd ..
```

### Train
Set `data_root` in the configuration file to `SAVE_PATH` in the data preprocess section. Then run
```bash
python3 main.py configs/train_xxx.yaml
```

### Test
Set `data_root` in the configuration file to `SAVE_PATH` in the data preprocess section. Set `resume` to be the path of your trained model or our trained model in `trained_models`. Then run
```bash
python3 main.py configs/test_xxx.yaml
```

Current implementation only supports `batch_size=1`.

### Visualization
If you set `TOTAL_NUM_SAMPLES` in `evaluation_bnn.py` to be larger than 0. Sampled results will be saved in a subdir of your checkpoint directory, `VISU_DIR`.

Run
```bash
python3 visualization.py VISU_DIR
``` 

## Citation

If you use this code for your research, please cite our paper.


```
@article{tishchenko2020self,
  title={Self-Supervised Learning of Non-Rigid Residual Flow and Ego-Motion},
  author={Tishchenko, Ivan and Lombardi, Sandro and Oswald, Martin R and Pollefeys, Marc},
  journal={arXiv preprint arXiv:2009.10467},
  year={2020}
}
```
## Acknowledgments
The codebase is a fork based on an excellent work [HPLFlowNet](https://web.cs.ucdavis.edu/~yjlee/projects/cvpr2019-HPLFlowNet.pdf) by [Xiuye Gu](https://github.com/laoreja).
