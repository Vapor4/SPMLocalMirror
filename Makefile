prefix ?= /usr/local
bindir = $(prefix)/bin
libdir = $(prefix)/lib

build:
	swift build -c release --disable-sandbox

install: build
	install ".build/release/SPMLocalMirror" "$(bindir)"
	install ".build/release/libswiftCore.dylib" "$(libdir)"
	install_name_tool -change \
		".build/x86_64-apple-macosx10.10/release/libswiftCore.dylib" \
		"$(libdir)/libswiftCore.dylib" \
		"$(bindir)/SPMLocalMirror"

uninstall:
	rm -rf "$(bindir)/SPMLocalMirror"
	rm -rf "$(libdir)/libswiftCore.dylib"

clean:
	rm -rf .build

.PHONY: build install uninstall clean
