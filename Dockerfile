FROM ghcr.io/gap-system/gap:4.15.1-full

USER root

RUN apt-get clean        && \
    apt-get update --yes && \
    apt-get install --no-install-recommends --quiet --yes \
      python3 \
      python3-pip

USER gap

ENV PATH="/opt/gap/.local/bin/:${PATH}"

RUN python3 -m pip install jupyterlab==3.* jupyter-server==1.* notebook==6.*

# RUN cd "$HOME/gap-4.15.1/pkg/jupyterkernel" \
#     && python3 -m pip install . --user
