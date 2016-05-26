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

General Topics and Background
=============================

In this section will we walk through various topics about building software that
lead up to being able to successfully build RPMs:

* What is Source Code?
* How Programs Are Made
* Building from source into an output artifact (what type of artifact will
  depend on the scenario and we will define what this means more specifically
  with examples).
* Defining what we contextually mean as a "buildroot" and how that can mean
  different things to different people based on scenario. (This will directly
  relate to RPM building specific topics later)
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
~~~~~~~~~~~~~~~~~~~~~~

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
~~~~~~~~~~~~~~~~

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
~~~~~~~~~~~~~~~~~~~~~~

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
.............

In the below example we are going to invoke the `C`_ compiler from the GNU
Compiler Collection (`GCC`_).

::

    gcc -o hello hello.c


From here we can actually execute the resulting output binary.

::

    $ ./hello
    Hello World

That's it! You've built natively compiled software from source code!

Interpreted Code
~~~~~~~~~~~~~~~~

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
..................

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
...............

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


Buildroots
----------

Placing Things on the Filesystem
---------------------------------

RPM Packages
============

What is a RPM?
--------------

What is a SPEC File?
--------------------

Basic SPEC File layout
----------------------

RPM Macros and their use in SPEC files
--------------------------------------

Prepping Our Build Environment
==============================

Building RPMS
=============

Appendix
========

Here you will find supplementary information that is very good to know and will
likely prove to helpful for anyone who is going to be building RPMs in an
serious capacity but isn't necessarily a hard requirement to learn how to
package RPMs in the first place which is what the main goal of this document is.

Prestine Build Environments with Mock
-------------------------------------

References
==========

Below are references to various topics of interest around RPMs, RPM Packaging,
and RPM Building.

* `RPM`_.org
* `Gurulabs CREATING RPMS (Student Version)`_
* `Fedora Packaging Guidelines`_
* `OpenSUSE Packaging Guidelines`_

.. _RPM: http://rpm.org/
.. _GCC: https://gcc.gnu.org/
.. _Fedora: https://getfedora.org/
.. _CentOS: https://www.centos.org/
.. _Python: https://www.python.org/
.. _Red Hat: https://www.redhat.com/en
.. _bash: https://www.gnu.org/software/bash/
.. _Linux: https://en.wikipedia.org/wiki/Linux
.. _CPython: https://en.wikipedia.org/wiki/CPython
.. _shebang: https://en.wikipedia.org/wiki/Shebang_%28Unix%29
.. _C: https://en.wikipedia.org/wiki/C_%28programming_language%29
.. _architecture: https://en.wikipedia.org/wiki/Microarchitecture
.. _Package Managers: https://en.wikipedia.org/wiki/Package_manager
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
