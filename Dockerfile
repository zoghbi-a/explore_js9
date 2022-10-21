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
        cfitsio && \
    mamba install -y -c conda-forge \
        nodejs=17 \
        emcee \
        jupyter-server-proxy \
        sidecar && \
    mamba clean -y --all
# update bashrc to use base
RUN echo 'source /opt/conda/bin/activate base' > ~/.bashrc




# js9 and pyjs9 
RUN git clone https://github.com/zoghbi-a/js9.git /tmp/js9 && \
   cd /tmp/js9 && git checkout jh_updates && \
   \
   pip install git+https://github.com/ericmandel/pyjs9.git@f5db48d4b4486236eb3f97221bc54a0dc8f4d81f

RUN cd /tmp/js9 && \
    ./configure --prefix=/opt/js9 \
        --with-helper=nodejs \
        --with-webdir=/opt/js9-web \
        --with-cfitsio=/opt/conda && \
    make && \
    make install && \
    printf "\n# js9\nexport PATH=/opt/js9/bin:\$PATH\n" >> ~/.bashrc

WORKDIR ${HOME}

ADD entrypoint.sh /entrypoint.sh
# ENTRYPOINT bash /entrypoint.sh



ENV SHELL=/usr/bin/bash

ADD jupjs9 jupjs9
ADD js9prefs.js /opt/js9-web/
USER root
RUN chown -R $USER:$USER jupjs9 /opt/js9-web
USER $USER
RUN cp -r jupjs9/index.html  /opt/js9-web/
