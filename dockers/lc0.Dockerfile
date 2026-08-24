FROM nvidia/cuda:12.9.2-devel-ubuntu24.04 AS builder

ENV DEBIAN_FRONTEND=noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN=true

WORKDIR /root

RUN apt-get update && \
    apt-get install -y \
    ninja-build \
    pkg-config \
    meson \
    zlib1g-dev \
    libhwloc-dev \
    libgoogle-perftools-dev \
    wget \
    git \
    python3-venv

RUN PATH="/$HOME/.local/bin:$PATH" && \
    git clone https://github.com/Menkib64/lc0/ && \
    cd lc0 && \
    git checkout tcec-season-30-swiss && \
    git submodule update --remote && \
    ln -s /usr/bin/python3 /usr/bin/python && \
    INSTALL_PREFIX=/root/.local ./build.sh release \
        -Dcutlass=true \
        -Dmalloc=tcmalloc \
        -Db_lto=true \
        -Dnative_arch=true \
        -Dpext=true \
        -Ddefault_library=static \
        -Ddefault_search="dag-preview" \
        -Dcc_cuda=80

FROM nvidia/cuda:12.9.2-runtime-ubuntu24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN=true

ARG TZ='America/Los_Angeles'

WORKDIR /root

COPY --from=builder /root/lc0/build/release /root/lc0

RUN echo $TZ > /etc/timezone && \
    apt-get update && \
    apt-get install -y wget libgomp1 libprotobuf-dev libgoogle-perftools-dev libhwloc15 libatomic1 && \
    apt purge git -y && \
    apt autoclean

WORKDIR /root/lc0

RUN wget https://storage.lczero.org/files/networks-contrib/big-transformers/t3-512x15x16h-distill2-swa-03477500.pb.gz

CMD [ "/root/lc0/./lc0", "--show-hidden" ]
