.. SPDX-License-Identifier:    CC-BY-SA-4.0


.. _rpm-guide:

===================
RPM Packaging Guide
===================

Hello! Welcome to RPM Packaging 101 (for lack of a more inventive title). Here
you will find all of the information you need in order to start packaging RPMs
for various `Linux`_ Distributions that use the `RPM`_ Packaging Format.

This guide assumes no previous knowledge about packaging software for any
Operating System, Linux or otherwise. However, it should be noted that this
guide is written to target the Red Hat "family" of Linux distributions, which
are:

* `Fedora`_
* `CentOS`_
* `Red Hat Enterprise Linux`_

While these distros are the target environment, it should be noted that lessions
learned here should be applicable across all distributions that are `RPM based`_
but the examples will need to be adapted for distribution specific items such as
prerequisite installation items, guidelines, or macros. (More on macros later)

.. note::
    If you have made it this far and don't know what a software package or a
    GNU/Linux distribution is, you might be best served by exploring some
    articles on the topics of `Linux`_ and `Package Managers`_.

Prerequisites
=============

In order to perform the following the following examples you will need a few
packages installed on your system:

.. note::
    The inclusion of some of the packages below are not actually necessary
    because they are a part of the default installation of Fedora, RHEL, and
    CentOS but are listed explicitly for perspective of exactly the tools used
    within this document.

* For Fedora:

::

    $ dnf install gcc rpmbuild rpm-devel make python bash coreutils diffutils
    patch

* For RHEL/CentOS (this guide assumes version 7.x of either):

::

    $ yum install gcc rpmbuild rpm-devel make python bash coreutils diffutils
    patch


Beyond these preliminary packages you will also need a text editor of your
choosing. We will not be discussing or recommending text editors in this
document and we trust that everyone has at least one they are comfortable with
at their disposal.

General Topics and Background
=============================

In this section will we walk through various topics about building software that
lead up to being able to successfully build RPMs:

* What is Source Code?
* How Programs Are Made
* Building from source into an output artifact (what type of artifact will
  depend on the scenario and we will define what this means more specifically
  with examples).
* Patching Software
* Placing those output artifacts somewhere on the system that is useful within
  the `Filesystem Hierarchy Standard`_.

What is Source Code?
--------------------

.. note::
    If you are familiar with what the following terms mean then feel free to
    skip this section: source code, programming, programming languages.

In the world of computer software, **source code** is the term used to the
representation of instructions to the computer about how to perform a task in
a way that is human readable, normally as simple text. This human readable
format is expressed using a `programming language`_ which basically boils down
to a set of rules about that programmers learn so that the text they write is
meaningful to the computer.

.. note::
    There are many thousands of programming languages in the world. In this
    document we will provide examples of only a couple, some finer points of
    various programming languages are going to vary but hopefully this guide
    will prove to be a good conceptual overview.

For example, the following three examples are all a very simple program that
will display the text ``Hello World`` to the command line. The reason for three
versions of the example will become apparent in the next section but this is
three implementations of the same program written in different programming
languages. The program is a very common starting place for newcomers to the
programming world so it may appear familiar to some readers, but if it doesn't
do not worry.

.. note::
    In the first two examples below, the ``#!`` line is known as a `shebang`_
    and is not tehcnically part of the programming language source code.

This version of the example is written in the `bash`_ shell built in scripting
language.

``hello.bash``

.. code-block:: sh

    #!/bin/bash

    printf "Hello World\n"


This version of the example is written in a programming language named
`Python`_.

``hello.py``

.. code-block:: python

    #!/usr/bin/env python

    print("Hello World")


This version of the example is written in a programming language named `C`_.

``hello.c``

.. code-block:: c

    #include <stdio.h>

    int main(void) {
        printf("Hello World\n");
        return 0;
    }


The finer points of how to write software isn't necessarily important at this
time but if you felt so inclined to learn to program that would certainly be
beneficial in your adventures as a software packager.

As mentioned before, the output of both examples to the command line will be
simply, ``Hello World`` when the source code is built and run. The topic of how
that happens is up next!

How Programs Are Made
---------------------

Before we dive too far into how to actually build code it is best to first
understand a few items about software source code and how it becomes
instructions to the computer. Effectively, how programs are actually made. There
many ways in which a program can be executed but it boils down to effectively
two common methods:

#. Natively Compiled
#. Interpreted (Byte Compiled and Raw Interpreted)

Natively Compiled Code
^^^^^^^^^^^^^^^^^^^^^^

Software written in programming languages that compile to machines code or
directly to a binary executable (i.e. - something that the computer natively
understands without an help) that can be run stand alone is considered to be
**Natively Compiled**. This is important for building `RPM`_ Packages because
packages built this way are what is known as `architecture`_ specific, meaning
that if you compile this particular piece of software on a computer that uses a
64-bit (x86_64) AMD or Intel processor, it will not execute on a (x86) 32-bit
AMD or Intel processor. The method by which this happens will be covered in the
next section.

Interpreted Code
^^^^^^^^^^^^^^^^

There are certain programming languages that do not compile down to a
representation of program that the computer natively understands. These programs
are **Interpreted** and require a Language `Interpreter`_ or Language Virtual
Machine(VM). The name *interpreter* comes from it's similarities with how human
language interpreters convert between two representations of human speach
to allow two people to talk, a programming language interpreter converts from
a format that the computer doesn't "speak" to one that it does.

There are two types of Interpreted Languages, Byte Compiled and Raw Interpreted
and the distinction between these is useful to keep in mind when packaging
software because of the actual ``%build`` process is going to be very different
and sometimes in the case of Raw Interpreted Languages there will be no series
of steps required at all for the ``%build``. (What ``%build`` means in detail
will be explained later, but the short version is this is how we tell the RPM
Packaging system to actually perform the *build*). Where as Byte Compiled
programming languages will perform a build task that will "compile" or
"translate" the code from the programming language source that is human readable
to an intermediate representation of the program that is more effecient for the
programming language interpreter to execute.

Software written entirely in programming languages such as `bash`_ shell script
and `Python`_ (as used in our example) are *Interpreted* and therefore are not
`architecture`_ specific which means the resulting RPM Package that is created
will be considered ``noarch``. Indicating that it does not have an
`architecture`_ associated with it.

Building Software from Source
-----------------------------

In this section we will discuss and provide examples of building software from
it's source code.

.. note::
    If you are comfortable building software from source code please feel free
    to skip this section and move on. However, if you'd like to stick around and
    read it then please feel free and it will hopefully serve as a refresher or
    possibly contain something interesting that's new to you.


Source code must go through a **build** process and that process will vary based
on specific programming language but most often this is refered to as
**compiling** or **translating** the software. For software written in
interpreted programming languages this step may not be necesary but sometimes it
is desirable to perform what is known as **byte compiling** as it's build
process. We will cover each scenario below. The resulting built software can
then be **run** or "**executed**" which tells the computer to perform the task
described to it in the source code provided by the programmer who authored the
software.

.. note::
    There are various methods by which software written in different programming
    languages can vary heavily. If the software you are interested in packaging
    doesn't follow the exact examples here, this will hopefully be an objective
    guideline.


Natively Compiled Code
^^^^^^^^^^^^^^^^^^^^^^

Referencing the example previously used that is written in `C`_ (listed again
below for the sake of those who may have skipped the previous section), we will
build this source code into something the computer can execute.

``hello.c``

.. code-block:: c

    #include <stdio.h>

    int main(void) {
        printf("Hello World\n");
        return 0;
    }

Build Process
"""""""""""""

In the below example we are going to invoke the `C`_ compiler from the GNU
Compiler Collection (`GCC`_).

::

    gcc -o hello hello.c


From here we can actually execute the resulting output binary.

::

    $ ./hello
    Hello World

That's it! You've built natively compiled software from source code!

Let's take this one step further and add a `GNU make`_ Makefile which will help
automate the building of our code. This is an extremely common practice by real
large scale software and is a good thing to become familiar with as a RPM
Packager. Let's create a file named ``Makefile`` in the same directory as our
example `C`_ source code file named ``hello.c``.

``Makefile``

.. code-block:: make

    hello:
            gcc -o hello hello.c

    clean:
            rm hello


Now to build our software we can simply run the command ``make``, below you
will see the command run more than once just for the sake of seeing what is
expected behavior.

::

    $ make
    make: 'hello' is up to date.

    $ make clean
    rm hello

    $ make
    gcc -o hello hello.c

    $ make
    make: 'hello' is up to date.

    +$ ./hello
    Hello World

Congratulations! You have now both compiled software manually and used a build
tool!

Interpreted Code
^^^^^^^^^^^^^^^^

For software written in interpreted programming languages, we know that we don't
need to compile it, but if it's a byte compiled language such as `Python`_ there
may still be a step required.

Referencing the two examples previously (listed again below for the sake of
those who may have skipped the previous section), for `Python`_ we will build
this source code into something the `Python`_ Language Interpreter (known as
`CPython`_) can execute.

.. note::
    In the two examples below, the ``#!`` line is known as a `shebang`_ and is
    not tehcnically part of the programming language source code.

Byte Compiled Code
""""""""""""""""""

As mentioned previously, this version of the example is written in a programming
language named `Python`_ and it's default language virtual machine is one that
executes *byte compiled* code. This will "compile" or "translate" the source
code into an intermediate format that is optimised and will be much faster for
the language virtual machine to execute.

``hello.py``

.. code-block:: python

    #!/usr/bin/env python

    print("Hello World")

The exact procedure to byte compile programs based on language will differ
heavily based on the programming language, it's language virtual machine, and
the tools or processes that are common within that programming language's
community. Below is an example using `Python`_.

::

    $ python -m compileall hello.py
    $ python hello.pyc
    Hello World

Raw Interpreted
"""""""""""""""

This version of the example is written in the `bash`_ shell built in scripting
language.

``hello.bash``

.. code-block:: sh

    #!/bin/bash

    printf "Hello World\n"


UNIX-style shells have scripting languages, much like `bash` does, but
programms written in these languages do not have any kind of byte compile
procedure and are interpreted directly as they are written so the only procedure
we have to do is make the file executable and then run it.

::

    $ chmod +x hello.bash
    $ ./hello.bash
    Hello World

Patching Software
-----------------

In software and computing a **patch** is the term given to a

Installing Arbitrary Artifacts
------------------------------

One of the many really nice things about `Linux`_ systems is the `Filesystem
Hierarchy Standard`_ (FHS) which defines areas of the filesystem in which things
should be placed. As a RPM Packager this is extremely useful because we will
always know where to place things that come from our source code.

This section references the concept of an **Arbitrary Artifact** which in this
context is anything you can imagine that is a file that you want to install
somewhere on the system within the FHS. It could be a simple script,
a pre-existing binary, the binary output of source code that you have created as
a side effect of a build process, or anything else you can think up. We discuss
it in such a vague vocabulary in order to demonstrate that the system nor RPM
care what the *Artifact* in question is. To both RPM and the system, it is just
a file that needs to exist in a pre-determined place. The permissions and the
type of file it is makes it special to the system but that is for us as a RPM
Packager to decide.

For example, once we have built our software we can then place it on the system
somewhere that will end up in the system `$PATH`_ so that they can be found and
executed easily by users, developers, and sysadmins alike. We will explore two
ways to accomplish this as they each are quite popular approaches used by RPM
Packagers.

install command
^^^^^^^^^^^^^^^

When placing arbitrary artifacts onto the system without build automation
tooling such as `GNU make`_ or because it is a simple script and such tooling
would be seen as unnecessary overhead, it is a very common practice to use the
``install`` command (provided to the system by `coreutils`_) to place the
artifact in a correct location on the filesystem based on where it should exist
in the FHS along with appropriate permissions on the target file or directory.

The example below is going to use the ``hello.bash`` file that we had previously
created as the artibrary artifact subject to our installation method. Note that
you will either need `sudo`_ permissions or run this command as root excluding
the ``sudo`` portion of the command.

::

    $ install -m 0755 hello.bash /usr/bin/hello.bash


As this point, we can execute ``hello.bash`` from our shell no matter what our
current working directory is because it has been installed into our `$PATH`_.

::

    $ cd ~/

    $ hello.bash
    Hello World

make install
^^^^^^^^^^^^

A very popular mechanism by which you will install software from source after
it's built is by using a command called ``make install`` and in order to do that
we need to enhance the ``Makefile`` we created previously just a little bit.

Open the ``Makefile`` file up in your favorite text editor and make the
appropriate edits needed so that it ends up looking exactly as the following.

``Makefile``

.. code-block:: make

    hello:
            gcc -o hello hello.c

    clean:
            rm hello

    install:
            install -m 0755 hello /usr/bin/hello

Now we are able to use the make file to both build and install the software from
source. Note that for the installation portion, like before when we ran the raw
``install`` command, you will need either `sudo`_ permissions or be the ``root``
user and ommit the ``sudo`` portion of the command.

.. note::
    The creation of ``Makefile`` is normally done by the developer who writes
    the original source code of the software in question and as a RPM Packager
    this is not generally something you will need to do. This is purely an
    exercise for background knowledge and we will expand upon this as it relates
    to RPM Packaging later.

The following will build and install the simple ``hello.c`` program that we had
written previously.

::

    $ make
    gcc -o hello hello.c

    $ sudo make install
    install -m 0755 hello /usr/bin/hello

Just as in the previous example, we can now execute ``hello`` from our shell no
matter what our current working directory is because it has been installed into
our `$PATH`_.

::

    $ cd ~/

    $ hello
    Hello World

Congratulations, you have now installed a build artifact into it's proper
location on the system!


RPM Packages
============

In this section we are going to hopefully cover everything you ever wanted to
know about the RPM Packaging format, and if not then hopefully the contents of
the :ref:`Appendix <appendix>` will satisfy the craving for knowledge that has
been left out of this section.

What is a RPM?
--------------

To kick things off, let's first define what an RPM actually is. An RPM package
is simply file containing a `cpio`_ archive and metadata about itself. The
`cpio`_ archive is the payload and the RPM Header contains the metadata. The
package manager ``rpm`` uses this metadata to determine things like
dependencies.

Conventionally speaking there are two different types of RPM, there is the
Source RPM (SRPM) and the binary RPM. Both of these share an over all
convention, file format, and tooling but they represent very different things.
The payload of a SRPM is a SPEC file (which describes how to build a binary RPM)
and the actually source code that the resulting binary RPM will be built out of
(including any patches that may be needed).

What is a SPEC File?
--------------------

.. FIXME

Working with SPEC files
-----------------------

.. FIXME

BuildRoots
----------

The term "buildroot" is unfortunately ambiguous and you will often get various
different definitions. However in the world of RPM Packages this is literally
a `chroot`_ environment such that you are creating a filesystem hierarchy in
a new "fake" root directory much in the way these contents can be laid down upon
an actual system's filesystem and not violate it's integrity. Imagine this much
in the same way that you would imagine creating the contents for a `tarball`_
such that it would be expanded at the root (/) directory of an existing system
as this is effectively what RPM will do at a certain point during an
installation transaction.

RPM Macros and their use in SPEC files
--------------------------------------

.. FIXME

Prepping Our Build Environment
==============================

.. FIXME

Building RPMS
=============

.. FIXME


.. _appendix:

Appendix
========

Here you will find supplementary information that is very good to know and will
likely prove to helpful for anyone who is going to be building RPMs in an
serious capacity but isn't necessarily a hard requirement to learn how to
package RPMs in the first place which is what the main goal of this document is.

Prestine Build Environments with Mock
-------------------------------------

.. FIXME

References
----------

Below are references to various topics of interest around RPMs, RPM Packaging,
and RPM Building.

* `RPM Official Documentation`_
* `Gurulabs CREATING RPMS (Student Version)`_
* `Fedora Packaging Guidelines`_
* `OpenSUSE Packaging Guidelines`_


.. Citations / Links - etc.
.. _RPM: http://rpm.org/
.. _GCC: https://gcc.gnu.org/
.. _sudo: http://www.sudo.ws/
.. _Fedora: https://getfedora.org/
.. _CentOS: https://www.centos.org/
.. _Python: https://www.python.org/
.. _Red Hat: https://www.redhat.com/en
.. _bash: https://www.gnu.org/software/bash/
.. _cpio: https://en.wikipedia.org/wiki/Cpio
.. _Linux: https://en.wikipedia.org/wiki/Linux
.. _GNU make: http://www.gnu.org/software/make/
.. _chroot: https://en.wikipedia.org/wiki/Chroot
.. _CPython: https://en.wikipedia.org/wiki/CPython
.. _patch: http://savannah.gnu.org/projects/patch/
.. _RPM Official Documentation: http://rpm.org/wiki/Docs
.. _$PATH: https://en.wikipedia.org/wiki/PATH_%28variable%29
.. _shebang: https://en.wikipedia.org/wiki/Shebang_%28Unix%29
.. _tarball: https://en.wikipedia.org/wiki/Tar_%28computing%29
.. _C: https://en.wikipedia.org/wiki/C_%28programming_language%29
.. _architecture: https://en.wikipedia.org/wiki/Microarchitecture
.. _Package Managers: https://en.wikipedia.org/wiki/Package_manager
.. _coreutils: http://www.gnu.org/software/coreutils/coreutils.html
.. _Interpreter: https://en.wikipedia.org/wiki/Interpreter_%28computing%29
.. _programming language:
    https://en.wikipedia.org/wiki/Programming_language
.. _OpenSUSE Packaging Guidelines:
    https://en.opensuse.org/openSUSE:Packaging_guidelines
.. _Red Hat Enterprise Linux:
    https://www.redhat.com/en/technologies/linux-platforms
.. _Filesystem Hierarchy Standard:
    https://en.wikipedia.org/wiki/Filesystem_Hierarchy_Standard
.. _RPM based:
    https://en.wikipedia.org/wiki/List_of_Linux_distributions#RPM-based
.. _Gurulabs CREATING RPMS (Student Version):
    https://www.gurulabs.com/media/files/courseware-samples/GURULABS-RPM-GUIDE-v1.0.PDF
.. _Fedora Packaging Guidelines:
    https://fedoraproject.org/wiki/Packaging:Guidelines?rd=Packaging/Guidelines
