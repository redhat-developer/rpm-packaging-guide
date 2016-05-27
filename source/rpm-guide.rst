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

.. _pre-req:

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

``bello``

.. code-block:: sh

    #!/bin/bash

    printf "Hello World\n"


This version of the example is written in a programming language named
`Python`_.

``pello.py``

.. code-block:: python

    #!/usr/bin/env python

    print("Hello World")


This version of the example is written in a programming language named `C`_.

``cello.c``

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

``cello.c``

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

    gcc -o cello cello.c


From here we can actually execute the resulting output binary.

::

    $ ./cello
    Hello World

That's it! You've built natively compiled software from source code!

Let's take this one step further and add a `GNU make`_ Makefile which will help
automate the building of our code. This is an extremely common practice by real
large scale software and is a good thing to become familiar with as a RPM
Packager. Let's create a file named ``Makefile`` in the same directory as our
example `C`_ source code file named ``cello.c``.

``Makefile``

.. code-block:: make

    cello:
            gcc -o cello cello.c

    clean:
            rm cello


Now to build our software we can simply run the command ``make``, below you
will see the command run more than once just for the sake of seeing what is
expected behavior.

::

    $ make
    make: 'cello' is up to date.

    $ make clean
    rm cello

    $ make
    gcc -o cello cello.c

    $ make
    make: 'cello' is up to date.

    +$ ./cello
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

``pello.py``

.. code-block:: python

    #!/usr/bin/env python

    print("Hello World")

The exact procedure to byte compile programs based on language will differ
heavily based on the programming language, it's language virtual machine, and
the tools or processes that are common within that programming language's
community. Below is an example using `Python`_.

::

    $ python -m compileall pello.py
    $ python pello.pyc
    Hello World

Raw Interpreted
"""""""""""""""

This version of the example is written in the `bash`_ shell built in scripting
language.

``bello``

.. code-block:: sh

    #!/bin/bash

    printf "Hello World\n"


UNIX-style shells have scripting languages, much like `bash` does, but
programms written in these languages do not have any kind of byte compile
procedure and are interpreted directly as they are written so the only procedure
we have to do is make the file executable and then run it.

::

    $ chmod +x bello
    $ ./bello
    Hello World

Patching Software
-----------------

In software and computing a **patch** is the term given to source code that is
meant to fix other code, this is similar to the way that someone will use
a piece of cloth to patch another piece of cloth that is part of a shirt or
a blanket. Patches in software are formatted as what is called a``diff`` since
it represents what is *different* between to pieces of source code. A *diff* is
created using the ``diff`` command line utility that is provided by `diffutils`_
and then it is applied to the original source code using the tool `patch`_.

.. note::
    Software developer will often use "Version Control Systems" such as `git`_
    to manage their code base. Tools like these provide their own methods of
    creating diffs or patching software but those are outside the scope of this
    document.

Let's walk through an example where we create a patch from the original source
code using ``diff`` and then apply it using the `patch`_ utility. We will
revisit patching software in a later section when it comes to actually building
RPMs and hopefully this exercise will prove it's usefulness at that time. First
step in patching software is to preserve the original source code, a common
practice for this is tocopy it and append ``.orig`` to the filename. Let's do
that now.

::

    $ cp cello.c cello.c.orig

Next, we want to make an edit to ``cello.c`` using our favorite text editor.
Update your ``cello.c`` to match the output below.


.. code-block:: c

    #include <stdio.h>

    int main(void) {
        printf("Hello World from my very first patch!\n");
        return 0;
    }


Now that we have our original source code preserved and the updated source code
written, we can generate a patch using the ``diff`` utility.

.. note::
    Here we are using a handful of common arguments for the ``diff`` utility and
    their documentation is out of the scope of this document. Please reference
    the manual page on your local machine with: ``man diff`` for more
    information.

::

    $ diff -Naur cello.c.orig cello.c
    --- cello.c.orig        2016-05-26 17:21:30.478523360 -0500
    +++ cello.c     2016-05-27 14:53:20.668588245 -0500
    @@ -1,6 +1,6 @@
     #include<stdio.h>

     int main(void){
    -    printf("Hello World\n");
    +    printf("Hello World from my very first patch!\n");
         return 1;
     }

This is the output, you can see lines that start with a ``-`` are being removed
from the original source code and replaced by the line that starts wtih ``+``.
Let's now save that output to a file this time by redirecting the output to
a file so that we can use it later with the `patch`_ utility. It is not
a requirement but it's good practice to use a meaningful filename when creating
patches.

::

    $ diff -Naur cello.c.orig cello.c > cello-output-first-patch.patch

Now we want to restor the ``cello.c`` file to it's original source code such
that we can patch it with our new patch file.

::

    $ cp cello.c.orig cello.c

Next up, let's go ahead and patch the source code by redirecting the patch file
to the ``patch`` command.

::

    $ patch < cello-output-first-patch.patch
    patching file cello.c

    $ cat cello.c
    #include<stdio.h>

    int main(void){
        printf("Hello World from my very first patch!\n");
        return 1;
    }

From the output of the ``cat`` command we can see that the patch has been
successfully applied, let's build and run it now.

::

    $ make clean
    rm cello

    $ make
    gcc -o cello cello.c

    $ ./cello
    Hello World from my very first patch!


Congratulations, you have successfully created a patch, patched software, built
the patched software and run it!

Next up, installing things!


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

The example below is going to use the ``bello`` file that we had previously
created as the artibrary artifact subject to our installation method. Note that
you will either need `sudo`_ permissions or run this command as root excluding
the ``sudo`` portion of the command.

::

    $ install -m 0755 bello /usr/bin/bello


As this point, we can execute ``bello`` from our shell no matter what our
current working directory is because it has been installed into our `$PATH`_.

::

    $ cd ~/

    $ bello
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

    cello:
            gcc -o cello cello.c

    clean:
            rm cello

    install:
            install -m 0755 cello /usr/bin/cello

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

The following will build and install the simple ``cello.c`` program that we had
written previously.

::

    $ make
    gcc -o cello cello.c

    $ sudo make install
    install -m 0755 cello /usr/bin/cello

Just as in the previous example, we can now execute ``cello`` from our shell no
matter what our current working directory is because it has been installed into
our `$PATH`_.

::

    $ cd ~/

    $ cello
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
Source RPM (SRPM) and the binary RPM. Both of these share afile format and
tooling, but they represent very different things. The payload of a SRPM is a
SPEC file (which describes how to build a binary RPM) and the actually source
code that the resulting binary RPM will be built out of (including any patches
that may be needed).

RPM Packaging Workspace
-----------------------

In the :ref:`Prerequisite <pre-req>` section we installed a package named
``rpmdevtools`` which provides a number of handy utilities for RPM Packagers.

Feel free to explore the output of the following command and check out the
various utilities manual pages or help dialogs.

::

    $ rpm -ql rpmdevtools | grep bin

For the sake of setting up our RPM Packaging workspace let's use the
``rpmdev-setuptree`` utility to create our directory layout. We will then define
what each directory in the directory structure is meant for.

::

    $ rpmdev-setuptree

    $ tree ~/rpmbuild/
    /home/maxamillion/rpmbuild/
    |-- BUILD
    |-- RPMS
    |-- SOURCES
    |-- SPECS
    `-- SRPMS

    5 directories, 0 files

==================  ============================================================
Directory           Purpose
==================  ============================================================
BUILD               Various ``%buildroot`` directories will be created here when
                    packages are built. This is useful for inspecting a
                    postmortem of a build that goes bad if the logs output don't
                    provide enough information.
RPMS                Binary RPMs will land here in subdirectories of
                    Architecture. For example: ``noarch`` and ``x86_64``
SOURCES             Compressed source archives and any patches should go here,
                    this is where the ``rpmbuild`` command will look for them.
SPECS               SPEC files live here.
SRPMS               When the correct arguments are passed to ``rpmbuild`` to
                    build a Source RPM instead of a Binary RPM, the Source RPMs
                    (SRPMS) will land in this directory.
==================  ============================================================

Prepping our examples
---------------------

Now that we have our RPM Packaging Workspace setup, we should create simulated
upstream compressed archives of the example programs we have made. We will once
again list them here just in case a previous section was skipped.

Each implementation of the ``Hello World`` example script will be created into a
`gzip`_ compressed tarball which will be used to similate what an upstream
project might release as it's source code to then be consumed and packaged for
distribution.

.. note::
    What we are about to do here in this section is not normally something a RPM
    Packager has to do, this is normally what happens from an upstream software
    project, product, or developer who actually releases the software as source
    code. This is simply to setup the RPM Build example space and give some
    insight into where everything actually comes from.

bello
^^^^^

For the `bash`_ example implementation we will have a fake project called
*bello* and since the project named *bello* produces one thing and that's
a shell script named ``bello`` then it will only contain that in it's resulting
``tar.gz``. Let's pretend that this is version ``0.1`` of that software and
we'll mark the ``tar.gz`` file as such.

Here is the listing of the file as mentioned before.

``bello``

.. code-block:: sh

    #!/bin/bash

    printf "Hello World\n"

Let's make a project ``tar.gz`` out of our source code.

::

    $ mkdir /tmp/bello

    $ mv ~/bello /tmp/bello/

    $ cd /tmp/

    $ tar -cvzf bello-0.1.tar.gz bello
    bello/
    bello/bello

    $ mv /tmp/bello-0.1.tar.gz ~/rpmbuild/SOURCES/


pello
^^^^^

For the `Python`_ example implementation we will have a fake project called
*pello* and since the project named *pello* produces one thing and that's
a small program named ``pello.py`` then it will only contain that in it's
resulting ``tar.gz``. Let's pretend that this is version ``0.1.1`` of this
software and we'll mark the ``tar.gz`` file as such.

Here is the listing of the file as mentioned before.

``pello.py``

.. code-block:: python

    #!/usr/bin/env python

    print("Hello World")


Let's make a project ``tar.gz`` out of our source code.

::

    $ mkdir /tmp/pello

    $ mv ~/pello.py /tmp/pello/

    $ cd /tmp/

    $ tar -cvzf pello-0.1.1.tar.gz pello
    pello/
    pello/pello.py

    $ mv /tmp/pello-0.1.1.tar.gz ~/rpmbuild/SOURCES/


cello
^^^^^

For the `C`_ example implementation we will have a fake project called *cello*
and since the project named *cello* produces two things, the source code to our
program named ``cello.c`` and a ``Makefile`` we will need to make sure and
include both of these in our ``tar.gz``. Let's pretend that this is version
``1..0`` of the software and we'll mark the ``tar.gz`` file as such.

Here is the listing of the files involved as mentioned before.

You will notice the ``patch`` file is listed here, but it will not go in our
project tarball because it is something that we as the RPM Packager will apply
and not something that comes from the upstream source code. RPM Packages are
built in such a way that the original upstream source code in preserved in it's
prestine form just as released by it's creator. All patches required to the
software happen at RPM Build time, not before. We will place that in the
``~/rpmbuild/SOURCES/`` directory along side the "upstream" source code that we
are simulating here. (More on this later).

``cello.c``

.. code-block:: c

    #include <stdio.h>

    int main(void) {
        printf("Hello World\n");
        return 0;
    }


``cello-output-first-patch.patch``

.. code-block:: diff

    --- cello.c.orig        2016-05-26 17:21:30.478523360 -0500
    +++ cello.c     2016-05-27 14:53:20.668588245 -0500
    @@ -1,6 +1,6 @@
     #include<stdio.h>

     int main(void){
    -    printf("Hello World\n");
    +    printf("Hello World from my very first patch!\n");
         return 1;
     }

``Makefile``

.. code-block:: make

    cello:
            gcc -o cello cello.c

    clean:
            rm cello

    install:
            install -m 0755 cello /usr/bin/cello

Let's make a project ``tar.gz`` out of our source code.

::

    $ mkdir /tmp/cello

    $ mv ~/cello.c /tmp/cello/

    $ mv ~/Makefile /tmp/cello/

    $ cd /tmp/

    $ tar -cvzf cello-1.0.tar.gz cello
    cello/
    cello/Makefile
    cello/cello.c

    $ mv /tmp/cello-1.0.tar.gz ~/rpmbuild/SOURCES/

    $ mv ~/cello-output-first-patch.patch ~/rpmbuild/SOURCES/


Great, now we have all of our upstream source code prep'd and ready to be turned
into RPMs! Let's move on to learning with a RPM SPEC file is and how it relates
to building RPMs.


What is a SPEC File?
--------------------

A SPEC file can be though of the as the **recipe** for that the ``rpmbuild``
utility uses to actually build an RPM. It tells the build system what to do by
defining instructions in a series of sections. The sections are defined between
the *Preamble* and the *Body*. Within the *Preamble* we will define a series of
metadata items that will be used through out the *Body* and the *Body* is where
the bulk of the work is accomplished.

Preamble Items
^^^^^^^^^^^^^^

In the table below you will find the items that are used in RPM Spec files in
the Preamble section.

==================  ============================================================
SPEC Directive      Definition
==================  ============================================================
``Name``            The (base) name of the package, which should match the SPEC
                    file name
``Version``         The upstream version number of the software.
``Release``         The initial value should normally be 1%{?dist}, this value
                    should be incremented each new release of the package and
                    reset to 1 when a new ``Version`` of the software is built.
``Summary``         A brief, one-line summary of the package.
``License``         The license of the software being packaged. For packages
                    that are destined for community distributions such as
                    `Fedora`_ this must be an Open Source License obiding by the
                    specific distribution's Licensing Guidelines.
``URL``             The full URL for more information about the program (most
                    often this is the upstream project website for the software
                    being packaged).
``Source0``         Path or URL to the compressed archive of the upstream source
                    code (unpatched, patches are handled elsewhere). This is
                    ideally a listing of the upstream URL resting place and not
                    just a local copy of the source. If needed, more SourceX
                    directives can be added, incrementing the number each time
                    such as: Source1, Source2, Source3, and so on.
``Patch0``          The name of the first patch to apply to the source code if
                    necessary. If needed, more PatchX directives can be added,
                    incrementing the number each time such as: Patch1, Patch2,
                    Patch3, and so on.
``BuildArch``       If the package is not architecture dependent, i.e. written
                    entirely in an interpreted programming language, this should
                    be ``BuildArch: noarch`` otherwise it will automatically
                    inherit the Architecture of the machine it's being built on.
``BuildRequires``   A comma-separated list of packages required for building
                    (compiling) the program. There can be multiple entries of
                    ``BuildRequires`` each on it's own line in the SPEC file.
``Requires``        A comma-separate list of packages that are required by the
                    software to run once installed.
``ExcludeArch``     In the event a piece of software can not operate on a
                    specific processor architectue, you can exclude it here.
==================  ============================================================


Body Items
^^^^^^^^^^

In the table below you will find the items that are used in RPM Spec files in
the body.

==================  ============================================================
SPEC Directive      Definition
==================  ============================================================
``%description``    A full description of the software packaged in the RPM, this
                    can consume multiple lines and be broken into paragraphs.
``%prep``           Command or series of commands to prepare the software
                    to be built. Example is to uncompress the archive in
                    ``Source0``. This can contain shell script.
``%build``          Command or series of commands used to actually perform the
                    build procedure (compile) of the software.
``%install``        Command or series of commands used to actually install the
                    various artifacts into a resulting location in the FHS.
                    Something to note is that this is done withing the relative
                    context of the ``%buildroot`` (more on that later).
``%check``          Command or series of commands to "test" the software. This
                    is normally things such as unit tests.
``%files``          The list of files that will be installed in their final
                    resting place in the context of the target system.
``%changelog``      A record of changes that have happened to the package
                    between different ``Version`` or ``Release`` builds.
==================  ============================================================

Advanced items
^^^^^^^^^^^^^^

There are a series of advanced items that are known as *scriptlets* and
*triggers* which take effect at different points through out the installation
process on the target machine (not the build process). These are out of the
scope of this document, but there is plenty of information on them in the
:ref:`Appendix <appendix>`.

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

Advanced SPEC File Topics
-------------------------

.. FIXME

Scriptlets
^^^^^^^^^^

.. FIXME

Triggers
^^^^^^^^

.. FIXME


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
.. _RPM Official Documentation: http://rpm.org/wiki/Docs
.. _$PATH: https://en.wikipedia.org/wiki/PATH_%28variable%29
.. _Part 1: http://www.ibm.com/developerworks/library/l-rpm1/
.. _Part 2: http://www.ibm.com/developerworks/library/l-rpm2/
.. _Part 3: http://www.ibm.com/developerworks/library/l-rpm3/
.. _shebang: https://en.wikipedia.org/wiki/Shebang_%28Unix%29
.. _tarball: https://en.wikipedia.org/wiki/Tar_%28computing%29
.. _C: https://en.wikipedia.org/wiki/C_%28programming_language%29
.. _architecture: https://en.wikipedia.org/wiki/Microarchitecture
.. _Package Managers: https://en.wikipedia.org/wiki/Package_manager
.. _coreutils: http://www.gnu.org/software/coreutils/coreutils.html
.. _diffutils: http://www.gnu.org/software/diffutils/diffutils.html
.. _Interpreter: https://en.wikipedia.org/wiki/Interpreter_%28computing%29
.. _programming language:
    https://en.wikipedia.org/wiki/Programming_language
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
