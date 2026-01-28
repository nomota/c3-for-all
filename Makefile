build:
	@c3c compile-only src/*.c3

clean:
	@rm -rf ./obj/*
	@rm -rf ./src/obj/*

push:
	@make clean
	@git add .
	@git commit -m "update"
	@git push origin main

pull:
	@git pull origin main
