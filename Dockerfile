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
    python3-scipy                                                  \
    python3-pip                                                    \
    fftw3                                                          \
    python3-matplotlib                                             \
    sqlite3                                                        \
    libsqlite3-dev

ENV CC=gcc-5 CXX=g++-5

RUN pip3 install --upgrade pip &&                                  \
    pip3 install jupyter

RUN ipython3 profile create default &&                             \
    jupyter notebook --generate-config &&                          \
    jupyter nbextension enable --py --sys-prefix widgetsnbextension && \
    sed -i -e '/c.NotebookApp.ip/s/^#//'                          \
           -e '/c.NotebookApp.ip/s/localhost/*/'                 \
           -e '/c.NotebookApp.open_browser/s/^#//'                \
           -e '/c.NotebookApp.open_browser/s/True/False/'         \
           -e '/c.NotebookApp.ip/s/localhost/*/'                 \
           -e '/c.NotebookApp.token/s/^#//'                       \
       /root/.jupyter/jupyter_notebook_config.py

# Pre-run annoying step to build font cache
RUN echo %pylab | ipython3

RUN mkdir /build &&                                                \
    cd /build &&                                                   \
    wget --no-check-certificate https://cmake.org/files/v3.7/cmake-3.7.1.tar.gz && \
    tar zxf cmake-3.7.1.tar.gz &&                                  \
    cd cmake-3.7.1 &&                                              \
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
    wget https://github.com/google/protobuf/releases/download/v3.1.0/protobuf-cpp-3.1.0.tar.gz && \
    tar zxf protobuf-cpp-3.1.0.tar.gz &&                           \
    cd protobuf-3.1.0 &&                                           \
    ./configure --prefix=/usr &&                                   \
    make -j2 &&                                                    \
    make install > /dev/null &&                                    \
    cd / &&                                                        \
    rm -rf /build

RUN mkdir /build &&                                                \
    cd /build &&                                                   \
    wget http://geant4.cern.ch/support/source/geant4.10.03.tar.gz && \
    tar zxf geant4.10.03.tar.gz &&                             \
    cd geant4.10.03 &&                                         \
    mkdir mybuild &&                                               \
    cd mybuild &&                                                  \
    cmake -DCMAKE_C_COMPILER=$CC -DCMAKE_CXX_COMPILER=$CXX -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr -DGEANT4_INSTALL_DATA=ON .. && \
    make -j2 &&                                                    \
    make install > /dev/null &&                                    \
    cd / &&                                                        \
    rm -rf /build

ADD build_cameras_to_actl.sh /build/

# Add Geant 4 environment variables
ENV G4DATADIR=/usr/share/Geant4-10.3/data
ENV G4NEUTRONHPDATA=$G4DATADIR/G4ABLA3.0                           \
    G4LEDATA=$G4DATADIR/G4EMLOW6.50                                \
    G4LEVELGAMMADATA=$G4DATADIR/PhotonEvaporation4.3               \
    G4RADIOACTIVEDATA=$G4DATADIR/RadioactiveDecay5.1               \
    G4NEUTRONXSDATA=$G4DATADIR/G4NEUTRONXS1.4                      \
    G4PIIDATA=$G4DATADIR/G4PII1.3                                  \
    G4REALSURFACEDATA=$G4DATADIR/RealSurface1.0                    \
    G4SAIDXSDATA=$G4DATADIR/G4SAIDDATA1.1                          \
    G4ABLADATA=$G4DATADIR/G4ABLA3.0                                \
    G4ENSDFSTATEDATA=$G4DATADIR/G4ENSDFSTATE2.1

# Now build CamerasToACTL manually with :
#   docker run -t -i xxxxxxxxxxxx /bin/bash /build/build_cameras_to_actl.sh
