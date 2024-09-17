SHELL=/usr/bin/env bash

WD := $(shell pwd)
UFROM := /home/phil/uxn/uf-8/uf.rom
UXNCLI := /home/phil/build/uxn/uxncli

all: process

deps:
	git submodule update --init --recursive
	cd $(WD)/left && git checkout 46caefa8f27c819432a085078e6a509f6600b19c 

extract: deps
	sed '63,165!d' left/src/assets.tal > cream12.tal

process: extract
	uxncli $(UXNCLI) $(UFROM) < rom2uf2.f

clean:
	rm *.tal *.uf2 *.rom
