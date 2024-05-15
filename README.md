# DeepStream 7.0 with YOLOv9 - Detection and Segmentation

This project was developed using DeepStream SDK 7.0.<br>[DeepStream 7.0 is now supported on Windows WSL2](https://docs.nvidia.com/metropolis/deepstream/dev-guide/text/DS_on_WSL2.html), which greatly aids in application development.

This repo support Object Detection and Instance Segmentation

### Video Processed with DeepStream 7.0 and YOLOv9-Segmentation
[![YOLOv9 Segmentation](https://img.youtube.com/vi/v6OTjOFLNLA/0.jpg)](https://www.youtube.com/watch?v=v6OTjOFLNLA)


## Project Workflow Overview

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

2. You can [export your own custom YOLOv9 models](yolov9) to ONNX<br>

#### 2. Download or Build TensorRT lib `libnvinfer_plugin.so.8.6.1` with  custom TensorRT YoloNMS plugin.
The YoloNMS plugin is customized, being a modified version of the EfficientNMS plugin, with the addition of a layer called det_indices. The YoloNMS plugin needs to be compiled, or you can use a precompiled version provided, which should be installed.

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

#### 4. Install  `libnvinfer_plugin` with YoloNMS
```bash
cd TensorRTPlugin
./patch_libnvinfer.sh
cd ..
```

### 5. Build TRT Engine Files with trtexec 
Make sure that you've copied the ONNX models to the `models` directory in step 1. 

>Important: This step can take long time around ~15min per Model.

>Note: The model was exported with Dynamic Batch and Size, you can change it.

Optional flags: 
* `-b` -- batch_size (default is 1)
* `-n` -- network_size (default is 640)

```bash
cd models
./build_engine.sh 
cd ..
```

### 6.  Compile DeepStream Parse Functions
```bash
CUDA_VER=12.2 make -C nvdsinfer_yolo
```

### 7. Run Application
```bash
## Detection
deepstream-app -c deepstream_yolov9_det.txt

## Segmentation
deepstream-app -c deepstream_yolov9_mask.txt
```





