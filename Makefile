#
# Copyright (C) 2018 Hamish Coleman <hamish@zot.org>
#

NAME := cjdnstool
INSTALLROOT := installdir
INSTALLBIN := $(INSTALLROOT)/usr/bin
INSTALLLIB := $(INSTALLROOT)/usr/share/perl5

describe := $(shell git describe --dirty --always)
tarfile := $(NAME)-$(describe).tar.gz

all: test

build_dep:
	aptitude install perl libdevel-cover-perl

install: clean
	mkdir -p $(INSTALLBIN)
	cp -pr cexec $(INSTALLBIN)
	mkdir -p $(INSTALLLIB)/mini/Digest/
	mkdir -p $(INSTALLLIB)/Stream/
	mkdir -p ${INSTALLLIB}/Cjdns/
	cp -pr lib/mini/Data.pm $(INSTALLLIB)/mini/
	cp -pr lib/mini/Digest/SHA.pm $(INSTALLLIB)/mini/Digest/
	cp -pr lib/Stream/String.pm $(INSTALLLIB)/Stream/
	cp -pr lib/Bencode_bork.pm $(INSTALLLIB)/
	cp -pr lib/Cjdns/RPC.pm $(INSTALLLIB)/Cjdns
	cp -pr lib/Cjdns/Addr.pm $(INSTALLLIB)/Cjdns

tar: $(tarfile)

$(tarfile):
	$(MAKE) install
	tar -v -c -z -C $(INSTALLROOT) -f $(tarfile) .

clean:
	rm -rf $(INSTALLROOT)

distclean: clean

cover:
	cover -delete
	-COVER=true $(MAKE) test
	cover

test:
	./test_harness

