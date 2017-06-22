
NAME := cjdns_tool
INSTALLROOT := installdir
INSTALLBIN := $(INSTALLROOT)/usr/local/bin
INSTALLLIB := $(INSTALLROOT)/usr/local/lib/site_perl

describe := $(shell git describe --dirty)
tarfile := $(NAME)-$(describe).tar.gz

all: test

build_dep:
	aptitude install perl

install: clean
	mkdir -p $(INSTALLBIN)
	cp -pr cexec $(INSTALLBIN)

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

