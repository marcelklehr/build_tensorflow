#!/bin/bash

export tensorflowversion=v2.5.0 #must be a valid tag
export bazel_output_base="$(pwd)/bazel"

mkdir -p $bazel_output_base

export opt='mkl_only'
./build_tensorflow_instructionsets.sh

export opt='nothing'
./build_tensorflow_instructionsets.sh

export opt='O3_only'
./build_tensorflow_instructionsets.sh

export opt='AVX2_only'
./build_tensorflow_instructionsets.sh

export opt='mkl_AVX2_only'
./build_tensorflow_instructionsets.sh

export opt='mkl_O3_only'
./build_tensorflow_instructionsets.sh

export opt='nothingOs'
./build_tensorflow_instructionsets.sh


export march='cascadelake'
export mtune='cascadelake'
./build_tensorflow_architecture.sh


export march='skylake'
export mtune='skylake'
./build_tensorflow_architecture.sh


export march='skylake-avx512'
export mtune='skylake-avx512'
./build_tensorflow_architecture.sh
