# DeepStream / YOLOv9 - Detection and Segmentation

This project was developed using DeepStream SDK 7.0.<br>[DeepStream 7.0 is now supported on Windows WSL2](https://docs.nvidia.com/metropolis/deepstream/dev-guide/text/DS_on_WSL2.html), which greatly aids in application development.


This project combines the power of DeepStream 7, the latest and most advanced real-time video analytics platform, with the precision and efficiency of YOLOv9, the cutting-edge in object detection and instance segmentation. 

With DeepStream 7, we unlock the full potential of real-time video processing, providing an unparalleled video analytics experience.

YOLOv9 signifies a monumental leap forward in real-time object detection, introducing revolutionary methodologies like Programmable Gradient Information (PGI) and the Generalized Efficient Layer Aggregation Network (GELAN). This cutting-edge model showcases extraordinary enhancements in efficiency, accuracy, and adaptability, establishing unprecedented benchmarks on the MS COCO dataset.

This repo support Object Detection and Instance Segmentation

### Video Processed with DeepStream 7.0 and YOLOv9-Segmentation
[![YOLOv9 Segmentation](https://img.youtube.com/vi/v6OTjOFLNLA/0.jpg)](https://www.youtube.com/watch?v=v6OTjOFLNLA)


# Project Workflow 

This project involves several important steps as outlined below:

### Clone Repo
```bash
git clone https://github.com/levipereira/deepstream-yolov9.git
cd deepstream-yolov9
git submodule update --init --recursive
```


#### 1. Download or Export your own Custom Models

Choose one option:

1. Download Models
    YOLOv9-C Detection/Segmentation models pre-trained on the COCO Dataset are available in this repository, exported in ONNX format.

    ```bash
    cd models
    ./download_models.sh
    cd ..
    ```
    ## Models Download 

    ### Detection
    | Model | Test Size | AP<sup>val</sup> | AP<sub>50</sub><sup>val</sup> | AP<sub>75</sub><sup>val</sup> | Param. | FLOPs |
    | :-- | :-: | :-: | :-: | :-: | :-: | :-: |
    | [**YOLOv9-T**](https://github.com/WongKinYiu/yolov9/releases/download/v0.1/yolov9-t-converted.pt) | 640 | **38.3%** | **53.1%** | **41.3%** | **2.0M** | **7.7G** |
    | [**YOLOv9-S**](https://github.com/WongKinYiu/yolov9/releases/download/v0.1/yolov9-s-converted.pt) | 640 | **46.8%** | **63.4%** | **50.7%** | **7.1M** | **26.4G** |
    | [**YOLOv9-M**](https://github.com/WongKinYiu/yolov9/releases/download/v0.1/yolov9-m-converted.pt) | 640 | **51.4%** | **68.1%** | **56.1%** | **20.0M** | **76.3G** |
    | [**YOLOv9-C**](https://github.com/WongKinYiu/yolov9/releases/download/v0.1/yolov9-c-converted.pt) | 640 | **53.0%** | **70.2%** | **57.8%** | **25.3M** | **102.1G** |

    ### Instance Segmentation
    | Model | Test Size | Param. | FLOPs | AP<sup>box</sup> | AP<sup>mask</sup>  |
    | :-- | :-: | :-: | :-: | :-: | :-: |
    | [**YOLOv9-C-SEG**]() | 640 | 27.4M | 145.5G | **53.3%** | **43.5%** |
 

2. You can [export your own custom YOLOv9 models](yolov9) to ONNX<br>

#### 2. Required Only for Instance Segmentation Models. 
 Download or Build TensorRT lib `libnvinfer_plugin.so.8.6.1` with  custom TensorRT EfficientNMSX plugin.
The EfficientNMSX plugin is customized, being a modified version of the EfficientNMS plugin, with the addition of a layer called det_indices. The EfficientNMSX plugin needs to be compiled, or you can use a precompiled version provided, which should be installed.

Choose one option:
1. Download  
    ```bash
    cd TensorRTPlugin
    wget https://github.com/levipereira/deepstream-yolov9/releases/download/v1.0/libnvinfer_plugin.so.8.6.1
    cd ..
    ```
2. Build Plugin from source code [TensorRTPlugin](TensorRTPlugin) (This can take a long time)

#### 3. **Run Deepstream Container**
```bash
sudo docker pull nvcr.io/nvidia/deepstream:7.0-triton-multiarch
```
Start the docker container from `deepstream-yolov9` dir:

```bash
sudo  docker run \
        -it \
        --privileged \
        --rm \
        --name=deepstream_yolov9 \
        --net=host \
        --gpus all \
        -e DISPLAY=$DISPLAY \
        -e CUDA_CACHE_DISABLE=0 \
        --device /dev/snd \
        -v /tmp/.X11-unix/:/tmp/.X11-unix \
        -v `pwd`:/apps/deepstream-yolov9 \
        -w /apps/deepstream-yolov9 \
        nvcr.io/nvidia/deepstream:7.0-triton-multiarch
```

#### 4. Install  `libnvinfer_plugin` with plugin TRT_EfficientNMSX (Required Only for Instance Segmentation Models)
```bash
cd TensorRTPlugin
./patch_libnvinfer.sh
cd ..
```

### 5.  Compile DeepStream Parse Functions
```bash
CUDA_VER=12.2 make -C nvdsinfer_yolo
```

### 6. Run Application
```bash
## Detection
deepstream-app -c deepstream_yolov9_det.txt

## Segmentation
deepstream-app -c deepstream_yolov9_mask.txt
```
>**The first run may take up to 15 minutes due to the building Engine File with FP16 precision.**

During this process, it may seem like it's stuck on the following line.
```
WARNING: [TRT]: onnx2trt_utils.cpp:374: Your ONNX model has been generated with INT64 weights, while TensorRT does not natively support INT64. Attempting to cast down to INT32.
```
Please be patient and wait for it to complete.


# Optional

## Dynamic Shapes Batch Size Support
This implementation supports dynamic shapes and dynamic batch sizes. To modify these settings, change the following configurations:
 
[config_pgie_yolo9_det.txt](https://github.com/levipereira/deepstream-yolov9/blob/master/config_pgie_yolov9_det.txt#L8-L9)  <br>
[config_pgie_yolov9_mask.txt](https://github.com/levipereira/deepstream-yolov9/blob/master/config_pgie_yolov9_mask.txt#L8-L10)
```
batch-size=1
infer-dims=3;640;640
```



## Build TRT Engine Files with trtexec  
**This also can be used to Perfomance Tests**

This will avoid to create TRT Engine File on each execution.

>Important: This step can take long time around ~15min per Model.
>Note: The model was exported with Dynamic Batch and Size, you can change it.

Optional flags: 
* `-b` -- batch_size (default is 1)
* `-n` -- network_size (default is 640)
* `-p` -- precision fp32/fp16/int8 (default fp32)
```bash

cd models
./build_engine.sh 
cd ..
```
Change in config_pgie files accordingly <br>
[config_pgie_yolo9_det.txt](https://github.com/levipereira/deepstream-yolov9/blob/master/config_pgie_yolov9_det.txt#L8-L9)  <br>
[config_pgie_yolov9_mask.txt](https://github.com/levipereira/deepstream-yolov9/blob/master/config_pgie_yolov9_mask.txt#L8-L10)
```plaintext
batch-size=1
infer-dims=3;640;640
# 0: FP32 1: INT8 2: FP16
network-mode=0
```
 



