

build:
	docker build --network=host -t js9:v0.1 .
	docker images -q -f dangling=true | xargs --no-run-if-empty docker rmi -f
   
    
    
run:
	docker run -it -p 8885:8888 js9:v0.1 
