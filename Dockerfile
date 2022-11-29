FROM ubuntu

ARG USER=idies
ARG UID=1000
ENV HOME /home/${USER}


USER root
RUN adduser --uid ${UID} ${USER}
RUN chown -R ${UID} ${HOME}
RUN chsh $USER -s /usr/bin/bash


# useful software
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
    apt-get -y upgrade && \
    apt-get -y install \
        ca-certificates curl \
        git vim screen \
        build-essential g++ && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*



# conda 
RUN mkdir -p /opt && chown ${USER}:${USER} /opt
USER ${USER}
RUN curl https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -o /tmp/install-conda.sh && \
    bash /tmp/install-conda.sh -b -f -p /opt/conda && \
    rm /tmp/install-conda.sh

# needed to get conda to work properly
ENV BASH_ENV=~/.bashrc
RUN echo 'source /opt/conda/bin/activate' > ~/.bashrc
SHELL ["/bin/bash", "-c"]


# jupyter stuff
RUN conda install mamba -c conda-forge
RUN mamba install -y \
        jupyter \
        jupyterlab \
        matplotlib \
        astropy \
        seaborn \
        scipy \
        numpy \
        && \
    mamba clean -y --all
# update bashrc to use base
RUN echo 'source /opt/conda/bin/activate base' > ~/.bashrc

WORKDIR ${HOME}
ENV SHELL=/usr/bin/bash


USER root
# entrypoint
RUN echo 'jupyter lab --ip 0.0.0.0 --no-browser --debug --ServerApp.token="" --ServerApp.password=""' >\
    /entrypoint.sh
USER $USER
    
    
RUN mamba install -y -c conda-forge \
    nodejs=18 \
    cfitsio \
    jupyter-server-proxy sidecar \
    websockify \
    && \
    mamba clean -y --all



# js9 and pyjs9 
USER root
RUN git clone -b jh_updates --depth=1 https://github.com/zoghbi-a/js9.git /tmp/js9 && \
    cd /tmp/js9 && \
    ./configure --prefix=/usr/local \
        --with-helper=nodejs \
        --with-webdir=/opt/js9-web \
        --with-cfitsio=/opt/conda && \
    make && \
    make install
USER $USER

RUN pip install git+https://github.com/ericmandel/pyjs9.git@f5db48d4b4486236eb3f97221bc54a0dc8f4d81f

ADD js9prefs.js index.html /opt/js9-web/
ADD run_websockify.sh /usr/local/bin/
ADD proxy.js .

ADD jupjs9 jupjs9
RUN cd jupjs9 && pip install . && cd ..
USER root
RUN chmod +x /usr/local/bin/run_websockify.sh
RUN chown -R $USER:$USER $HOME /opt/js9-web
USER $USER
