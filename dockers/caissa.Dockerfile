FROM ubuntu:24.04

ARG DEBIAN_FRONTEND=noninteractive

RUN apt update && apt-get -y install git make cmake wget curl gcc g++ clang llvm lld

# ------------------------------------------------------------------------------

# Force the cache to break, using CACHE_BUST = $(date +%s)
ARG CACHE_BUST

# ------------------------------------------------------------------------------

# Clone and build from master
RUN git clone --depth 1 --branch master https://github.com/Witek902/Caissa && \
    cd Caissa/ && \
    mkdir build && cd build && \
    cmake -DTARGET_ARCH=x64-avx512 -DCMAKE_BUILD_TYPE=Final .. && \
    make -j

CMD [ "./Caissa/build/bin/caissa" ]
