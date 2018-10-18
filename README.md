While trying to put together a system image for mesh routing, one of
the mesh protocols (cjdns) turned out to not have native code admin tools.

Worse still, it had either nodejs or python tools.  Which is basically
only an issue because in the minimal system image I was using, only perl
was installed.

Target Environment
------------------

The normal runtime environment for this tool is a system with barely any
packages installed.  Thus, any perl feature that can normally be used by
installing a small package is probably not possible.

The simplest way to construct a test environment for checking if the tool
works is to debootstrap a small debian chroot:

    sudo debootstrap stretch outdir http://httpredir.debian.org/debian
    sudo mkdir -p outdir/cjdns_tool
    sudo cp -r cexec lib outdir/cjdns_tool
    sudo chroot outdir

