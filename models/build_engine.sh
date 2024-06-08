#!/bin/bash

# Default values
batch_size=1
network_size=640
precision=fp16

# Parse command line options
while getopts ":b:n:" opt; do
  case ${opt} in
    b )
      batch_size=$OPTARG
      ;;
    n )
      network_size=$OPTARG
      ;;
    p )
      precision=$OPTARG
      ;;
    \? )
      echo "Use: $0 [-b batch_size] [-n network_size] [-p precision]"
      exit 1
      ;;
  esac
done
shift $((OPTIND -1))

export batch_size

find . -maxdepth 1 -type f -name '*.onnx' | while read -r file; do
    filename=$(basename "$file" .onnx)
    trtexec \
    --onnx=${filename}.onnx \
    --${precision} \
    --saveEngine=${filename}.engine \
    --timingCacheFile=${filename}.engine.timing.cache \
    --warmUp=500 \
    --duration=10  \
    --useCudaGraph \
    --useSpinWait \
    --noDataTransfers \
    --minShapes=images:1x3x${network_size}x${network_size} \
    --optShapes=images:${batch_size}x3x${network_size}x${network_size} \
    --maxShapes=images:${batch_size}x3x${network_size}x${network_size}
done
