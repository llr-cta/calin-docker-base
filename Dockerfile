FROM ubuntu:16.04

MAINTAINER sfegan@llr.in2p3.fr

RUN apt-get update -y && apt-get install -y                        \
    gcc-5                                                          \
    g++-5                                                          \
    make                                                           \
    git                                                            \
    wget                                                           \
    gsl-bin                                                        \
    libgsl0-dev                                                    \
    libfftw3-dev                                                   \
    libzmq3-dev                                                    \
    libpcre3-dev                                                   \
    libpcap-dev                                                    \
    libz-dev                                                       \
    python3                                                        \
    python3-dev                                                    \
    python3-numpy                                                  \
    ipython3                                                       \
    ipython3-notebook                                              \
    fftw3

ENV CC=gcc-5 CXX=g++-5

RUN mkdir /build &&                                                \
    cd /build &&                                                   \
    wget --no-check-certificate https://cmake.org/files/v3.5/cmake-3.5.2.tar.gz && \
    tar zxf cmake-3.5.2.tar.gz &&                                  \
    cd cmake-3.5.2 &&                                              \
    ./bootstrap  --parallel=2 --prefix=/usr &&                     \
    make -j2 &&                                                    \
    make install > /dev/null &&                                    \
    cd / &&                                                        \
    rm -rf /build

RUN mkdir /build &&                                                \
    cd /build &&                                                   \
    wget https://sourceforge.net/projects/swig/files/swig/swig-3.0.10/swig-3.0.10.tar.gz && \
    tar zxf swig-3.0.10.tar.gz &&                                  \
    cd swig-3.0.10 &&                                              \
    ./configure --prefix=/usr --without-alllang --with-python &&   \
    make -j2 &&                                                    \
    make install > /dev/null &&                                    \
    cd / &&                                                        \
    rm -rf /build

RUN mkdir /build &&                                                \
    cd /build &&                                                   \
    wget https://github.com/google/protobuf/releases/download/v3.0.0/protobuf-cpp-3.0.0.tar.gz && \
    tar zxf protobuf-cpp-3.0.0.tar.gz &&                           \
    cd protobuf-3.0.0 &&                                           \
    ./configure --prefix=/usr &&                                   \
    make -j2 &&                                                    \
    make install > /dev/null &&                                    \
    cd / &&                                                        \
    rm -rf /build

RUN mkdir /build &&                                                \
    cd /build &&                                                   \
    wget http://geant4.cern.ch/support/source/geant4.10.02.p02.tar.gz && \
    tar zxf geant4.10.02.p02.tar.gz &&                             \
    cd geant4.10.02.p02 &&                                         \
    mkdir mybuild &&                                               \
    cd mybuild &&                                                  \
    cmake -DCMAKE_C_COMPILER=$CC -DCMAKE_CXX_COMPILER=$CXX -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr -DGEANT4_INSTALL_DATA=ON .. && \
    make -j2 &&                                                    \
    make install > /dev/null &&                                    \
    cd / &&                                                        \
    rm -rf /build

ADD build_cameras_to_actl.sh /build/

RUN apt-get update -y && apt-get install -y                        \
    python3-matplotlib                                             \
    sqlite3                                                        \
    libsqlite3-dev                                                 \
    python3-pip &&                                                 \
    pip3 install --upgrade pip &&                                  \
    pip3 install jupyter

RUN ipython3 profile create default &&                             \
    jupyter notebook --generate-config

ADD ipython_notebook_config.py /root/.ipython/profile_default/
ADD ipython_kernel_config.py /root/.ipython/profile_default/
ADD jupyter_notebook_config.py  /root/.jupyter/

# Pre-run annoying step to build font cache
RUN echo %pylab | ipython3

# Now build CamerasToACTL manually with :
#   docker run -t -i xxxxxxxxxxxx /bin/bash /build/build_cameras_to_actl.sh
