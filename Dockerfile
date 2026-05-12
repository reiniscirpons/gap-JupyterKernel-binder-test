FROM ghcr.io/gap-system/gap:4.15.1-full
USER root

# Install build prerequisites

RUN apt-get clean        && \
    apt-get update --yes && \
    apt-get install --no-install-recommends --quiet --yes \
      python3 \
      python3-pip \
      build-essential autoconf libtool pkg-config \
      curl graphviz

# Compile Semigroups package

RUN cd "/opt/gap/gap-4.15.1/pkg/semigroups" \
    && ./configure \
    && make -j10

# Install Jupyter

RUN python3 -m pip install --no-cache jupyterlab jupyter-server notebook

# Compile GAP Kernel extension

ENV NODE_VERSION=16.13.0
ENV NVM_DIR="/root/.nvm"
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.4/install.sh | bash
RUN . "$NVM_DIR/nvm.sh" && nvm install ${NODE_VERSION}
RUN . "$NVM_DIR/nvm.sh" && nvm use v${NODE_VERSION}
RUN . "$NVM_DIR/nvm.sh" && nvm alias default v${NODE_VERSION}

ENV PATH="$NVM_DIR/versions/node/v${NODE_VERSION}/bin/:${PATH}"

RUN rm -rf "/opt/gap/gap-4.15.1/pkg/jupyterkernel"
RUN cd "/opt/gap/gap-4.15.1/pkg/" \
    && git clone https://github.com/gap-packages/JupyterKernel \
    && cd JupyterKernel \
    && git fetch origin \
    && git checkout c2a5894c2701e53d4136a0d5089c7b7072ff3851 \
    && python3 -m pip install .

# Install libsemigroups_pybind11

RUN python3 -m pip install --no-cache libsemigroups_pybind11

RUN userdel gap
ARG NB_USER
ARG NB_UID
ENV USER ${NB_USER}
ENV HOME /home/${NB_USER}

RUN adduser --disabled-password \
    --gecos "Default user" \
    --uid ${NB_UID} \
    ${NB_USER}
WORKDIR ${HOME}
COPY ./index.ipynb ${HOME}/index.ipynb
USER ${USER}
