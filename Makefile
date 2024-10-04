SHELL=env bash

WD := $(shell pwd)
UFROM := /boot/home/uxn/uf-8/uf.rom
UXNDIR := /bin

all: getcream run

deps:
	git submodule update --init --recursive
	cd $(WD)/left && git checkout 46caefa8f27c819432a085078e6a509f6600b19c 

getcream: deps
	sed '63,165!d' left/src/assets.tal > cream12.tal
	$(UXNDIR)/uxnasm cream12.tal cream12.bin
	rm -f *.tal *.sym

run:
	-$(UXNDIR)/uxnemu $(UFROM) < text.f

clean:
	rm -f *.tal *.uf2 *.bin *.sym
