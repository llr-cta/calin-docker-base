# calin-docker-base - Build base filesystem for calin on Docker, including
#                     all required libraries and configuration files.
#
# Stephen Fegan - sfegan@gmail.com - 2017-01-10
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

# Build version : ubuntu18.04_v1.22

# docker build . --build-arg camerastoactl_password=XXXX --tag llrcta/calin-docker-base:ubuntu18.04_v1.19

FROM ubuntu:18.04 as intermediate

MAINTAINER sfegan@llr.in2p3.fr

RUN apt-get update -y && apt-get install -y                        \
        make                                                       \
        git                                                        \
        wget                                                       \
        gsl-bin                                                    \
        libgsl0-dev                                                \
        libfftw3-dev                                               \
        libzmq3-dev                                                \
        libpcre3-dev                                               \
        libpcap-dev                                                \
        libz-dev                                                   \
        python3                                                    \
        python3-dev                                                \
        python3-pip                                                \
        fftw3                                                      \
        sqlite3                                                    \
        libsqlite3-dev                                             \
        libxerces-c-dev                                            \
        vim

#ENV CC=gcc CXX=g++

RUN pip3 install numpy scipy matplotlib jupyter

# Pre-run annoying step to build font cache
RUN echo "import matplotlib.font_manager ; matplotlib.font_manager._rebuild()" | ipython3

RUN mkdir /build &&                                                \
    cd /build &&                                                   \
    wget --no-check-certificate https://cmake.org/files/v3.12/cmake-3.12.3.tar.gz && \
    tar zxf cmake-3.12.3.tar.gz &&                                 \
    cd cmake-3.12.3 &&                                             \
    ./bootstrap  --parallel=2 --prefix=/usr &&                     \
    make -j2 &&                                                    \
    make install > /dev/null &&                                    \
    cd / &&                                                        \
    rm -rf /build

RUN mkdir /build &&                                                \
    cd /build &&                                                   \
    wget https://sourceforge.net/projects/swig/files/swig/swig-3.0.12/swig-3.0.12.tar.gz && \
    tar zxf swig-3.0.12.tar.gz &&                                  \
    cd swig-3.0.12 &&                                              \
    ./configure --prefix=/usr --without-alllang --with-python &&   \
    make -j2 &&                                                    \
    make install > /dev/null &&                                    \
    cd / &&                                                        \
    rm -rf /build

RUN mkdir /build &&                                                \
    cd /build &&                                                   \
    wget https://github.com/protocolbuffers/protobuf/releases/download/v3.6.1/protobuf-cpp-3.6.1.tar.gz && \
    tar zxf protobuf-cpp-3.6.1.tar.gz &&                           \
    cd protobuf-3.6.1 &&                                           \
    ./configure --prefix=/usr &&                                   \
    make -j2 &&                                                    \
    make install > /dev/null &&                                    \
    cd / &&                                                        \
    rm -rf /build

RUN mkdir /build &&                                                \
    cd /build &&                                                   \
    wget http://geant4.cern.ch/support/source/geant4.10.04.p02.tar.gz && \
    tar zxf geant4.10.04.p02.tar.gz &&                              \
    cd geant4.10.04.p02 &&                                          \
    mkdir mybuild &&                                               \
    cd mybuild &&                                                  \
    cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr -DGEANT4_INSTALL_DATA=ON .. && \
    make -j2 &&                                                    \
    make install > /dev/null &&                                    \
    cd / &&                                                        \
    rm -rf /build

RUN ipython3 profile create default &&                             \
    jupyter notebook --allow-root --generate-config &&             \
    jupyter nbextension enable --py --sys-prefix widgetsnbextension && \
    sed -i -e '/c.NotebookApp.ip/s/^#//'                           \
           -e '/c.NotebookApp.ip/s/localhost/0.0.0.0/'                   \
           -e '/c.NotebookApp.open_browser/s/^#//'                 \
           -e '/c.NotebookApp.open_browser/s/True/False/'          \
           -e '/c.NotebookApp.token/s/^#//'                        \
           -e '/c.NotebookApp.token/s/<generated>//'               \
           -e '/c.NotebookApp.allow_root/s/^#//'                   \
           -e '/c.NotebookApp.allow_root/s/False/True/'            \
       /root/.jupyter/jupyter_notebook_config.py

RUN pip3 install ipyparallel

RUN mkdir /data

# Add Geant 4 environment variables
ENV G4DATADIR=/usr/share/Geant4-10.4.2/data
ENV G4ABLADATA=$G4DATADIR/G4ABLA3.1                                \
    G4LEDATA=$G4DATADIR/G4EMLOW7.3                                 \
    G4ENSDFSTATEDATA=$G4DATADIR/G4ENSDFSTATE2.2                    \
    G4NEUTRONHPDATA=$G4DATADIR/G4NDL4.5                            \
    G4NEUTRONXSDATA=$G4DATADIR/G4NEUTRONXS1.4                      \
    G4PIIDATA=$G4DATADIR/G4PII1.3                                  \
    G4SAIDXSDATA=$G4DATADIR/G4SAIDDATA1.1                          \
    G4LEVELGAMMADATA=$G4DATADIR/PhotonEvaporation5.2               \
    G4RADIOACTIVEDATA=$G4DATADIR/RadioactiveDecay5.2               \
    G4REALSURFACEDATA=$G4DATADIR/RealSurface2.1.1

# Limit OMP threads to one - otherwise FFTs go crazy
ENV OMP_NUM_THREADS=1

FROM intermediate as camerastoactl_download

ARG camerastoactl_password

RUN mkdir /build &&                                                \
    cd /build &&                                                   \
    git clone https://sfegan:${camerastoactl_password}@github.com/llr-cta/CamerasToACTL.git

FROM intermediate

COPY --from=camerastoactl_download /build /build

RUN cd /build &&                                                   \
    cd CamerasToACTL &&                                            \
    mkdir mybuild &&                                               \
    cd mybuild &&                                                  \
    cmake -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Release .. && \
    make -j2 &&                                                    \
    make install > /dev/null &&                                    \
    cd / &&                                                        \
    rm -rf /build

# Set default to bash so that Jupyter uses it for new terminals
ENV SHELL=/bin/bash

CMD ["/bin/bash"]
