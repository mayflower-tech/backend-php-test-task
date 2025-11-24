baseUrl = http://host.docker.internal:8088/v1/statistics
wrkImage = elswork/wrk
wrkCommand = docker run --rm --volume $(CURDIR):/wrk -w /wrk $(wrkImage) -t12 -c20 -d5s
composerCommand = docker run --rm --volume $(CURDIR):/app --interactive composer:2.8.6 composer

up: composer-install
	docker compose up -d --build

down:
	docker compose stop

composer-install:
	$(composerCommand) install

composer-update:
	$(composerCommand) update

curl-post:
	curl -X POST -H "Content-Type: application/json" -d '{"countryCode": "ru"}' http://localhost:8088/v1/statistics

curl-error:
	curl -X POST -H "Content-Type: application/json" -d '{"countryCode": "wrongCountry"}' http://localhost:8088/v1/statistics

curl-get:
	curl -H "Content-Type: application/json" http://localhost:8088/v1/statistics

unit-test:
	docker run --rm \
    	--volume $(CURDIR):/app \
    	--workdir /app \
    	--interactive \
    	php:8.4-cli \
    	./vendor/bin/phpunit --testdox tests

load-test: load-test-post load-test-get

wrk-pull:
	docker pull $(wrkImage)

load-test-post: wrk-pull
	$(wrkCommand) -s ./tests/load/countries.lua $(baseUrl)

load-test-get: wrk-pull
	$(wrkCommand) $(baseUrl)

archive:
	git archive --format=zip --output="archive.zip" HEAD

unarchive:
	unzip -o archive.zip
	