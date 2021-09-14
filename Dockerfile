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

# Build version : ubuntu20.04_v1.37

# docker build . --tag llrcta/calin-docker-base:ubuntu20.04_v1.37

FROM ubuntu:20.04

MAINTAINER sfegan@llr.in2p3.fr

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update -y && apt-get install -y                        \
        cmake                                                      \
        git                                                        \
        make                                                       \
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
        python3-numpy                                              \
        python3-scipy                                              \
        python3-matplotlib                                         \
        cython3                                                    \
        ipython3                                                   \
        jupyter-notebook                                           \
        fftw3                                                      \
        sqlite3                                                    \
        libsqlite3-dev                                             \
        libxerces-c-dev                                            \
        vim                                                        \
        curl                                                       \
        libcurl4                                                   \
        libcurl4-openssl-dev                                       \
        ffmpeg                                                     \
        libgeos-dev                                                \
        libgeos++-dev                                              \
        libhdf5-dev                                                \
        hdf5-tools                                                 \
        libjpeg-dev                                                \
        libnetcdf-dev                                              \
        netcdf-bin                                                 \
        netcdf-doc                                                 \
        proj-bin                                                   \
        libproj-dev                                                \
        libopenjp2-7                                               \
        libopenjp2-7-dev                                           \
        libopenjp2-tools                                           \
        zstd                                                       \
        libzstd-dev                                                \
        swig                                                       \
        libprotobuf-c-dev                                          \
        protobuf-c-compiler                                        \
        libprotobuf-dev                                            \
        protobuf-compiler                                          \
        libprotoc-dev

#ENV CC=gcc CXX=g++

RUN pip3 install ipyparallel ipywidgets cdsapi ecmwf-api-client

# Pre-run annoying step to build font cache
# RUN echo "import matplotlib.font_manager ; matplotlib.font_manager._rebuild()" | ipython3

ENV G4DATADIR=/usr/share/Geant4-10.7.2/data

RUN G4URL=http://geant4-data.web.cern.ch/datasets &&                          \
    mkdir -p $G4DATADIR &&                                                    \
    curl -L $G4URL/G4NDL.4.6.tar.gz | tar -C $G4DATADIR -zxf - &&             \
    curl -L $G4URL/G4EMLOW.7.13.tar.gz | tar -C $G4DATADIR -zxf - &&          \
    curl -L $G4URL/G4PhotonEvaporation.5.7.tar.gz | tar -C $G4DATADIR -zxf - &&\
    curl -L $G4URL/G4RadioactiveDecay.5.6.tar.gz | tar -C $G4DATADIR -zxf - && \
    curl -L $G4URL/G4SAIDDATA.2.0.tar.gz | tar -C $G4DATADIR -zxf - &&        \
    curl -L $G4URL/G4PARTICLEXS.3.1.1.tar.gz | tar -C $G4DATADIR -zxf - &&    \
    curl -L $G4URL/G4ABLA.3.1.tar.gz | tar -C $G4DATADIR -zxf - &&            \
    curl -L $G4URL/G4INCL.1.0.tar.gz | tar -C $G4DATADIR -zxf - &&            \
    curl -L $G4URL/G4PII.1.3.tar.gz | tar -C $G4DATADIR -zxf - &&             \
    curl -L $G4URL/G4ENSDFSTATE.2.3.tar.gz | tar -C $G4DATADIR -zxf - &&      \
    curl -L $G4URL/G4RealSurface.2.2.tar.gz | tar -C $G4DATADIR -zxf - &&     \
    curl -L $G4URL/G4TENDL.1.3.2.tar.gz | tar -C $G4DATADIR -zxf -

RUN curl -L https://github.com/llr-cta/Geant4Build/releases/download/ubuntu-20.04-10.7.2/Geant4-ubuntu-20.04-10.7.2.tbz2 | tar -jxf - -C /

RUN ipython3 profile create default &&                             \
    jupyter notebook --allow-root --generate-config &&             \
    sed -i -e '/c.NotebookApp.ip/s/^#//'                           \
           -e '/c.NotebookApp.ip/s/localhost/*/'                   \
           -e '/c.NotebookApp.allow_origin =/s/^#//'               \
           -e "/c.NotebookApp.allow_origin =/s/''/'*'/"            \
           -e '/c.NotebookApp.open_browser/s/^#//'                 \
           -e '/c.NotebookApp.open_browser/s/True/False/'          \
           -e '/c.NotebookApp.allow_root/s/^#//'                   \
           -e '/c.NotebookApp.allow_root/s/False/True/'            \
       /root/.jupyter/jupyter_notebook_config.py

RUN pip3 install https://github.com/SciTools/cartopy/archive/refs/tags/v0.19.0.post1.tar.gz

RUN mkdir /build &&                                                \
    cd /build &&                                                   \
    wget https://confluence.ecmwf.int/download/attachments/45757960/eccodes-2.22.1-Source.tar.gz && \
    tar zxf eccodes-2.22.1-Source.tar.gz &&                        \
    cd eccodes-2.22.1-Source &&                                    \
    mkdir build &&                                                 \
    cd build &&                                                    \
    cmake -DENABLE_FORTRAN=FALSE -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr .. && \
    make -j2 &&                                                    \
    make install > /dev/null &&                                    \
    cd / &&                                                        \
    rm -rf /build

RUN mkdir /data

# Add Geant 4 environment variables
ENV G4NEUTRONHPDATA="$G4DATADIR/G4NDL4.6"                          \
    G4LEDATA="$G4DATADIR/G4EMLOW7.13"                              \
    G4LEVELGAMMADATA="$G4DATADIR/PhotonEvaporation5.7"             \
    G4RADIOACTIVEDATA="$G4DATADIR/RadioactiveDecay5.6"             \
    G4PARTICLEXSDATA="$G4DATADIR/G4PARTICLEXS3.1.1"                \
    G4PIIDATA="$G4DATADIR/G4PII1.3"                                \
    G4REALSURFACEDATA="$G4DATADIR/RealSurface2.2"                  \
    G4SAIDXSDATA="$G4DATADIR/G4SAIDDATA2.0"                        \
    G4ABLADATA="$G4DATADIR/G4ABLA3.1"                              \
    G4INCLDATA="$G4DATADIR/G4INCL1.0"                              \
    G4ENSDFSTATEDATA="$G4DATADIR/G4ENSDFSTATE2.3"

# Limit OMP threads to one - otherwise FFTs go crazy
ENV OMP_NUM_THREADS=1

RUN wget https://github.com/llr-cta/CamerasToACTLRelease/releases/download/latest/CamerasToACTL.tgz && \
    tar zxf CamerasToACTL.tgz -C / &&                              \
    rm -f CamerasToACTL.tgz

RUN pip3 install --upgrade google-api-python-client google-auth-httplib2 google-auth-oauthlib

# Set default to bash so that Jupyter uses it for new terminals
ENV SHELL=/bin/bash

CMD ["/bin/bash"]
