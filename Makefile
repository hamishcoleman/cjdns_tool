
NAME := cjdns_tool
INSTALLROOT := installdir
INSTALLBIN := $(INSTALLROOT)/usr/local/bin
INSTALLLIB := $(INSTALLROOT)/usr/local/lib/site_perl

describe := $(shell git describe --dirty)
tarfile := $(NAME)-$(describe).tar.gz

all: test

build_dep:
	aptitude install perl libdevel-cover-perl

install: clean
	mkdir -p $(INSTALLBIN)
	cp -pr cexec $(INSTALLBIN)
	mkdir -p $(INSTALLLIB)/mini/Digest/
	mkdir -p $(INSTALLLIB)/Stream/
	cp -pr lib/mini/Data.pm $(INSTALLLIB)/mini/
	cp -pr lib/mini/Digest/SHA.pm $(INSTALLLIB)/mini/Digest/
	cp -pr lib/Stream/String.pm $(INSTALLLIB)/Stream/
	cp -pr lib/Bencode_bork.pm $(INSTALLLIB)/
	cp -pr lib/RPC.pm $(INSTALLLIB)/

tar: $(tarfile)

$(tarfile):
	$(MAKE) install
	tar -v -c -z -C $(INSTALLROOT) -f $(tarfile) .

clean:
	rm -rf $(INSTALLROOT)

cover:
	cover -delete
	-COVER=true $(MAKE) test
	cover

test:
	./test_harness

