.. _general-background:

General Topics and Background
=============================

In this section will we walk through various topics about building software that
are helpful background or otherwise general topics that are important for a good
RPM Packager to be familiar with.

* What is `Source Code`_?
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

    The `shebang`_ allows us to use a text file as an executable and the system
    program loader will parse the line at the top of the file containing
    a ``#!`` character sequence looking a path to the binary executable to use
    as the programming language interpreter.

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

.. note::
    The practice of byte compiling `Python`_ is common but the exact procedure
    shown here is not. This is meant to be a simple example. For more
    information, please reference the `Software Packaging and Distribution`_
    documentation.

::

    $ python -m compileall pello.py
    $ python pello.pyc
    Hello World

    $ file foo.pyc
    foo.pyc: python 2.7 byte-compiled

You can see here that after we byte-compiled the source ``.py`` file we now have
a ``.pyc`` file which is of ``python 2.7 byte-compiled`` filetype. This file can
be run with the python language virtual machine and is more efficient than
passing in just the raw source file, which is a desired attribute of resulting
software we as a RPM Packager will distribute out to systems.

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
a blanket. Patches in software are formatted as what is called a *diff* since
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
step in patching software is to preserve the original source code because we
want to keep the original source code in prestine condition as we will "patch
it" instead of simply modifying it. A common practice for this is to copy it and
append ``.orig`` to the filename. Let's do that now.

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
    -    printf("Hello World!\n");
    +    printf("Hello World from my very first patch!\n");
         return 1;
     }
    \ No newline at end of file

This is the output, you can see lines that start with a ``-`` are being removed
from the original source code and replaced by the line that starts wtih ``+``.
Let's now save that output to a file this time by redirecting the output to
a file so that we can use it later with the `patch`_ utility. It is not
a requirement but it's good practice to use a meaningful filename when creating
patches.

::

    $ diff -Naur cello.c.orig cello.c > cello-output-first-patch.patch

Now we want to restore the ``cello.c`` file to it's original source code such
that it is restored to it's prestine state and we we can patch it with our new
patch file. The reason this partular process is important is because this is how
it is done when building RPMs, the original source code is left in prestine
condition and we patch it during the process that prepares to source code to be
built.

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

.. note::
    The creation of ``Makefile`` is normally done by the developer who writes
    the original source code of the software in question and as a RPM Packager
    this is not generally something you will need to do. This is purely an
    exercise for background knowledge and we will expand upon this as it relates
    to RPM Packaging later.


Open the ``Makefile`` file up in your favorite text editor and make the
appropriate edits needed so that it ends up looking exactly as the following.

.. note::
    The use of `$(DESTDIR)`_ is a `GNU make`_ built-in and is commonly used to
    install into alternative destination directories.

``Makefile``

.. code-block:: make

    cello:
            gcc -o cello cello.c

    clean:
            rm cello

    install:
            mkdir -p $(DESTDIR)/usr/bin
            install -m 0755 cello $(DESTDIR)/usr/bin/cello

Now we are able to use the make file to both build and install the software from
source. Note that for the installation portion, like before when we ran the raw
``install`` command, you will need either `sudo`_ permissions or be the ``root``
user and ommit the ``sudo`` portion of the command.

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

Prepping our example upstream source code
-----------------------------------------

.. note::
    If you're familiar with how upstream software is distributed and would like
    to skip this, please feel free to `download the example source code`_ for
    our fake upstream projects skip this section. However if you are curious how
    the examples are created please feel free to read along.


Now that we have our RPM Packaging Workspace setup, we should create simulated
upstream compressed archives of the example programs we have made. We will once
again list them here just in case a previous section was skipped.

.. note::
    What we are about to do here in this section is not normally something a RPM
    Packager has to do, this is normally what happens from an upstream software
    project, product, or developer who actually releases the software as source
    code. This is simply to setup the RPM Build example space and give some
    insight into where everything actually comes from.

We will also assume `GPLv3`_ as the `Software License`_ for all of these
simulated upstream software releases. As such, we will need a ``LICENSE`` file
included with each source code release. We include this in our simulated
upstream software release because encounters with a `Software License`_ when
packaging RPMs is a very common occurance for a RPM Packager and we should know
how to properly handle them.

.. note::
    The method used below to create th ``LICENSE`` file is known as a `here
    document`_.

Let us go ahead and make a ``LICENSE`` file that can be included in the source
code "release" for each example.

::

    $ cat > /tmp/LICENSE <<EOF
    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
    EOF

Each implementation of the ``Hello World`` example script will be created into a
`gzip`_ compressed tarball which will be used to similate what an upstream
project might release as it's source code to then be consumed and packaged for
distribution.

Below is an example procedure for each example implementation.

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

    $ mkdir /tmp/bello-0.1

    $ mv ~/bello /tmp/bello-0.1/

    $ cp /tmp/LICENSE /tmp/bello-0.1/

    $ cd /tmp/

    $ tar -cvzf bello-0.1.tar.gz bello-0.1
    bello-0.1/
    bello-0.1/LICENSE
    bello-0.1/bello

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

    $ mkdir /tmp/pello-0.1.1

    $ mv ~/pello.py /tmp/pello-0.1.1/

    $ cp /tmp/LICENSE /tmp/pello-0.1.1/

    $ cd /tmp/

    $ tar -cvzf pello-0.1.1.tar.gz pello-0.1.1
    pello-0.1.1/
    pello-0.1.1/LICENSE
    pello-0.1.1/pello.py

    $ mv /tmp/pello-0.1.1.tar.gz ~/rpmbuild/SOURCES/


cello
^^^^^

For the `C`_ example implementation we will have a fake project called *cello*
and since the project named *cello* produces two things, the source code to our
program named ``cello.c`` and a ``Makefile`` we will need to make sure and
include both of these in our ``tar.gz``. Let's pretend that this is version
``1.0`` of the software and we'll mark the ``tar.gz`` file as such.

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

    $ mkdir /tmp/cello-1.0

    $ mv ~/cello.c /tmp/cello-1.0/

    $ mv ~/Makefile /tmp/cello-1.0/

    $ cp /tmp/LICENSE /tmp/cello-1.0/

    $ cd /tmp/

    $ tar -cvzf cello-1.0.tar.gz cello-1.0
    cello-1.0/
    cello-1.0/Makefile
    cello-1.0/cello.c
    cello-1.0/LICENSE

    $ mv /tmp/cello-1.0.tar.gz ~/rpmbuild/SOURCES/

    $ mv ~/cello-output-first-patch.patch ~/rpmbuild/SOURCES/


Great, now we have all of our upstream source code prep'd and ready to be turned
into RPMs!

.. include:: citations.rst
