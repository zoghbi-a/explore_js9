FROM ubuntu

ARG USER=idies
ARG UID=1000
ENV HOME /home/${USER}


USER root
RUN adduser --uid ${UID} ${USER}
RUN chown -R ${UID} ${HOME}
#RUN chsh $USER -s bash


# useful software
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
    apt-get -y upgrade && \
    apt-get -y install \
        ca-certificates curl \
        git vim \
        build-essential g++ && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*



# conda 
RUN mkdir -p /opt && chown ${USER}:${USER} /opt
USER ${USER}
RUN curl https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -o /tmp/install-conda.sh && \
    bash /tmp/install-conda.sh -b -f -p /opt/conda

# needed to get conda to work properly
ENV BASH_ENV=~/.bashrc
RUN echo 'source /opt/conda/bin/activate' > ~/.bashrc
SHELL ["/bin/bash", "-c"]


# jupyter stuff
RUN conda install mamba -c conda-forge
RUN mamba install -c conda-forge \
        jupyter \
        jupyterlab \
        matplotlib \
        astropy \
        seaborn \
        emcee \
        scipy \
        numpy && \
    conda clean -y --all
# update bashrc to use base
RUN echo 'source /opt/conda/bin/activate base' > ~/.bashrc


# install stuff needed for js9
RUN mamba install -y -c conda-forge \
        nodejs=17 jupyter-server-proxy cfitsio && \
    mamba clean -y --all



# js9 and pyjs9 
RUN git clone https://github.com/ericmandel/js9.git /tmp/js9 && \
   cd /tmp/js9 && git reset --hard 5923975 && \
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

RUN cd /opt && \
    npm i http-proxy socket.io uuid rimraf && \
    npm cache clean --force

WORKDIR ${HOME}


ADD entrypoint.sh /entrypoint.sh
# ENTRYPOINT bash /entrypoint.sh


COPY jupyter_notebook_config.py /home/$USER/.jupyter/jupyter_notebook_config.py
RUN cp /opt/js9-web/js9.html /opt/js9-web/index.html

