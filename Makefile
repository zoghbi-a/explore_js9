

build:
	docker build --network=host -t js9:latest .
	docker images -q -f dangling=true | xargs --no-run-if-empty docker rmi -f
   
    
    
run:
	docker run -it -p 8885:8000 js9:latest bash
