FROM jupyter/minimal-notebook:2023-04-17

ARG USER=jovyan


# useful software
USER root
RUN apt-get update && \
    apt-get -y install \
        ca-certificates curl \
        git vim screen \
        build-essential g++ && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
USER $USER
    
    
RUN mamba install -y -c conda-forge \
    nodejs=18 \
    cfitsio \
    jupyter-server-proxy sidecar \
    && \
    mamba clean -y --all


## install js9 first as root (not needed, but we want it in /opt/js9/)
ENV JS9_PATH=/opt/js9/
USER root
RUN git clone -b jh_updates --depth=1 https://github.com/zoghbi-a/js9.git /tmp/js9 \
 && cd /tmp/js9 \
 && ./configure --prefix=/usr/local \
        --with-helper=nodejs \
        --with-webdir=$JS9_PATH \
        --with-cfitsio=/opt/conda \
 && make \
 && make install \
 && rm -r /tmp/js9

RUN cd $JS9_PATH && \
    npm i socket.io uuid rimraf && \
    fix-permissions $JS9_PATH

## install jpyjs9 as a normal user
USER $USER
RUN pip install git+https://github.com/zoghbi-a/jpyjs9.git


# add jupyterhub for testing; Username and password are: jovyan, pass
RUN mamba install -y -c conda-forge jupyterhub
USER root
RUN chpasswd <<< "jovyan:pass"
USER $USER
