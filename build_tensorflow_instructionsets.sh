#!/bin/bash

## run this in the singularity container. 
 #chmod u+x build_tensorflow_instructionsets.sh
 #screen -S build
 #export tensorflowversion=v2.5.0 #must be a valid tag
 #export opt='mkl_only'
 #export bazel_output_base=$(mktemp -d -t -p /scratch/builds) #this avoids using NFS on ~ which is not recommended
 #export bazel_output
 #singularity exec --bind /scratch oras://ghcr.io/kaufman-lab/tensorflow_buildenvironment:v1 ./build_tensorflow_instructionsets.sh
 #note the singularity shell will try to inherit your current wd
 #singularity containers aren't writable
 #singularity containers mount your home directory by default

## the following variables need to be defined (note that singularity containers inherit exported variables)
 #export tensorflowversion=
 #export march=
 #export mtune=
 


if [ -z "$bazel_output_base" ]
then
      exit 1
fi


if [ -z "$tensorflowversion" ]
then
      exit 1
fi



if [ -z "$opt" ]
then
      exit 1
fi


#download tensorflow source
mkdir -p builds
cd builds
mkdir tensorflow$opt
cd tensorflow$opt

git clone https://github.com/tensorflow/tensorflow --depth 1 --branch $tensorflowversion tensorflow
cd tensorflow


## build and make wheel
#mavx is always on, consistent with the official tensorflow builds:

#i think -c opt means O2 is always on, presumbaly unless O3 is specified. https://stackoverflow.com/questions/50413978/what-is-the-difference-between-c-opt-and-copt-o3-in-bazel-build-or-gcc
#this means all of these are O2 unless otherwise specified
 #"Note: Starting with TensorFlow 1.6, binaries use AVX instructions which may not run on older CPUs."
 #https://software.intel.com/content/www/us/en/develop/articles/intel-optimization-for-tensorflow-installation-guide.html
 
if [ "$opt" = "mkl_only" ]; then     
    bazel --output_base $bazel_output_base build --cxxopt="-D_GLIBCXX_USE_CXX11_ABI=0" -c opt --copt=-mavx --copt=-mno-avx2 --copt=-mno-fma --copt=-mno-avx512f   \
    //tensorflow:libtensorflow.so
elif [ "$opt" = "nothing" ]; then
    bazel --output_base $bazel_output_base build --cxxopt="-D_GLIBCXX_USE_CXX11_ABI=0" -c opt --copt=-mavx --copt=-mno-avx2 --copt=-mno-fma --copt=-mno-avx512f  \
    //tensorflow:libtensorflow.so
elif [ "$opt" = "nothing_noAVX" ]; then
    bazel --output_base $bazel_output_base build --cxxopt="-D_GLIBCXX_USE_CXX11_ABI=0" -c opt --copt=-mno-avx --copt=-mno-avx2 --copt=-mno-fma --copt=-mno-avx512f  \
    //tensorflow:libtensorflow.so
elif [ "$opt" = "O3_only" ]; then
    bazel --output_base $bazel_output_base build --cxxopt="-D_GLIBCXX_USE_CXX11_ABI=0" -c opt --copt=-mavx --copt=-mno-avx2 --copt=-mno-fma --copt=-mno-avx512f --copt="-O3" \
    //tensorflow:libtensorflow.so
elif [ "$opt" = "AVX2_only" ]; then
    bazel --output_base $bazel_output_base build --cxxopt="-D_GLIBCXX_USE_CXX11_ABI=0" -c opt --copt=-mavx --copt=-mavx2 --copt=-mfma --copt=-mno-avx512f  \
    //tensorflow:libtensorflow.so  
elif [ "$opt" = "mkl_AVX2_only" ]; then
    bazel --output_base $bazel_output_base build --config=mkl --cxxopt="-D_GLIBCXX_USE_CXX11_ABI=0" -c opt --copt=-mavx --copt=-mavx2 --copt=-mfma --copt=-mno-avx512f  \
    //tensorflow:libtensorflow.so
elif [ "$opt" = "mkl_O3_only" ]; then
    bazel --output_base $bazel_output_base build --config=mkl --cxxopt="-D_GLIBCXX_USE_CXX11_ABI=0" -c opt --copt=-mavx --copt=-mno-avx2 --copt=-mno-fma --copt=-mno-avx512f --copt="-O3" \
    //tensorflow:libtensorflow.so
elif [ "$opt" = "nothingOs" ]; then
    bazel --output_base $bazel_output_base build --cxxopt="-D_GLIBCXX_USE_CXX11_ABI=0" --copt=-mavx --copt=-DNDEBUG --copt=-mavx --copt=-mno-avx2 --copt=-mno-fma --copt=-mno-avx512f --copt="-Os"  \
    //tensorflow:libtensorflow.so
else
  exit 1
fi
