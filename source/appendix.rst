
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

::

    $ rpmbuild --rebuild ~/rpmbuild/SRPMS/cello-1.0-1.el7.src.rpm
    Installing /home/admiller/rpmbuild/SRPMS/cello-1.0-1.el7.src.rpm
    error: Failed build dependencies:
            gcc is needed by cello-1.0-1.el7.x86_64

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

.. include:: citations.rst
