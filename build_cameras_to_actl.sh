#!/bin/bash

cd /build &&                                                   \
git clone https://github.com/llr-cta/CamerasToACTL.git &&      \
cd CamerasToACTL &&                                            \
mkdir mybuild &&                                               \
cd mybuild &&                                                  \
cmake -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Release .. && \
make -j2 &&                                                    \
make install > /dev/null &&                                    \
cd / &&                                                        \
rm -rf /build
