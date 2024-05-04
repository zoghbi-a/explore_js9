
## Content
explore_js9 a repo that illustartes how to setup js9 and jpyjs9 to run inside a Docker conatiner.

The image starts with `jupyter/minimal-notebook`, so it is easy to launch a jupyterlab server.
The important parts are installing `js9` and `jpyjs9`.

The image also install `jupyterhub`, so the testing include both a simple jupyterlab as well as jupyterhub server.


## Build
Build the image with:
```sh
make build
```
This is create an image with tag `js9`

## Run
### JupyterLab
```sh
make run-lab
```
This runs jupyterlab server on port 8888, which is exposed at 8885.

### JupyterHub
```sh
make run-hub
```
This runs jupyterhub server on port 8000, which is also exposed at 8885. The username and password are: jovyan/pass