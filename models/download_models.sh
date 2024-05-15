#!/bin/bash

# Array of file URLs to download
#"https://github.com/levipereira/deepstream-yolov9/releases/download/v1.0/gelan-c-det-trt.onnx"
#"https://github.com/levipereira/deepstream-yolov9/releases/download/v1.0/gelan-c-seg-trt.onnx"

urls=(
    "https://github.com/levipereira/deepstream-yolov9/releases/download/v1.0/yolov9-c-converted-trt.onnx"
    "https://github.com/levipereira/deepstream-yolov9/releases/download/v1.0/yolov9-c-seg-converted-trt.onnx"
)

# Destination directory
destination="./"

# Download files
for url in "${urls[@]}"; do
    wget -P "$destination" "$url"
done

echo "Downloads complete."