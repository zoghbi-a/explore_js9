

build:
	docker build --network=host -t js9:latest .
	docker images -q -f dangling=true | xargs --no-run-if-empty docker rmi -f
   
    
    
run-lab:
	docker run -it --rm -p 8885:8888 js9:latest

run-hub:
	docker run -it --rm -p 8885:8000 js9:latest jupyterhub
