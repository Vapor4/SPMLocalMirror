REFIX?=/usr/local
PROD_NAME=SPMLocalMirror
PROD_NAME_HOMEBREW=SPMLocalMirror

build:
	swift build -c release
build-for-linux:
	swift build -c release
install: build
	mkdir -p "$(PREFIX)/bin"
	cp -f ".build/release/SPMLocalMirror" "$(PREFIX)/bin/SPMLocalMirror"
run:
	.build/release/$(PROD_NAME)
