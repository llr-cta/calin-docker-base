FROM ubuntu:16.04
MAINTAINER sfegan@llr.in2p3.fr
RUN apt-get update -y && apt-get install -y gcc-5 git wget cmake gsl-bin libgsl0-dev libfftw3-dev libzmq3-dev python3 python3-dev python3-numpy ipython3 ipython3-notebook fftw3
ENV CC=gcc-5 CXX=g++-5

#EXE apt-get install gcc-5
