.. SPDX-License-Identifier:    CC-BY-SA-4.0

Welcome to RPM Packaging Guide's documentation!
===============================================


So You Want To Be An RPM Packager?
----------------------------------

So you want to be an RPM Packager (or you at least need to know how to package
RPMs because of your dayjob or otherwise)?

Well hopefully this guide will prove to be helpful.

Below you will find information about RPMs, source code and all sorts of things
in between. If you are familiar with what "`Source Code`_" is and how it gets
compiled or "built" into software then feel free to skip the :ref:`General
Topics and Background <general-background>` section and move right on into the
:ref:`RPM Guide <rpm-guide>`. More advanced topics and items otherwise
considered out of scope of getting you on the path to packaging software will be
held in the :ref:`Appendix <appendix>`. However, I hope all sections of this
guide do prove useful in some capacity.

This guide is meant to be used however the reader feels they would best like to
use it. The sections are arranged such that the reader may start from the
beginning and go all the way through and the flow of topics should make sense
with each topic building upon the previous ones. However, if you as the reader
feel you are comfortable with a topic or would just like to use the guide as
reference material please feel free to skip sections or jump around as you
please. The goal here is to be useful to someone with little to no background in
software development or packaging so some topics will likely seem oddly
introductory for such a guide, but don't worry that's by design and you can skip
past those if you like.

Document Conventions
--------------------

Code and command line out put will be placed into a block similar to the
following:

::

    This is a block! We can do all sorts of cool code and command line stuff
    here!

    Look, more lines!


::

    $ echo "Here's some command line output!"
    Here's some command line output!

.. code-block:: python

    #!/usr/bin/env python

    def code_example:
        print("And here's some code with syntax highlighting and everything!")

    code_example()

Topics of interest or vocabulary terms will either be referred to as URLs to
their respective documentation/website, as a **bold** item, or in *italics*. The
first encounter of the term should be a reference to its respective
documentation.

Command line utilities, commands, or things otherwise found in code that are
used through out paragraphs will be written in a ``monospace`` font.

.. _pre-req:

Prerequisites
-------------

In order to perform the following the following examples you will need a few
packages installed on your system:

.. note::
    The inclusion of some of the packages below are not actually necessary
    because they are a part of the default installation of Fedora, RHEL, and
    CentOS but are listed explicitly for perspective of exactly the tools used
    within this document.

* For `Fedora`_:

::

    $ dnf install gcc rpmbuild rpm-devel rpmlint make python bash coreutils diffutils
    patch

* For `RHEL`_ or `CentOS`_ (this guide assumes version 7.x of either):

::

    $ yum install gcc rpmbuild rpm-devel rpmlint make python bash coreutils diffutils
    patch


Beyond these preliminary packages you will also need a text editor of your
choosing. We will not be discussing or recommending text editors in this
document and we trust that everyone has at least one they are comfortable with
at their disposal.


Contents
--------

.. toctree::
    :maxdepth: 2

    rpm-guide
    general-background
    appendix
    citations

Indices and tables
==================

* :ref:`genindex`
* :ref:`modindex`
* :ref:`search`

.. include:: citations.rst
