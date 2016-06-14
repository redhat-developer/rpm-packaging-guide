
.. _appendix:

Appendix
========

Here you will find supplementary information that is very good to know and will
likely prove to helpful for anyone who is going to be building RPMs in an
serious capacity but isn't necessarily a hard requirement to learn how to
package RPMs in the first place which is what the main goal of this document is.

Prestine Build Environments with Mock
-------------------------------------

FIXME

.. _more-macros:

More on Macros
--------------

There are many built-in RPM Macros and we will cover a few in the following
section, however an exhaustive list can be found rpm.org's `rpm macro`_ official
documentation.

There are also macros that are provided by your `Linux`_ Distribution, we will
cover some of those provided by `Fedora`_, `CentOS`_ and `RHEL`_ in this section
as well as provide information on how to inspect your system to learn about
others that we don't cover or for discovering them on a RPM-based `Linux`_
Distribution other than the ones covered.

Built In Macros
^^^^^^^^^^^^^^^

FIXME


RPM Distribution Macros
^^^^^^^^^^^^^^^^^^^^^^^

FIXME

FIXME: %files section: %license, %dir, %config(noreplace)

Advanced SPEC File Topics
-------------------------

FIXME

FIXME: Epoch

FIXME: Scriptlets and Triggers

Scriptlets
^^^^^^^^^^

FIXME

Triggers
^^^^^^^^

FIXME


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


.. Citations / Links - etc.
.. _RPM: http://rpm.org/
.. _GCC: https://gcc.gnu.org/
.. _sudo: http://www.sudo.ws/
.. _git: https://git-scm.com/
.. _Fedora: https://getfedora.org/
.. _CentOS: https://www.centos.org/
.. _Python: https://www.python.org/
.. _Red Hat: https://www.redhat.com/en
.. _gzip: https://www.gnu.org/software/gzip/
.. _bash: https://www.gnu.org/software/bash/
.. _cpio: https://en.wikipedia.org/wiki/Cpio
.. _Linux: https://en.wikipedia.org/wiki/Linux
.. _GNU make: http://www.gnu.org/software/make/
.. _chroot: https://en.wikipedia.org/wiki/Chroot
.. _Maximum RPM: http://rpm.org/max-rpm-snapshot/
.. _CPython: https://en.wikipedia.org/wiki/CPython
.. _patch: http://savannah.gnu.org/projects/patch/
.. _rpm macro: http://rpm.org/wiki/PackagerDocs/Macros
.. _RPM Official Documentation: http://rpm.org/wiki/Docs
.. _$PATH: https://en.wikipedia.org/wiki/PATH_%28variable%29
.. _Part 1: http://www.ibm.com/developerworks/library/l-rpm1/
.. _Part 2: http://www.ibm.com/developerworks/library/l-rpm2/
.. _Part 3: http://www.ibm.com/developerworks/library/l-rpm3/
.. _shebang: https://en.wikipedia.org/wiki/Shebang_%28Unix%29
.. _here document: https://en.wikipedia.org/wiki/Here_document
.. _tarball: https://en.wikipedia.org/wiki/Tar_%28computing%29
.. _GPLv3: https://www.gnu.org/licenses/quick-guide-gplv3.html
.. _RHEL: https://www.redhat.com/en/technologies/linux-platforms
.. _C: https://en.wikipedia.org/wiki/C_%28programming_language%29
.. _architecture: https://en.wikipedia.org/wiki/Microarchitecture
.. _Package Managers: https://en.wikipedia.org/wiki/Package_manager
.. _coreutils: http://www.gnu.org/software/coreutils/coreutils.html
.. _diffutils: http://www.gnu.org/software/diffutils/diffutils.html
.. _Software License: https://en.wikipedia.org/wiki/Software_license
.. _configure script: https://en.wikipedia.org/wiki/Configure_script
.. _Interpreter: https://en.wikipedia.org/wiki/Interpreter_%28computing%29
.. _Fedora License Guidelines: https://fedoraproject.org/wiki/Licensing:Main
.. _$(DESTDIR): https://www.gnu.org/software/make/manual/html_node/DESTDIR.html
.. _programming language:
    https://en.wikipedia.org/wiki/Programming_language
.. _Software Packaging and Distribution:
    https://docs.python.org/2/library/distribution.html
.. _OpenSUSE Packaging Guidelines:
    https://en.opensuse.org/openSUSE:Packaging_guidelines
.. _Red Hat Enterprise Linux:
    https://www.redhat.com/en/technologies/linux-platforms
.. _Fedora How To Create An RPM Package Guide:
    https://fedoraproject.org/wiki/How_to_create_an_RPM_package
.. _Filesystem Hierarchy Standard:
    https://en.wikipedia.org/wiki/Filesystem_Hierarchy_Standard
.. _RPM based:
    https://en.wikipedia.org/wiki/List_of_Linux_distributions#RPM-based
.. _Gurulabs CREATING RPMS (Student Version):
    https://www.gurulabs.com/media/files/courseware-samples/GURULABS-RPM-GUIDE-v1.0.PDF
.. _Fedora Packaging Guidelines:
    https://fedoraproject.org/wiki/Packaging:Guidelines?rd=Packaging/Guidelines
.. _download the example source code:
    https://github.com/maxamillion/rpm-guide/tree/master/example-code
