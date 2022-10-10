export SHELL=/bin/bash 

jupyter lab --ip 0.0.0.0 --no-browser --debug --NotebookApp.token="" --NotebookApp.password="" 2>&1 | tee /tmp/lab-log

