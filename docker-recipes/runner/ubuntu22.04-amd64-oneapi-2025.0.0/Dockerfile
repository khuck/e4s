FROM ubuntu:22.04 as base

ARG DEBIAN_FRONTEND=noninteractive
ARG ONEAPI_VERSION=2025.0
ENV TZ=America/Los_Angeles

RUN apt update -y \
 && apt upgrade -y

RUN apt install -y gpg-agent wget ca-certificates \
    && wget -O- https://apt.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS.PUB | \
       gpg --dearmor | tee /usr/share/keyrings/oneapi-archive-keyring.gpg > /dev/null \
    && echo "deb [signed-by=/usr/share/keyrings/oneapi-archive-keyring.gpg] https://apt.repos.intel.com/oneapi all main" | \
       tee /etc/apt/sources.list.d/oneAPI.list \
    && . /etc/os-release \
    && wget -qO - https://repositories.intel.com/gpu/intel-graphics.key | \
       gpg --yes --dearmor --output /usr/share/keyrings/intel-graphics.gpg \
    && echo "deb [arch=amd64 signed-by=/usr/share/keyrings/intel-graphics.gpg] https://repositories.intel.com/gpu/ubuntu ${VERSION_CODENAME}/lts/2350 unified" | \
       tee /etc/apt/sources.list.d/intel-gpu-${VERSION_CODENAME}.list \
    && apt update -y \
    && apt install -y intel-oneapi-compiler-fortran-${ONEAPI_VERSION} \
         intel-oneapi-compiler-dpcpp-cpp-${ONEAPI_VERSION} \
         intel-opencl-icd \
         intel-level-zero-gpu \
         intel-media-va-driver-non-free \
         libmfx1 \
         libigc-dev \
         intel-igc-cm \
         libigdfcl-dev \
         libigfxcmrt-dev \
         level-zero-dev \
         clinfo \
         libdrm-dev

RUN apt install -y \
 intel-oneapi-mkl-devel \
 intel-oneapi-mpi-devel

RUN apt install -y \
  autoconf \
  automake \
  bzip2 \
  cpio \
  curl \
  emacs-nox \
  file \
  findutils \
  g++ \
  gcc \
  gettext \
  gfortran \
  git \
  gpg \
  iputils-ping \
  jq \
  libffi-dev \
  libssl-dev \
  libudev-dev \
  libxml2-dev \
  locales \
  locate \
  m4 \
  make \
  mercurial \
  ncurses-dev \
  patch \
  pciutils \
  python3-pip \
  rsync \
  unzip \
  uuid-runtime \
  vim \
  wget \
  zlib1g-dev \
  && apt autoremove --purge \
  && apt clean
 
RUN locale-gen en_US.UTF-8 \
 && ln -s /usr/bin/gpg /usr/bin/gpg2 \
 && ln -s `which python3` /usr/bin/python

RUN python -m pip install --upgrade pip setuptools wheel \
 && python -m pip install gnureadline pyyaml pytz minio requests clingo \
 && python -m pip install urllib3 \
 && python -m pip install boto3 botocore \
 && rm -rf ~/.cache

ENV BOOTSTRAP_DIR=/usr/local/spack-tools

COPY /spack.yaml /spack.yaml.pre

RUN envsubst < spack.yaml.pre > spack.yaml \
 && rm spack.yaml.pre

FROM base as complete

RUN export S=/tmp/spack \
 && git clone https://github.com/spack/spack $S \
 && git -C $S checkout b5b5130bedcf5a5165cfef2e4e3a30dc1ac0f7ef \
 && . $S/share/spack/setup-env.sh \
 && export SPACK_DISABLE_LOCAL_CONFIG=1 \
 && spack config add 'config:build_stage:$spack/build_stage' \
 && spack config add "config:db_lock_timeout:120" \
 && spack config add "config:connect_timeout:60" \
 && spack mirror add bootstrap https://cache.e4s.io/spack-bootstrap \
 && spack buildcache keys -it \
 && spack -e . concretize -f | tee concretize.log \
 && spack -e . install --cache-only \ 
 && spack clean -a \
 && rm -rf $S spack.yaml spack.lock concretize.log .spack-env Makefile ~/.spack

RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
 && unzip awscliv2.zip \
 && ./aws/install \
 && rm -rf awscliv2.zip

RUN ./opt/intel/oneapi/modulefiles-setup.sh --output-dir=/opt/intel/oneapi/modulefiles

RUN echo export PATH=$BOOTSTRAP_DIR/view/bin:'${PATH}' >> /etc/bash.bashrc \
 && echo . $(find $BOOTSTRAP_DIR -type f -name bash) >> /etc/bash.bashrc \
 && mkdir -p /modules \
 && echo module use /modules >> /etc/bash.bashrc \
 && echo module use /opt/intel/oneapi/modulefiles/ >> /etc/bash.bashrc \
 && echo module load mpi >> /etc/bash.bashrc

ENV PATH=/opt/intel/oneapi/compiler/${ONEAPI_VERSION}/bin:/opt/intel/oneapi/mpi/2021.14/bin:$BOOTSTRAP_DIR/view/bin:$PATH
ENV LD_LIBRARY_PATH=/opt/intel/oneapi/compiler/${ONEAPI_VERSION}/lib:/opt/intel/oneapi/mpi/2021.14/lib:$LD_LIBRARY_PATH

RUN echo /opt/intel/oneapi/compiler/${ONEAPI_VERSION}/lib >> /etc/ld.so.conf.d/oneapi.conf \
 && echo /opt/intel/oneapi/mpi/2021.14/lib >> /etc/ld.so.conf.d/oneapi.conf \
 && ldconfig -v

RUN updatedb

CMD ["/bin/bash"]

ENV LANGUAGE=en_US:en \
    LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8
