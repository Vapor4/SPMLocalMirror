REFIX?=/usr/local
PROD_NAME=SPMLocalMirror
PROD_NAME_HOMEBREW=SPMLocalMirror

build:
	swift build --disable-sandbox -c release -Xswiftc -static-stdlib
build-for-linux:
	swift build --disable-sandbox -c release
install: build
	mkdir -p "$(PREFIX)/bin"
	cp -f ".build/release/SPMLocalMirror" "$(PREFIX)/bin/SPMLocalMirror"
run:
	.build/release/$(PROD_NAME)
