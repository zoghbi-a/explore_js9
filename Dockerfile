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



# js9 and pyjs9 
ENV JS9_WEB_PATH=/opt/js9-web/
USER root
RUN git clone -b jh_updates --depth=1 https://github.com/zoghbi-a/js9.git /tmp/js9 && \
    cd /tmp/js9 && \
    ./configure --prefix=/usr/local \
        --with-helper=nodejs \
        --with-webdir=$JS9_WEB_PATH \
        --with-cfitsio=/opt/conda && \
    make && \
    make install

# ADD js9prefs.js index.html /opt/js9-web/
RUN cd $JS9_WEB_PATH && \
    npm i socket.io uuid rimraf && \
    fix-permissions $JS9_WEB_PATH

USER $USER

# jupyter-server-proxy fix to get sockets to work
RUN git clone -b js9-fix --depth=1 https://github.com/zoghbi-a/jupyter-server-proxy.git /tmp/jupyter-server-proxy \
 && pip install /tmp/jupyter-server-proxy \
 && git clone -b socket-fix --depth=1 https://github.com/zoghbi-a/pyjs9.git /tmp/pyjs9 \
 && pip install /tmp/pyjs9 \
 && git clone --depth=1 https://github.com/zoghbi-a/jpyjs9.git /tmp/jpyjs9 \
 && pip install /tmp/jpyjs9 \
 && rm -rf /tmp/jupyter-server-proxy /tmp/pyjs9 /tmp/pyjs9

#COPY --chown=1000:1000 jpyjs9 jpyjs9
#RUN pip install ./jpyjs9

# add jupyterhub
RUN mamba install -y -c conda-forge jupyterhub
USER root
RUN chpasswd <<< "jovyan:pass"
USER $USER