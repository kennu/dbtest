build:
	docker -H do.kfalck.net build -t dbtest .

run:
	docker -H do.kfalck.net run -t -i -p 9000:9000 -link=mongodb:mongo -name dbtest dbtest 

shell:
	docker -H do.kfalck.net run -t -i -p 9000:9000 -link=mongodb:mongo dbtest /bin/bash
