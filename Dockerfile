FROM ubuntu:16.04

MAINTAINER sfegan@llr.in2p3.fr

RUN apt-get update -y && apt-get install -y \
    gcc-5              \
    g++-5              \
    make               \
    git                \
    wget               \
    gsl-bin            \
    libgsl0-dev        \
    libfftw3-dev       \
    libzmq3-dev        \
    libpcre3-dev       \
    python3            \
    python3-dev        \
    python3-numpy      \
    ipython3           \
    ipython3-notebook  \
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
