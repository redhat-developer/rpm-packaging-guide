.. SPDX-License-Identifier:    CC-BY-SA-4.0

.. _appendix:

Appendix
========

Here you will find supplementary information that is very good to know and will
likely prove to helpful for anyone who is going to be building RPMs in an
serious capacity but isn't necessarily a hard requirement to learn how to
package RPMs in the first place which is what the main goal of this document is.

Mock
----

"`Mock`_ is a tool for building packages. It can build packages for different
architectures and different Fedora or RHEL versions than the build host has.
Mock creates chroots and builds packages in them. Its only task is to reliably
populate a chroot and attempt to build a package in that chroot.

Mock also offers a multi-package tool, mockchain, that can build chains of
packages that depend on each other.

Mock is capable of building SRPMs from source configuration management if the
mock-scm package is present, then building the SRPM into RPMs. See --scm-enable
in the documentation." (From the upstream documentation)

.. note::
    In order to use `Mock`_ on a RHEL or CentOS system, you will need to enable
    the "Extra Packages for Enterprise Linux" (`EPEL`_) repository. This is
    a repository provided by the `Fedora`_ community and has many useful tools
    for RPM Packagers, systems administrators, and developers.

One of the most common use cases RPM Packagers have for `Mock`_ is to create
what is known as a "pristine build environment". By using mock as a "pristine
build environment", nothing about the current state of your system has an
effect on the RPM Package itself. Mock uses different configurations to specify
what the build "target" is, these are found on your system in the ``/etc/mock/``
directory (once you've installed the ``mock`` package). You can build for
different distributions or releases just by specifying it on the command line.
Something to keep in mind is that the configuration files the come with mock are
targeted at Fedora RPM Packagers and as such RHEL and CentOS release versions
are labeled as "epel" because that is the "target" repository these RPMs would
be built for. You simply specify the configuration you want to use (minus the
``.cfg`` file extension). For example, you could build our ``cello`` example
for both RHEL 7 and Fedora 23 using the following commands without ever having
to use different machines.

::

    $ mock -r epel-7-x86_64 ~/rpmbuild/SRPMS/cello-1.0-1.el7.src.rpm

    $ mock -r fedora-23-x86_64 ~/rpmbuild/SRPMS/cello-1.0-1.el7.src.rpm

One example of why you might want to use mock is if you were packaging RPMs on
your laptop and you had a package installed (we'll call it ``foo`` for this
example) that was a ``BuildRequires`` of that package you were creating but
forgot to actually make the ``BuildRequires: foo`` entry. The build would
succeed when you run ``rpmbuild`` because ``foo`` was needed to build and it was
found on the system at build time. However, if you took the SRPM to another
system that lacked ``foo`` it would fail, causing an unexpected side effect.
`Mock`_ solves this by first parsing the contents of the SRPM and installing the
``BuildRequires`` into it's `chroot`_ which means that if you were missing the
``BuildRequires`` entry the build would fail because mock would not know to
install it and it would therefore not be present in the buildroot.

Another example is the opposite scenario, let's say you need ``gcc`` to build
a package but don't have it installed on your system (which is unlikely as a RPM
Packager, but just for the sake of the example let us pretend that is true).
With `Mock`_, you don't have to install ``gcc`` on your system because it will
get installed in the chroot as part of mock's process.

Below is an example of attempting to rebuild a package that has a dependency
that I'm missing on my system. The key thing to note is that while ``gcc`` is
commonly on most RPM Packager's systems, some RPM Packages can have over a dozen
``BuildRequires`` and this allows you to not need to clutter up your workstation
with otherwise un-needed or un-necessary packages.

::

    $ rpmbuild --rebuild ~/rpmbuild/SRPMS/cello-1.0-1.el7.src.rpm
    Installing /home/admiller/rpmbuild/SRPMS/cello-1.0-1.el7.src.rpm
    error: Failed build dependencies: gcc is needed by cello-1.0-1.el7.x86_64

    $ mock -r epel-7-x86_64 ~/rpmbuild/SRPMS/cello-1.0-1.el7.src.rpm
    INFO: mock.py version 1.2.17 starting (python version = 2.7.5)...
    Start: init plugins
    INFO: selinux enabled
    Finish: init plugins
    Start: run
    INFO: Start(/home/admiller/rpmbuild/SRPMS/cello-1.0-1.el7.src.rpm)  Config(epel-7-x86_64)
    Start: clean chroot
    Finish: clean chroot
    Start: chroot init
    INFO: calling preinit hooks
    INFO: enabled root cache
    Start: unpacking root cache
    Finish: unpacking root cache
    INFO: enabled yum cache
    Start: cleaning yum metadata
    Finish: cleaning yum metadata
    Mock Version: 1.2.17
    INFO: Mock Version: 1.2.17
    Start: yum update
    base                                                                    | 3.6 kB  00:00:00
    epel                                                                    | 4.3 kB  00:00:00
    extras                                                                  | 3.4 kB  00:00:00
    updates                                                                 | 3.4 kB  00:00:00
    No packages marked for update
    Finish: yum update
    Finish: chroot init
    Start: build phase for cello-1.0-1.el7.src.rpm
    Start: build setup for cello-1.0-1.el7.src.rpm
    warning: Could not canonicalize hostname: rhel7
    Building target platforms: x86_64
    Building for target x86_64
    Wrote: /builddir/build/SRPMS/cello-1.0-1.el7.centos.src.rpm
    Getting requirements for cello-1.0-1.el7.centos.src
     --> Already installed : gcc-4.8.5-4.el7.x86_64
     --> Already installed : 1:make-3.82-21.el7.x86_64
    No uninstalled build requires
    Finish: build setup for cello-1.0-1.el7.src.rpm
    Start: rpmbuild cello-1.0-1.el7.src.rpm
    Building target platforms: x86_64
    Building for target x86_64
    Executing(%prep): /bin/sh -e /var/tmp/rpm-tmp.v9rPOF
    + umask 022
    + cd /builddir/build/BUILD
    + cd /builddir/build/BUILD
    + rm -rf cello-1.0
    + /usr/bin/gzip -dc /builddir/build/SOURCES/cello-1.0.tar.gz
    + /usr/bin/tar -xf -
    + STATUS=0
    + '[' 0 -ne 0 ']'
    + cd cello-1.0
    + /usr/bin/chmod -Rf a+rX,u+w,g-w,o-w .
    Patch #0 (cello-output-first-patch.patch):
    + echo 'Patch #0 (cello-output-first-patch.patch):'
    + /usr/bin/cat /builddir/build/SOURCES/cello-output-first-patch.patch
    patching file cello.c
    + /usr/bin/patch -p0 --fuzz=0
    + exit 0
    Executing(%build): /bin/sh -e /var/tmp/rpm-tmp.UxRVtI
    + umask 022
    + cd /builddir/build/BUILD
    + cd cello-1.0
    + make -j2
    gcc -o cello cello.c
    + exit 0
    Executing(%install): /bin/sh -e /var/tmp/rpm-tmp.K3i2dL
    + umask 022
    + cd /builddir/build/BUILD
    + '[' /builddir/build/BUILDROOT/cello-1.0-1.el7.centos.x86_64 '!=' / ']'
    + rm -rf /builddir/build/BUILDROOT/cello-1.0-1.el7.centos.x86_64
    ++ dirname /builddir/build/BUILDROOT/cello-1.0-1.el7.centos.x86_64
    + mkdir -p /builddir/build/BUILDROOT
    + mkdir /builddir/build/BUILDROOT/cello-1.0-1.el7.centos.x86_64
    + cd cello-1.0
    + /usr/bin/make install DESTDIR=/builddir/build/BUILDROOT/cello-1.0-1.el7.centos.x86_64
    mkdir -p /builddir/build/BUILDROOT/cello-1.0-1.el7.centos.x86_64/usr/bin
    install -m 0755 cello /builddir/build/BUILDROOT/cello-1.0-1.el7.centos.x86_64/usr/bin/cello
    + /usr/lib/rpm/find-debuginfo.sh --strict-build-id -m --run-dwz --dwz-low-mem-die-limit 10000000 --dwz-max-die-limit 110000000 /builddir/build/BUILD/cello-1.0
    extracting debug info from /builddir/build/BUILDROOT/cello-1.0-1.el7.centos.x86_64/usr/bin/cello
    dwz: Too few files for multifile optimization
    /usr/lib/rpm/sepdebugcrcfix: Updated 0 CRC32s, 1 CRC32s did match.
    + /usr/lib/rpm/check-buildroot
    + /usr/lib/rpm/redhat/brp-compress
    + /usr/lib/rpm/redhat/brp-strip-static-archive /usr/bin/strip
    + /usr/lib/rpm/brp-python-bytecompile /usr/bin/python 1
    + /usr/lib/rpm/redhat/brp-python-hardlink
    + /usr/lib/rpm/redhat/brp-java-repack-jars
    Processing files: cello-1.0-1.el7.centos.x86_64
    Executing(%license): /bin/sh -e /var/tmp/rpm-tmp.vxtAuO
    + umask 022
    + cd /builddir/build/BUILD
    + cd cello-1.0
    + LICENSEDIR=/builddir/build/BUILDROOT/cello-1.0-1.el7.centos.x86_64/usr/share/licenses/cello-1.0
    + export LICENSEDIR
    + /usr/bin/mkdir -p /builddir/build/BUILDROOT/cello-1.0-1.el7.centos.x86_64/usr/share/licenses/cello-1.0
    + cp -pr LICENSE /builddir/build/BUILDROOT/cello-1.0-1.el7.centos.x86_64/usr/share/licenses/cello-1.0
    + exit 0
    Provides: cello = 1.0-1.el7.centos cello(x86-64) = 1.0-1.el7.centos
    Requires(rpmlib): rpmlib(CompressedFileNames) <= 3.0.4-1 rpmlib(FileDigests) <= 4.6.0-1 rpmlib(PayloadFilesHavePrefix) <= 4.0-1
    Requires: libc.so.6()(64bit) libc.so.6(GLIBC_2.2.5)(64bit) rtld(GNU_HASH)
    Processing files: cello-debuginfo-1.0-1.el7.centos.x86_64
    Provides: cello-debuginfo = 1.0-1.el7.centos cello-debuginfo(x86-64) = 1.0-1.el7.centos
    Requires(rpmlib): rpmlib(FileDigests) <= 4.6.0-1 rpmlib(PayloadFilesHavePrefix) <= 4.0-1 rpmlib(CompressedFileNames) <= 3.0.4-1
    Checking for unpackaged file(s): /usr/lib/rpm/check-files /builddir/build/BUILDROOT/cello-1.0-1.el7.centos.x86_64
    Wrote: /builddir/build/RPMS/cello-1.0-1.el7.centos.x86_64.rpm
    warning: Could not canonicalize hostname: rhel7
    Wrote: /builddir/build/RPMS/cello-debuginfo-1.0-1.el7.centos.x86_64.rpm
    Executing(%clean): /bin/sh -e /var/tmp/rpm-tmp.JuPOtY
    + umask 022
    + cd /builddir/build/BUILD
    + cd cello-1.0
    + /usr/bin/rm -rf /builddir/build/BUILDROOT/cello-1.0-1.el7.centos.x86_64
    + exit 0
    Finish: rpmbuild cello-1.0-1.el7.src.rpm
    Finish: build phase for cello-1.0-1.el7.src.rpm
    INFO: Done(/home/admiller/rpmbuild/SRPMS/cello-1.0-1.el7.src.rpm) Config(epel-7-x86_64) 0 minutes 16 seconds
    INFO: Results and/or logs in: /var/lib/mock/epel-7-x86_64/result
    Finish: run

As you can see, mock is a fairly verbose tool. You will also notice a lot of
`yum`_ or `dnf`_ output (depending on RHEL7, CentOS7, or Fedora mock target)
that is not found in this output which was omitted for brevity and is often
omitted after you have done an ``--init`` on a mock target, such as ``mock -r
epel-7-x86_64 --init`` which will pre-download all the required packages, cache
them, and pre-stage the build chroot.

For more information, please consult the `Mock`_ upstream documentation.


Version Control Systems
-----------------------

When working with RPMs, it is often desireable to utilize a `Version Control
System`_ (VCS) such as `git`_ for managing components of the software we are
packaging. Something to note is that storing binary files in a VCS is not
favorable because it will drastically inflate the size of the source repository
as these tools are engineered to handle differentials in files (often optimized
for text files) and this is not something that binary files lend themselves to
so normally each whole binary file is stored. As a side effect of this there are
some clever utilities that are popular among upstream Open Source projects that
work around this problem by either storing the SPEC file where the source code
is in a VCS (i.e. - it is not in a compressed archive for redistribution) or
place only the SPEC file and patches in the VCS and upload the compressed
archive of the upstream release source to what is called a "look aside cache".

In this section we will cover two different options for using a VCS system,
`git`_, for managing the contents that will ultimately be turned into a RPM
package. One is called `tito`_ and the other is `dist-git`_.

.. note::
    For the duration of this section you will need to install the ``git``
    package on you system in order to follow along.

tito
^^^^

Tito is an utility that assumes all the source code for the software that is
going to be packaged is already in a `git`_ source control repository. This is
good for those practicing a DevOps workflow as it allows for the team writing
the software to maintain their normal `Branching Workflow`_. Tito will then
allow for the software to be incrementally packaged, built in an automated
fashion, and still provide a native installation experience for `RPM`_ based
systems.

.. note::
    The `tito`_ package is available in `Fedora`_ as well as in the `EPEL`_
    repository for use on RHEL 7 and CentOS 7.

Tito operates based on `git tags`_ and will manage tags for you if you elect to
allow it, but can optionally operate under whatever tagging scheme you prefer as
this functionality is configurable.

Let's explore a little bit about tito by looking at an upstream project already
using it. We will actually be using the upstream git repository of the project
that is our next section's subject, `dist-git`_. Since this project is publicly
hosted on is publicly hosted on `GitHub`_, let's go ahead and clone the git
repo.

::

    $ git clone https://github.com/release-engineering/dist-git.git
    Cloning into 'dist-git'...
    remote: Counting objects: 425, done.
    remote: Total 425 (delta 0), reused 0 (delta 0), pack-reused 425
    Receiving objects: 100% (425/425), 268.76 KiB | 0 bytes/s, done.
    Resolving deltas: 100% (184/184), done.
    Checking connectivity... done.

    $ cd dist-git/

    $ ls *.spec
    dist-git.spec

    $ tree rel-eng/
    rel-eng/
    ├── packages
    │   └── dist-git
    └── tito.props

    1 directory, 2 files


As we can see here, the SPEC file is at the root of the git repository and there
is a ``rel-eng`` directory in the repository which is used by tito for general
book keeping, configuration, and various advanced topics like custom tito
modules. We can see in the directory layout that there is a sub-directory
entitled ``packages`` which will store a file per package that tito manages in
the repository as you can have many RPMs in a single git repository and tito
will handle that just fine. In this scenario however, we see only a single
package listing and it should be noted that it matches the name of our SPEC
file. All of this is setup by the command ``tito init`` when the developers of
`dist-git`_ first initialized their git repo to be managed by tito.

If we were to follow a common workflow of a DevOps Practitioner then we would
likely want to use this as part of a `Continuous Integration`_ (CI) or
`Continuous Delivery`_ (CD) process. What we can do in that scenario is perform
what is known as a "test build" to tito, we can even use mock to do this. We
could then use the output as the installation point for some other component in
the pipeline. Below is a simple example of commands that could accomplish this
and they could be adapted to other environments.

::

    $ tito build --test --srpm
    Building package [dist-git-0.13-1]
    Wrote: /tmp/tito/dist-git-git-0.efa5ab8.tar.gz

    Wrote: /tmp/tito/dist-git-0.13-1.git.0.efa5ab8.fc23.src.rpm

    $ tito build --builder=mock --arg mock=epel-7-x86_64 --test --rpm
    Building package [dist-git-0.13-1]
    Creating rpms for dist-git-git-0.efa5ab8 in mock: epel-7-x86_64
    Wrote: /tmp/tito/dist-git-git-0.efa5ab8.tar.gz

    Wrote: /tmp/tito/dist-git-0.13-1.git.0.efa5ab8.fc23.src.rpm


    Using srpm: /tmp/tito/dist-git-0.13-1.git.0.efa5ab8.fc23.src.rpm
    Initializing mock...
    Installing deps in mock...
    Building RPMs in mock...
    Wrote:
      /tmp/tito/dist-git-selinux-0.13-1.git.0.efa5ab8.el7.centos.noarch.rpm
      /tmp/tito/dist-git-0.13-1.git.0.efa5ab8.el7.centos.noarch.rpm

    $ sudo yum localinstall /tmp/tito/dist-git-*.noarch.rpm
    Loaded plugins: product-id, search-disabled-repos, subscription-manager
    Examining /tmp/tito/dist-git-0.13-1.git.0.efa5ab8.el7.centos.noarch.rpm: dist-git-0.13-1.git.0.efa5ab8.el7.centos.noarch
    Marking /tmp/tito/dist-git-0.13-1.git.0.efa5ab8.el7.centos.noarch.rpm to be installed
    Examining /tmp/tito/dist-git-selinux-0.13-1.git.0.efa5ab8.el7.centos.noarch.rpm: dist-git-selinux-0.13-1.git.0.efa5ab8.el7.centos.noarch
    Marking /tmp/tito/dist-git-selinux-0.13-1.git.0.efa5ab8.el7.centos.noarch.rpm to be installed
    Resolving Dependencies
    --> Running transaction check
    ---> Package dist-git.noarch 0:0.13-1.git.0.efa5ab8.el7.centos will be installed

Note that the final command would need to be run with either sudo or root
permissions and that much of the output has been omitted for brevity as the
dependency list is quite long.

This concludes our simple example of how to use tito but it has many amazing
features for traditional Systems Administrators, RPM Packagers, and DevOps
Practitioners alike. I would highly recommend consulting the upstream
documentation found at the `tito` GitHub site for more information on how to
quickly get started using it for your project as well as various advanced
features it offers.

dist-git
^^^^^^^^

The `dist-git`_ utility takes a slightly different approach from that of `tito`_
such that instead of keeping the raw source code in `git`_ it instead will keep
SPEC files and patches in a git repository and upload the compressed archive of
the source code to what is known as a "look-aside cache". The "look-aside-cache"
is a term that was coined by the use of RPM Build Systems storing large files
like these "on the side". A system like this is generally tied to a proper RPM
Build System such as `Koji`_. The build system is then configured to pull the
items that are listed as ``SourceX`` entries in the SPEC files in from this
look-aside-cache, while the SPEC and patches remain in a version control system.
There is also a helper command line tool to assist in this.

In an effort to not duplicate documentation, for more information on how to
setup a system such as this please refer to the upstream `dist-git`_ docs.
upstream docs.

.. _more-macros:

More on Macros
--------------

There are many built-in RPM Macros and we will cover a few in the following
section, however an exhaustive list can be found rpm.org's `rpm macro`_ official
documentation.

There are also macros that are provided by your `Linux`_ Distribution, we will
cover some of those provided by `Fedora`_, `CentOS`_ and `RHEL`_ in this section
as well as provide information on how to inspect your system to learn about
others that we don't cover or for discovering them on other RPM-based `Linux`_
Distributions.

Defining Your Own
^^^^^^^^^^^^^^^^^

You can define your own Macros, below is an excerpt from the `RPM Official
Documentation`_ and I recommend anyone interested in an exhaustive explanation
of the many possibilities of defining their own macros to visit that resource.
It's really quite good and there's little reason to duplicate the bulk of that
content here.

To define a macro use:

::

        %define <name>[(opts)] <body>

All whitespace surrounding ``\<body\>`` is removed.  Name may be composed
of alphanumeric characters, and the character ``_`` and must be at least
3 characters in length. A macro without an (opts) field is "simple" in that
only recursive macro expansion is performed. A parameterized macro contains
an (opts) field. The opts (i.e. string between parentheses) is passed
exactly as is to getopt(3) for argc/argv processing at the beginning of
a macro invocation.

%files
^^^^^^

Common "advanced" RPM Macros needed in the ``%files`` section are as follows:

=================== ============================================================
Macro               Definition
=================== ============================================================
%license            This identifies the file listed as a LICENSE file and it
                    will be installed and labeled as such by RPM.
                    Example: ``%license LICENSE``
%dir                Identifies that the path is a directory that should be owned
                    by this RPM. This is important so that the rpm file manifest
                    accurately knows what directories to clean up on uninstall.
                    Example: ``%dir %{_libdir}/%{name}``
%config(noreplace)  Specifies that the following file is a configuration file
                    and therefore should not be overwritten (or replaced) on
                    a package install or update if the file has been modified
                    from the original installation checksum. In the event that
                    there is a change, the file will be created with ``.rpmnew``
                    appended to the end of the filename upon upgrade or install
                    so that the pre-existing or modified file on the target
                    system is not modified.
                    Example: ``%config(noreplace)
                    %{_sysconfdir}/%{name}/%{name}.conf``
=================== ============================================================

Built In Macros
^^^^^^^^^^^^^^^

Your system has many built in RPM Macros and the fastest way to view them all is
to simply run the ``rpm --showrc`` command, however note that this will contain
a *lot* of output so it's often used in combination with a pipe to grep (or
a clever shell Process Substitution).

You can also find information about the RPMs macros that come directly with your
system's version of RPM by looking at the output of the command ``rpm -ql rpm``
taking note of the files titled ``macros`` in the directory structure.


RPM Distribution Macros
^^^^^^^^^^^^^^^^^^^^^^^

Different distributions will supply different sets of recommended RPM Macros
based on the language implementation of the software being packaged or the
specific Guidelines of the distribution in question.

These are often provided as RPM Packages themselves and can be installed with
the distribution package manager, such as `yum`_ or `dnf`_. The macro files
themselves once installed can be found in ``/usr/lib/rpm/macros.d/`` and will be
included in the ``rpm --showrc`` output by default once installed.

One primary example of this is the `Fedora Packaging Guidelines`_ section
pertaining specifically to `Application Specific Guidelines`_ which at the time
of this writing has over 30 different sets of guidelines along with associated
RPM Macro sets for subject matter specific RPM Packaging.

One example of these kinds of RPMs would be for `Python`_ version 2.x and if we
have the ``python2-rpm-macros`` package installed (available in EPEL for RHEL
7 and CentOS 7), we have a number of python2 specific macros available to us.

::

    $ rpm -ql python2-rpm-macros
    /usr/lib/rpm/macros.d/macros.python2


    $ rpm --showrc | grep python2
    -14: __python2  /usr/bin/python2
    CFLAGS="%{optflags}" %{__python2} %{py_setup} %{?py_setup_args} build --executable="%{__python2} %{py2_shbang_opts}" %{?1}
    CFLAGS="%{optflags}" %{__python2} %{py_setup} %{?py_setup_args} install -O1 --skip-build --root %{buildroot} %{?1}
    -14: python2_sitearch   %(%{__python2} -c "from distutils.sysconfig import get_python_lib; print(get_python_lib(1))")
    -14: python2_sitelib    %(%{__python2} -c "from distutils.sysconfig import get_python_lib; print(get_python_lib())")
    -14: python2_version    %(%{__python2} -c "import sys; sys.stdout.write('{0.major}.{0.minor}'.format(sys.version_info))")
    -14: python2_version_nodots     %(%{__python2} -c "import sys; sys.stdout.write('{0.major}{0.minor}'.format(sys.version_info))")

The above output displays the raw RPM Macro definitions, but we are likely more
interested in what these will evaluate to which we can do with ``rpm --eval`` in
order to determine what they do as well as how they may be helpful to us when
packaging RPMs.

::

    $ rpm --eval %{__python2}
    /usr/bin/python2

    $ rpm --eval %{python2_sitearch}
    /usr/lib64/python2.7/site-packages

    $ rpm --eval %{python2_sitelib}
    /usr/lib/python2.7/site-packages

    $ rpm --eval %{python2_version}
    2.7

    $ rpm --eval %{python2_version_nodots}
    27


Advanced SPEC File Topics
-------------------------

There are various topics in the world of RPM SPEC Files that are considered
advanced because they have implications on not only the SPEC file, how the
package is built, but also on the end machine that the resulting RPM is
installed upon. In this section we will cover the most common of these such as
Epoch, Scriptlets, and Triggers.

Epoch
^^^^^

First on the list is ``Epoch``, epoch is a way to define weighted dependencies
based on version numbers. It's default value is 0 and this is assumed if an
``Epoch`` directive is not listed in the RPM SPEC file. This was not covered in
the SPEC File section of this guide because it is almost always a bad idea to
introduce an Epoch value as it will skew what you would normally otherwise
expect RPM to do when comparing versions of packages.

For example if a package ``foobar`` with ``Epoch: 1`` and ``Version: 1.0`` was
installed and someone else packaged ``foobar`` with ``Version: 2.0`` but simply
omitted the ``Epoch`` directive either because they were unaware of it's
necessity or simply forgot, that new version would never be considered an update
because the Epoch version would win out over the traditional
Name-Version-Release marker that signifies versioning for RPM Packages.

This approach is generally only used when absolutely necessary (as a last
resort) to resolve an upgrade ordering issue which can come up as a side effect
of upstream software changing versioning number schemes or versions
incorporating alphabetical characters that can not always be compared reliably
based on encoding.

Triggers and Scriptlets
^^^^^^^^^^^^^^^^^^^^^^^

In RPM Packages, there are a series of directives that can be used to inflict
necessary or desired change on a system during install time of the RPM. These
are called **scriptlets**.

One primary example of when and why you'd want to do this is when a system
service RPM is installed and it provides a `systemd`_ `unit file`_. At install
time we will need to notify `systemd`_ that there is a new unit so that the
system administrator can run a command similar to ``systemctl start
foo.service`` after the fictional RPM ``foo`` (which provides some service
daemon in this example) has been installed. Similarly, we would need to inverse
of this action upon uninstallation so that an administrator would not get errors
due to the daemon's binary no longer being installed but the unit file still
existing in systemd's running configuration.

There are a small handful of common scriptlet directives, they are similar to
the "section headers" like ``%build`` or ``%install`` in that they are defined
by multi-line segments of code, often written as standard `POSIX`_ shell script
but can be a few different programming languages such that RPM for the target
machine's distribution is configured to allow them. An exhaustive list of these
available languages can be found in the `RPM Official Documentation`.

Scriptlet directives are as follows:

=================== ============================================================
Directive           Definition
=================== ============================================================
``%pre``            Scriptlet that is executed just before the package is
                    installed on the target system.
``%post``           Scriptlet that is executed just after the package is
                    installed on the target system.
``%preun``          Scriptlet that is executed just before the package is
                    uninstalled from the target system.
``%postun``         Scriptlet that is executed just after the package is
                    uninstalled from the target system.
=================== ============================================================

Is is also common for RPM Macros to exist for this function. In our previous
example we discussed `systemd`_ needing to be notified about a new `unit file`_,
this is easily handled by the systemd scriptlet macros as we can see from the
below example output. More information on this can be found in the `Fedora
systemd Packaging Guidelines`_.

::

    $ rpm --showrc | grep systemd
    -14: __transaction_systemd_inhibit      %{__plugindir}/systemd_inhibit.so
    -14: _journalcatalogdir /usr/lib/systemd/catalog
    -14: _presetdir /usr/lib/systemd/system-preset
    -14: _unitdir   /usr/lib/systemd/system
    -14: _userunitdir       /usr/lib/systemd/user
    /usr/lib/systemd/systemd-binfmt %{?*} >/dev/null 2>&1 || :
    /usr/lib/systemd/systemd-sysctl %{?*} >/dev/null 2>&1 || :
    -14: systemd_post
    -14: systemd_postun
    -14: systemd_postun_with_restart
    -14: systemd_preun
    -14: systemd_requires
    Requires(post): systemd
    Requires(preun): systemd
    Requires(postun): systemd
    -14: systemd_user_post  %systemd_post --user --global %{?*}
    -14: systemd_user_postun        %{nil}
    -14: systemd_user_postun_with_restart   %{nil}
    -14: systemd_user_preun
    systemd-sysusers %{?*} >/dev/null 2>&1 || :
    echo %{?*} | systemd-sysusers - >/dev/null 2>&1 || :
    systemd-tmpfiles --create %{?*} >/dev/null 2>&1 || :

    $ rpm --eval %{systemd_post}

    if [ $1 -eq 1 ] ; then
            # Initial installation
            systemctl preset  >/dev/null 2>&1 || :
    fi

    $ rpm --eval %{systemd_postun}

    systemctl daemon-reload >/dev/null 2>&1 || :

    $ rpm --eval %{systemd_preun}

    if [ $1 -eq 0 ] ; then
            # Package removal, not upgrade
            systemctl --no-reload disable  > /dev/null 2>&1 || :
            systemctl stop  > /dev/null 2>&1 || :
    fi


Another item that provides even more fine grained control over the RPM
Transaction as a whole is what is known as **triggers**. These are effectively
the same thing as a scriptlet but are executed in a very specific order of
operations during the RPM install or upgrade transaction allowing for a more
fine grained control over the entire process.

The order in which each is executed and the details of which are provided below.

::

    all-%pretrans
    ...
    any-%triggerprein (%triggerprein from other packages set off by new install)
    new-%triggerprein
    new-%pre      for new version of package being installed
    ...           (all new files are installed)
    new-%post     for new version of package being installed

    any-%triggerin (%triggerin from other packages set off by new install)
    new-%triggerin
    old-%triggerun
    any-%triggerun (%triggerun from other packages set off by old uninstall)

    old-%preun    for old version of package being removed
    ...           (all old files are removed)
    old-%postun   for old version of package being removed

    old-%triggerpostun
    any-%triggerpostun (%triggerpostun from other packages set off by old un
                install)
    ...
    all-%posttrans

The above items are from the included RPM documentation found in
``/usr/share/doc/rpm/triggers`` on Fedora systems and
``/usr/share/doc/rpm-4.*/triggers`` on RHEL 7 and CentOS 7 systems.

References
----------

Below are references to various topics of interest around RPMs, RPM Packaging,
and RPM Building. Some of these will be advanced and extend far beyond the
introductory material included in this guide.

* `RPM Official Documentation`_
* `Gurulabs CREATING RPMS (Student Version)`_
* `Fedora How To Create An RPM Package Guide`_
* `Fedora Packaging Guidelines`_
* `OpenSUSE Packaging Guidelines`_
* IBM RPM Packaging Guide: `Part 1`_, `Part 2`_, `Part 3`_
* `Maximum RPM` (Some material is dated, but this is still a great resource for
  advanced topics.)

.. include:: citations.rst
