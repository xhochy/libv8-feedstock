#!/bin/bash

set -euo pipefail
set -x

export LD_LIBRARY_PATH=$PREFIX/lib

if [[ $(uname) =~ .*Darwin.* ]]; then
  gn gen out.gn "--args=use_custom_libcxx=false clang_use_chrome_plugins=false v8_use_external_startup_data=false is_debug=false clang_base_path=\"${BUILD_PREFIX}\" mac_sdk_min=\"10.9\" use_system_xcode=false is_component_build=true mac_sdk_path=\"${CONDA_BUILD_SYSROOT}\" icu_use_system=true icu_include_dir=\"$PREFIX/include\" icu_lib_dir=\"$PREFIX/lib\" v8_use_snapshot=false"
elif [[ $(uname) =~ .*Linux.* ]]; then
  gn gen out.gn "--args=use_custom_libcxx=false clang_use_chrome_plugins=false v8_use_external_startup_data=false is_debug=false clang_base_path=\"${BUILD_PREFIX}\" is_component_build=true icu_use_system=true icu_include_dir=\"$PREFIX/include\" icu_lib_dir=\"$PREFIX/lib\" use_sysroot=false is_clang=false treat_warnings_as_errors=false fatal_linker_warnings=false"
  sed -i "s/ gcc/ ${HOST}-gcc/g" out.gn/toolchain.ninja
  sed -i "s/ g++/ ${HOST}-g++/g" out.gn/toolchain.ninja
  sed -i 's/deps = x86_64-conda_cos6-linux-gnu.*$//g' out.gn/toolchain.ninja
  sed -i 's/-Werror//g' out.gn/**/*.ninja
fi
ninja -C out.gn

mkdir -p $PREFIX/lib
cp out.gn/libv8*${SHLIB_EXT} $PREFIX/lib
mkdir -p $PREFIX/include
cp -r include/* $PREFIX/include/
