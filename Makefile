SHELL=/usr/bin/env bash

WD := $(shell pwd)
UFROM := /home/phil/uxn/uf-8/uf.rom
UXNDIR := /home/phil/build/uxn

all: process

deps:
	git submodule update --init --recursive
	cd $(WD)/left && git checkout 46caefa8f27c819432a085078e6a509f6600b19c 

extract: deps
	sed '63,165!d' left/src/assets.tal > cream12.tal
	$(UXNDIR)/uxnasm cream12.tal cream12.bin

process: extract
	-$(UXNDIR)/uxncli $(UFROM) < bin2uf2.f
	rm *.tal *.bin *.sym

clean:
	rm *.tal *.uf2 *.bin *.sym
