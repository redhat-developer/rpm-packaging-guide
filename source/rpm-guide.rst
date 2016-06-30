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
* `Red Hat Enterprise Linux`_ (often referred to as `RHEL`_ for short)

While these distros are the target environment, it should be noted that lessons
learned here should be applicable across all distributions that are `RPM based`_
but the examples will need to be adapted for distribution specific items such as
prerequisite installation items, guidelines, or macros. (More on macros later)

.. note::
    If you have made it this far and don't know what a software package or a
    GNU/Linux distribution is, you might be best served by exploring some
    articles on the topics of `Linux`_ and `Package Managers`_.

RPM Packages
============

In this section we are going to hopefully cover everything you ever wanted to
know about the RPM Packaging format, and if not then hopefully the contents of
the :ref:`Appendix <appendix>` will satisfy the craving for knowledge that has
been left out of this section.

What is an RPM?
---------------

To kick things off, let's first define what an RPM actually is. An RPM package
is simply a file that contains some files as well as information the system
needs to know about those files. More specifically, it is a file containing a
`cpio`_ archive and metadata about itself. The `cpio`_ archive is the payload
and the RPM Header contains the metadata. The package manager ``rpm`` uses this
metadata to determine things like dependencies, where to install files, etc.

Conventionally speaking there are two different types of RPM, there is the
Source RPM (SRPM) and the binary RPM. Both of these share a file format and
tooling, but they represent very different things. The payload of a SRPM is a
SPEC file (which describes how to build a binary RPM) and the actually source
code that the resulting binary RPM will be built out of (including any patches
that may be needed).

RPM Packaging Workspace
-----------------------

In the :ref:`Prerequisites <pre-req>` section we installed a package named
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

.. _what-is-spec-file:

What is a SPEC File?
--------------------

A SPEC file can be thought of the as the **recipe** that the ``rpmbuild``
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
                    `Fedora`_ this must be an Open Source License abiding by the
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
                    specific processor architecture, you can exclude it here.
==================  ============================================================

There are three "special" directives listed above which are ``Name``,
``Version``, and ``Release`` which are used to create the RPM package's
filename. You will often see these referred to by other RPM Package Maintainers
and Systems Administrators as **N-V-R** or just simply **NVR** as RPM package
filenames are of ``NAME-VERSION-RELEASE`` format.

For example, if we were to query about a specific package:

::

    $ rpm -q python
    python-2.7.5-34.el7.x86_64

Here ``python`` is our Package Name, ``2.7.5`` is our Version, and ``34.el7`` is
our Release. The final marker is ``x86_64`` and is our architecture, which is
not something we control as a RPM Packager (with the exception of ``noarch``,
more on that later) but is a side effect of the ``rpmbuild`` build environment,
something we will cover in more detail later.


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

There are a series of advanced items including what are known as *scriptlets*
and *triggers* which take effect at different points through out the
installation process on the target machine (not the build process). These are
out of the scope of this document, but there is plenty of information on them in
the :ref:`Appendix <appendix>`.

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
installation transaction. Ultimately the payload of the resulting Binary RPM is
extracted from this environment and put into the `cpio`_ archive.

.. _rpm-macros:

RPM Macros
----------

A `rpm macro`_ is a straight text substitution that can be conditionally assigned
based on the optional evaluation of a statement when certain built-in
functionality is used. What this means is that we can have RPM perform text
substitutions for us so that we don't have to.

An example of how this can be extremely useful for a RPM Packager is if we
wanted to reference the `Version` of the software we are packaging multiple
times through out our SPEC file but only want to define it one time. We would
then use the ``%{version}`` macro and it would be substituted in place by
whatever the actual version number is that was entered in the `Version` field of
the SPEC.

.. note::
    I handy utility of the ``rpm`` command for packager is the ``--eval`` flag
    which allows you to ask rpm to evaluate a macro so if you see one in a SPEC
    file that you're not familiar with you can quickly find out what it
    evaluates to.

    ::

        $ rpm --eval %{_bindir}
        /usr/bin

        $ rpm --eval %{_libexecdir}
        /usr/libexec


A common macro we will encounter as a packager is ``%{?dist}`` which signifies
the "distribution tag" allowing for a short textual representation of the
distribution used for the build to be injected into a text field.

For example:

::

    # On a RHEL 7.x machine
    $ rpm --eval %{?dist}
    .el7

    # On a Fedora 23 machine
    $ rpm --eval %{?dist}
    .fc23

For more information, please reference the :ref:`More on Macros <more-macros>`
section of the :ref:`Appendix <appendix>`.


Working with SPEC files
-----------------------

As a RPM Packager, you will likely spend a large majority of your time when
packaging software in the SPEC file since this is the recipe we use to tell
``rpmbuild`` how to actually perform a build. In this section we will discuss
how to create and modify a spec file.

When it comes time to package new software, you will want to create a new SPEC
file and we *could* write one from scratch from memory but that sounds boring
and tedious so let's not do that. The good news is that we're in luck and
there's an utility called ``rpmdev-newspec`` which will create one for us and we
will just fill in the various directives or add new fields as needed. This
provides us with a nice baseline template.

If you have not already done so by way of another section of the guide, go ahead
and download the example programs now and place them in your
``~/rpmbuild/SOURCES`` directory.

* `bello-0.1.tar.gz`_
* `pello-0.1.1.tar.gz`_
* `cello-1.0.tar.gz`_

    * `cello-output-first-patch.patch`_

Let's go ahead and create a SPEC file for each of our three implementations of
our example and then we will look at the SPEC files and the

.. note::
    Some programmer focused text editors will pre-populate a new file with the
    extension ``.spec`` with a SPEC template of their own but ``rpmdev-newspec``
    is an editor-agnostic method which is why it is chosen here.

::

    $ cd ~/rpmbuild/SPECS

    $ rpmdev-newspec bello
    bello.spec created; type minimal, rpm version >= 4.11.

    $ rpmdev-newspec cello
    cello.spec created; type minimal, rpm version >= 4.11.

    $ rpmdev-newspec pello
    pello.spec created; type minimal, rpm version >= 4.11.

You will now find three SPEC files in your ``~/rpmbuild/SPECS/`` directory all
matching the names you passed to ``rpmdev-newspec`` but with the ``.spec`` file
extension. Take a moment to look at the files using your favorite text editor,
the directives should look familiar from the
:ref:`What is a SPEC File? <what-is-spec-file>` section. We will discuss the
exact information we will input into these fields in the following sections that
will focus specifically on each example.

.. note::
    The ``rpmdev-newspec`` utility does not use `Linux`_ Distribution specific
    guidelines or conventions, however this document is targeted towards using
    conventions and guidelines for `Fedora`_, `CentOS`_, and `RHEL`_ so you will
    notice:

    We remove the use of ``rm $RPM_BUILD_ROOT`` as it is no longer necessary to
    perform that task when building on `RHEL`_ or `CentOS` 7.0 or newer or on
    `Fedora`_ version 18 or newer.

    We also will favor the use of ``%{buildroot}`` notation over
    ``$RPM_BUILD_ROOT`` when referencing RPM's Buildroot for consistency with
    all other defined or provided macros through out the SPEC

There are three examples below, each one is meant to be self-sufficient in
instruction such that you can jump to a specific one if it matches your needs
for packaging. However, feel free to read them straight through for a full
exploration of packaging different kinds of software.

===============     ============================================================
Software Name       Explanation of example
===============     ============================================================
bello               Software written in a raw interpreted programming language
                    does doesn't require a build but only needs files installed.
                    If a pre-compiled binary needs to be packaged, this method
                    could also be used since the binary would also just be
                    a file.
pello               Software written in a byte-compiled interpreted programming
                    language used to demonstrate the installation of a byte
                    compile process and the installation of the resulting
                    pre-optimized files.
cello               Software written in a natively compiled programming language
                    to demonstrate an common build and installation process
                    using tooling for compiling native code.
===============     ============================================================

bello
^^^^^

Our first SPEC file will be for our example written in `bash`_ shell script that
you downloaded (or you created a simulated upstream release in the :ref:`General
Topics and Background <general-background>` Section) and placed its source code
into ``~/rpmbuild/SOURCES/`` earlier. Let's go ahead and open the file
``~/rpmbuild/SOURCES/bello.spec`` and start filling in some fields.

The following is the output template we were given from ``rpmdev-newspec``.

.. code-block:: spec

    Name:           bello
    Version:
    Release:        1%{?dist}
    Summary:

    License:
    URL:
    Source0:

    BuildRequires:
    Requires:

    %description


    %prep
    %setup -q


    %build
    %configure
    make %{?_smp_mflags}


    %install
    rm -rf $RPM_BUILD_ROOT
    %make_install


    %files
    %doc



    %changelog
    * Tue May 31 2016 Adam Miller <maxamillion@fedoraproject.org>
    -

Let us begin with the first set of directives that ``rpmdev-newspec`` has
grouped together at the top of the file: ``Name``, ``Version``, ``Release``,
``Summary``. The ``Name`` is already specified because we provided that
information to the command line for ``rpmdev-newspec``.

Let's set the ``Version`` to match what the "upstream" release version of the
*bello* source code is, which we can observe is ``0.1`` as set by the example
code we downloaded (or we created in the :ref:`General Topics and Background
<general-background>` Section).

The ``Release`` is already set to ``1%{?dist}`` for us, the numerical value
which is initially ``1`` should be incremented every time the package is updated
for any reason, such as including a new patch to fix an issue, but doesn't have
a new upstream release ``Version``. When a new upstream release happens (for
example, bello version ``0.2`` were released) then the ``Release`` number should
be reset to ``1``. The *disttag* of ``%{?dist}`` should look familiar from the
previous section's coverage of :ref:`RPM Macros <rpm-macros>`.

The ``Summary`` should be a short, one-line explanation of what this software
is.

After your edits, the first section of the SPEC file should resemble the
following:

.. code-block:: spec

    Name:           bello
    Version:        0.1
    Release:        1%{?dist}
    Summary:        Hello World example implemented in bash script

Now, let's move on to the second set of directives that ``rpmdev-newspec`` has
grouped together in our SPEC file: ``License``, ``URL``, ``Source0``.

The ``License`` field is the `Software License`_ associated with the source code
from the upstream release. The exact format for how to label the License in your
SPEC file will vary depending on which specific RPM based `Linux`_ distribution
guidelines you are following, we will use the notation standards in the `Fedora
License Guidelines`_ for this document and as such this field will contain the
text ``GPLv3+``

The ``URL`` field is the upstream software's website, not the source code
download link but the actual project, product, or company website where someone
would find more information about this particular piece of software. Since we're
just using an example, we will call this ``https://example.com/bello``. However,
we will use the rpm macro variable of ``%{name}`` in it's place for consistency
and the resulting entry will be ``https://example.com/%{name}``.

The ``Source0`` field is where the upstream software's source code should be
able to be downloaded from. This URL should link directly to the specific
version of the source code release that this RPM Package is packaging. Once
again, since this is an example we will use an example value:
``https://example.com/bello/releases/bello-0.1.tar.gz`` and while we might want
to, we should note that this example URL has hard coded values in it that are
possible to change in the future and are potentially even likely to change such
as the release version ``0.1``. We can simplify this by only needing to update
one field in the SPEC file and allowing it to be reused. we will use the value
``https://example.com/%{name}/releases/%{name}-%{version}.tar.gz`` instead of
the hard coded examples string previously listed.

After your edits, the top portion of your spec file should look like the
following:

.. code-block:: spec

    Name:           bello
    Version:        0.1
    Release:        1%{?dist}
    Summary:        Hello World example implemented in bash script

    License:        GPLv3+
    URL:            https://example.com/%{name}
    Source0:        https://example.com/%{name}/release/%{name}-%{version}.tar.gz


Next up we have ``BuildRequires`` and ``Requires``, each of which define
something that is required by the package. However, ``BuildRequires`` is to tell
``rpmbuild`` what is needed by your package at **build** time and ``Requires``
is what is needed by your package at **run** time. In this example there is no
**build** because the `bash`_ script is a raw interpreted programming language
so we will only be installing files into locations on the system, but it does
require the `bash`_ shell environment in order to execute so we will need to
define ``bash`` as a requirement using the ``Requires`` directive.

Since we don't have a build step, we can simply omit the ``BuildRequires``
directive. There is no need to define is as "undefined" or otherwise, omitting
it's inclusion will suffice.

Something we need to add here since this is software written in an interpreted
programming language with no natively compiled extensions is a ``BuildArch``
entry that is set to ``noarch`` in order to tell RPM that this package does not
need to be bound to the processor architecture that it is built using.

After your edits, the top portion of your spec file should look like the
following:

.. code-block:: spec

    Name:           bello
    Version:        0.1
    Release:        1%{?dist}
    Summary:        Hello World example implemented in bash script

    License:        GPLv3+
    URL:            https://example.com/%{name}
    Source0:        https://example.com/%{name}/release/%{name}-%{version}.tar.gz

    Requires:       bash

    BuildArch:      noarch

The following directives can be thought of as "section headings" because they
are directives that can define multi-line, multi-instruction, or scripted tasks
to occur. We will walk through them one by one just as we did with the previous
items.

The ``%description`` should be a longer, more full length description of the
software being packaged than what is found in the ``Summary`` directive. For the
sake of our example, this isn't really going to contain much content but this
section can be a full paragraph or more than one paragraph if desired.

The ``%prep`` section is where we *prepare* our build environment or workspace
for building. Most often what happens here is the expansion of compressed
archives of the source code, application of patches, and potentially parsing of
information provided in the source code that is necessary in a later portion of
the SPEC. In this section we will simply use the provided macro ``%setup -q``.

The ``%build`` section is where we tell the system how to actually build the
software we are packaging. However, since this software doesn't need to be built
we can simply leave this section blank (removing what was provided by the
template).

The ``%install`` section is where we instruct ``rpmbuild`` how to install our
previously built software (in the event of a build process) into the
``BUILDROOT`` which is effectively a `chroot`_ base directory with nothing in it
and we will have to construct any paths or directory hierarchies that we will
need in order to install our software here in their specific locations. However,
our RPM Macros help us accomplish this task without having to hardcode paths.
Since the only thing we need to do in order to install ``bello`` into this
environment is create the destination directory for the executable `bash`_
script file and then install the file into that directory, we can do so by using
the same ``install`` command but we will make a slight modification since we are
inside the SPEC file and we will use the macro variable of ``%{name}`` in it's
place for consistency.

The ``%install`` section should look like the following after your edits:

.. code-block:: spec

    %install

    mkdir -p %{buildroot}/%{_bindir}

    install -m 0755 %{name} %{buildroot}/%{_bindir}/%{name}

The ``%files`` section is where we provide the list of files that this RPM
provides and where it's intended for them to live on the system that the RPM is
installed upon. Note here that this isn't relative to the ``%{buildroot}`` but
the full path for the files as they are expected to exist on the end system
after installation. Therefore, the listing for the ``bello`` file we are
installing will be ``%{_bindir}/%{name}`` (this would be ``/usr/bin/bello`` if
we weren't using the rpm macros).

Also within this section, you will sometimes need a built-in macro to provide
context on a file. This can be useful for Systems Administrators and end users
who might want to query the system with ``rpm`` about the resulting package.
The built-in macro we will use here is ``%license`` which will tell ``rpmbuild``
that this is a software license file in the package file manifest metadata.

The ``%files`` section should look like the following after your edits:

.. code-block:: spec

    %files
    %license LICENSE
    %{_bindir}/%{name}

The last section, ``%changelog`` is a list of date-stamped entries that
correlate to a specific Version-Release of the package. This is not meant to be
a log of what changed in the software from release to release, but specifically
to packaging changes. For example, if software in a package needed patching or
there was a change needed in the build procedure listed in the ``%build``
section that information would go here. Each change entry can contain multiple
items and each item should start on a new line and begin with a ``-`` character.
Below is our example entry:

.. code-block:: spec

    %changelog
    * Tue May 31 2016 Adam Miller <maxamillion@fedoraproject.org> - 0.1-1
    - First bello package
    - Example second item in the changelog for version-release 0.1-1

Note the format above, the date-stamp will begin with a ``*`` character,
followed by the calendar day of the week, the month, the day of the month, the
year, then the contact information for the RPM Packager. From there we have
a ``-`` character before the Version-Release, which is an often used convention
but not a requirement. Then finally the Version-Release.

That's it! We've written an entire SPEC file for **bello**! In the next section
we will cover how to build the RPM!

The full SPEC file should now look like the following:

.. code-block:: spec

    Name:           bello
    Version:        0.1
    Release:        1%{?dist}
    Summary:        Hello World example implemented in bash script

    License:        GPLv3+
    URL:            https://www.example.com/%{name}
    Source0:        https://www.example.com/%{name}/releases/%{name}-%{version}.tar.gz

    Requires:       bash

    BuildArch:      noarch

    %description
    The long-tail description for our Hello World Example implemented in
    bash script

    %prep
    %setup -q

    %build

    %install

    mkdir -p %{buildroot}/%{_bindir}

    install -m 0755 %{name} %{buildroot}/%{_bindir}/%{name}

    %files
    %license LICENSE
    %{_bindir}/%{name}

    %changelog
    * Tue May 31 2016 Adam Miller <maxamillion@fedoraproject.org> - 0.1-1
    - First bello package
    - Example second item in the changelog for version-release 0.1-1

pello
^^^^^

Our second SPEC file will be for our example written in the `Python`_
programming language that  you downloaded (or you created a simulated upstream
release in the :ref:`General Topics and Background <general-background>`
Section) and placed it's source code into ``~/rpmbuild/SOURCES/``
earlier. Let's go ahead and open the file ``~/rpmbuild/SOURCES/bello.spec``
and start filling in some fields.

Before we start down this path, we need to address something somewhat unique
about byte-compiled interpreted software. Since we we will be byte-compiling
this program, the `shebang`_ is no longer applicable because the resulting file
will not contain the entry. It is common practice to either have a
non-byte-compiled shell script that will call the executable or have a small
bit of the `Python`_ code that isn't byte-compiled as the "entry point" into
the program's execution. This might seem silly for our small example but for
large software projects with many thousands of lines of code, the performance
increase of pre-byte-compiled code is sizeable.

.. note::
    The creation of a script to call the byte-compiled code or having
    a non-byte-compiled entry point into the software is something that upstream
    software developers most often address before doing a release of their
    software to the world, however this is not always the case and this exercise
    is meant to help address what to do in those situations. For more
    information on how `Python`_ code is normally released and distributed
    please reference the `Software Packaging and Distribution`_ documentation.

We will make a small shell script to call our byte compiled code to be the entry
point into our software. We will do this as a part of our SPEC file itself in
order to demonstrate how you can script actions inside the SPEC file. We will
cover the specifics of this in the ``%install`` section later.

Let's go ahead and open the file ``~/rpmbuild/SOURCES/pello.spec`` and start
filling in some fields.

The following is the output template we were given from ``rpmdev-newspec``.

.. code-block:: spec

    Name:           pello
    Version:
    Release:        1%{?dist}
    Summary:

    License:
    URL:
    Source0:

    BuildRequires:
    Requires:

    %description


    %prep
    %setup -q


    %build
    %configure
    make %{?_smp_mflags}


    %install
    rm -rf $RPM_BUILD_ROOT
    %make_install


    %files
    %doc



    %changelog
    * Tue May 31 2016 Adam Miller <maxamillion@fedoraproject.org>
    -

Just as with the first example, let's begin with the first set of directives
that ``rpmdev-newspec`` has grouped together at the top of the file:
``Name``, ``Version``, ``Release``, ``Summary``. The ``Name`` is already
specified because we provided that information to the command line for
``rpmdev-newspec``.

Let's set the ``Version`` to match what the "upstream" release version of the
*pello* source code is, which we can observe is ``0.1.1`` as set by the example
code we downloaded (or we created in the :ref:`General Topics and Background
<general-background>` Section).

The ``Release`` is already set to ``1%{?dist}`` for us, the numerical value
which is initially ``1`` should be incremented every time the package is updated
for any reason, such as including a new patch to fix an issue, but doesn't have
a new upstream release ``Version``. When a new upstream release happens (for
example, pello version ``0.1.2`` were released) then the ``Release`` number
should be reset to ``1``. The *disttag* of ``%{?dist}`` should look familiar
from the previous section's coverage of :ref:`RPM Macros <rpm-macros>`.

The ``Summary`` should be a short, one-line explanation of what this software
is.

After your edits, the first section of the SPEC file should resemble the
following:

.. code-block:: spec

    Name:           pello
    Version:        0.1.1
    Release:        1%{?dist}
    Summary:        Hello World example implemented in Python

Now, let's move on to the second set of directives that ``rpmdev-newspec`` has
grouped together in our SPEC file: ``License``, ``URL``, ``Source0``.

The ``License`` field is the `Software License`_ associated with the source code
from the upstream release. The exact format for how to label the License in your
SPEC file will vary depending on which specific RPM based `Linux`_ distribution
guidelines you are following, we will use the notation standards in the `Fedora
License Guidelines`_ for this document and as such this field will contain the
text ``GPLv3+``

The ``URL`` field is the upstream software's website, not the source code
download link but the actual project, product, or company website where someone
would find more information about this particular piece of software. Since we're
just using an example, we will call this ``https://example.com/pello``. However,
we will use the rpm macro variable of ``%{name}`` in it's place for consistency.

The ``Source0`` field is where the upstream software's source code should be
able to be downloaded from. This URL should link directly to the specific
version of the source code release that this RPM Package is packaging. Once
again, since this is an example we will use an example value:
``https://example.com/pello/releases/pello-0.1.1.tar.gz``

We should note that this example URL has hard coded values in it that are
possible to change in the future and are potentially even likely to change such
as the release version ``0.1.1``. We can simplify this by only needing to update
one field in the SPEC file and allowing it to be reused. we will use the value
``https://example.com/%{name}/releases/%{name}-%{version}.tar.gz`` instead of
the hard coded examples string previously listed.

After your edits, the top portion of your spec file should look like the
following:

.. code-block:: spec

    Name:           pello
    Version:        0.1.1
    Release:        1%{?dist}
    Summary:        Hello World example implemented in Python

    License:        GPLv3+
    URL:            https://example.com/%{name}
    Source0:        https://example.com/%{name}/release/%{name}-%{version}.tar.gz


Next up we have ``BuildRequires`` and ``Requires``, each of which define
something that is required by the package. However, ``BuildRequires`` is to tell
``rpmbuild`` what is needed by your package at **build** time and ``Requires``
is what is needed by your package at **run** time.

In this example we will need the ``python`` package in order to perform the
byte-compile build process. We will also need the ``python`` package in order to
execute the byte-compiled code at runtime and therefore need to define
``python`` as a requirement using the ``Requires`` directive. We will also need
the ``bash`` package in order to execute the small entry-point script we will
use here.

Something we need to add here since this is software written in an interpreted
programming language with no natively compiled extensions is a ``BuildArch``
entry that is set to ``noarch`` in order to tell RPM that this package does not
need to be bound to the processor architecture that it is built using.

After your edits, the top portion of your spec file should look like the
following:

.. code-block:: spec

    Name:           pello
    Version:        0.1
    Release:        1%{?dist}
    Summary:        Hello World example implemented in Python

    License:        GPLv3+
    URL:            https://example.com/%{name}
    Source0:        https://example.com/%{name}/release/%{name}-%{version}.tar.gz

    BuildRequires:  python
    Requires:       python
    Requires:       bash

    BuildArch:      noarch

The following directives can be thought of as "section headings" because they
are directives that can define multi-line, multi-instruction, or scripted tasks
to occur. We will walk through them one by one just as we did with the previous
items.

The ``%description`` should be a longer, more full length description of the
software being packaged than what is found in the ``Summary`` directive. For the
sake of our example, this isn't really going to contain much content but this
section can be a full paragraph or more than one paragraph if desired.

The ``%prep`` section is where we *prepare* our build environment or workspace
for building. Most often what happens here is the expansion of compressed
archives of the source code, application of patches, and potentially parsing of
information provided in the source code that is necessary in a later portion of
the SPEC. In this section we will simply use the provided macro ``%setup -q``.

The ``%build`` section is where we tell the system how to actually build the
software we are packaging. Here we will perform a byte-compilation of our
software. For those who read the :ref:`General Topics and Background
<general-background>` Section, this portion of the example should look familiar.
The ``%build`` section of our SPEC file should look as follows.

.. code-block:: spec

    %build

    python -m compileall pello.py

The ``%install`` section is where we instruct ``rpmbuild`` how to install our
previously built software into the ``BUILDROOT`` which is effectively a
`chroot`_ base directory with nothing in it and we will have to construct any
paths or directory hierarchies that we will need in order to install our
software here in their specific locations. However, our RPM Macros help us
accomplish this task without having to hardcode paths.

We had previously discussed that since we will lose the context of a file with
the `shebang`_ line in it when we byte compile that we will need to create
a simple wrapper script in order to accomplish that task. There are many options
on how to accomplish this including, but not limited to, making a separate
script and using that as a separate ``SourceX`` directive and the option we're
going to show in this example which is to create the file in-line in the SPEC
file. The reason for showing the example option that we are is simply to
demonstrate that the SPEC file itself is scriptable. What we're going to do is
create a small "wrapper script" which will execute the `Python`_ byte-compiled
code by using a `here document`_. We will also need to actually install the
byte-compiled file into a library directory on the system such that it can be
accessed.

.. note::
    You will notice below that we are hard coding the library path. There are
    various methods to avoid needing to do this, many of which are addressed in
    the :ref:`Appendix <appendix>`, under the :ref:`More on Macros
    <more-macros>` section, and are specific to the programming language in
    which the software that is being packaged was written in. In this example we
    hard code the path for simplicity as to not cover too many topics
    simultaneously.

The ``%install`` section should look like the following after your edits:

.. code-block:: spec

    %install

    mkdir -p %{buildroot}/%{_bindir}
    mkdir -p %{buildroot}/usr/lib/%{name}

    cat > %{buildroot}/%{_bindir}/%{name} <<-EOF
    #!/bin/bash
    /usr/bin/python /usr/lib/%{name}/%{name}.pyc
    EOF

    chmod 0755 %{buildroot}/%{_bindir}/%{name}

    install -m 0644 %{name}.py* %{buildroot}/usr/lib/%{name}/

The ``%files`` section is where we provide the list of files that this RPM
provides and where it's intended for them to live on the system that the RPM is
installed upon. Note here that this isn't relative to the ``%{buildroot}`` but
the full path for the files as they are expected to exist on the end system
after installation. Therefore, the listing for the ``pello`` file we are
installing will be ``%{_bindir}/pello``. We will also need to provide a ``%dir``
listing to define that this package "owns" the library directory we created as
well as all the files we placed in it.

Also within this section, you will sometimes need a built-in macro to provide
context on a file. This can be useful for Systems Administrators and end users
who might want to query the system with ``rpm`` about the resulting package.
The built-in macro we will use here is ``%license`` which will tell ``rpmbuild``
that this is a software license file in the package file manifest metadata.

The ``%files`` section should look like the following after your edits:

.. code-block:: spec

    %files
    %license LICENSE
    %dir /usr/lib/%{name}/
    %{_bindir}/%{name}
    /usr/lib/%{name}/%{name}.py*


The last section, ``%changelog`` is a list of date-stamped entries that
correlate to a specific Version-Release of the package. This is not meant to be
a log of what changed in the software from release to release, but specifically
to packaging changes. For example, if software in a package needed patching or
there was a change needed in the build procedure listed in the ``%build``
section that information would go here. Each change entry can contain multiple
items and each item should start on a new line and begin with a ``-`` character.
Below is our example entry:

.. code-block:: spec

    %changelog
    * Tue May 31 2016 Adam Miller <maxamillion@fedoraproject.org> - 0.1-1
    - First bello package
    - Example second item in the changelog for version-release 0.1-1

Note the format above, the date-stamp will begin with a ``*`` character,
followed by the calendar day of the week, the month, the day of the month, the
year, then the contact information for the RPM Packager. From there we have
a ``-`` character before the Version-Release, which is an often used convention
but not a requirement. Then finally the Version-Release.

That's it! We've written an entire SPEC file for **pello**! In the next section
we will cover how to build the RPM!

The full SPEC file should now look like the following:

.. code-block:: spec

    Name:           pello
    Version:        0.1.1
    Release:        1%{?dist}
    Summary:        Hello World example implemented in bash script

    License:        GPLv3+
    URL:            https://www.example.com/%{name}
    Source0:        https://www.example.com/%{name}/releases/%{name}-%{version}.tar.gz

    BuildRequires:  python
    Requires:       python
    Requires:       bash

    BuildArch:      noarch

    %description
    The long-tail description for our Hello World Example implemented in
    Python

    %prep
    %setup -q

    %build

    python -m compileall %{name}.py

    %install

    mkdir -p %{buildroot}/%{_bindir}
    mkdir -p %{buildroot}/usr/lib/%{name}

    cat > %{buildroot}/%{_bindir}/%{name} <<-EOF
    #!/bin/bash
    /usr/bin/python /usr/lib/%{name}/%{name}.pyc
    EOF

    chmod 0755 %{buildroot}/%{_bindir}/%{name}

    install -m 0644 %{name}.py* %{buildroot}/usr/lib/%{name}/

    %files
    %license LICENSE
    %dir /usr/lib/%{name}/
    %{_bindir}/%{name}
    /usr/lib/%{name}/%{name}.py*


    %changelog
    * Tue May 31 2016 Adam Miller <maxamillion@fedoraproject.org> - 0.1.1-1
      - First pello package


cello
^^^^^

Our third SPEC file will be for our example written in the `C`_ programming
language that we created a simulated upstream release of previously (or you
downloaded) and placed it's source code into ``~/rpmbuild/SOURCES/`` earlier.

Let's go ahead and open the file ``~/rpmbuild/SOURCES/cello.spec`` and start
filling in some fields.

The following is the output template we were given from ``rpmdev-newspec``.

.. code-block:: spec

    Name:           cello
    Version:
    Release:        1%{?dist}
    Summary:

    License:
    URL:
    Source0:

    BuildRequires:
    Requires:

    %description


    %prep
    %setup -q


    %build
    %configure
    make %{?_smp_mflags}


    %install
    rm -rf $RPM_BUILD_ROOT
    %make_install


    %files
    %doc



    %changelog
    * Tue May 31 2016 Adam Miller <maxamillion@fedoraproject.org>
    -

Just as with the previous examples, let's begin with the first set of directives
that ``rpmdev-newspec`` has grouped together at the top of the file:
``Name``, ``Version``, ``Release``, ``Summary``. The ``Name`` is already
specified because we provided that information to the command line for
``rpmdev-newspec``.

Let's set the ``Version`` to match what the "upstream" release version of the
*cello* source code is, which we can observe is ``1.0`` as set by the example
code we downloaded (or we created in the :ref:`General Topics and Background
<general-background>` Section).

The ``Release`` is already set to ``1%{?dist}`` for us, the numerical value
which is initially ``1`` should be incremented every time the package is updated
for any reason, such as including a new patch to fix an issue, but doesn't have
a new upstream release ``Version``. When a new upstream release happens (for
example, cello version ``2.0`` were released) then the ``Release`` number should
be reset to ``1``. The *disttag* of ``%{?dist}`` should look familiar from the
previous section's coverage of :ref:`RPM Macros <rpm-macros>`.

The ``Summary`` should be a short, one-line explanation of what this software
is.

After your edits, the first section of the SPEC file should resemble the
following:

.. code-block:: spec

    Name:           cello
    Version:        1.0
    Release:        1%{?dist}
    Summary:        Hello World example implemented in C

Now, let's move on to the second set of directives that ``rpmdev-newspec`` has
grouped together in our SPEC file: ``License``, ``URL``, ``Source0``. However,
we will add one to this grouping as it is closely related to the ``Source0`` and
that is our ``Patch0`` which will list the first patch we need against our
software.

The ``License`` field is the `Software License`_ associated with the source code
from the upstream release. The exact format for how to label the License in your
SPEC file will vary depending on which specific RPM based `Linux`_ distribution
guidelines you are following, we will use the notation standards in the `Fedora
License Guidelines`_ for this document and as such this field will contain the
text ``GPLv3+``

The ``URL`` field is the upstream software's website, not the source code
download link but the actual project, product, or company website where someone
would find more information about this particular piece of software. Since we're
just using an example, we will call this ``https://example.com/cello``. However,
we will use the rpm macro variable of ``%{name}`` in it's place for consistency.

The ``Source0`` field is where the upstream software's source code should be
able to be downloaded from. This URL should link directly to the specific
version of the source code release that this RPM Package is packaging. Once
again, since this is an example we will use an example value:
``https://example.com/cello/releases/cello-1.0.tar.gz``

We should note that this example URL has hard coded values in it that are
possible to change in the future and are potentially even likely to change such
as the release version ``1.0``. We can simplify this by only needing to update
one field in the SPEC file and allowing it to be reused. we will use the value
``https://example.com/%{name}/releases/%{name}-%{version}.tar.gz`` instead of
the hard coded examples string previously listed.

The next item is to provide a listing for the ``.patch`` file we created earlier
such that we can apply it to the code later in the ``%setup`` section. We will
need a listing of ``Patch0:         cello-output-first-patch.patch``.

After your edits, the top portion of your spec file should look like the
following:

.. code-block:: spec

    Name:           cello
    Version:        1.0
    Release:        1%{?dist}
    Summary:        Hello World example implemented in C

    License:        GPLv3+
    URL:            https://example.com/%{name}
    Source0:        https://example.com/%{name}/release/%{name}-%{version}.tar.gz

    Patch0:         cello-output-first-patch.patch

Next up we have ``BuildRequires`` and ``Requires``, each of which define
something that is required by the package. However, ``BuildRequires`` is to tell
``rpmbuild`` what is needed by your package at **build** time and ``Requires``
is what is needed by your package at **run** time.

In this example we will need the ``gcc`` and ``make`` packages in order to
perform the compilation build process. Runtime requirements are fortunately
handled for us by rpmbuild because this program does not require anything
outside of the core `C`_ standard libraries and we therefore will not need to
define anything by hand as a ``Requires`` and can omit that directive.

After your edits, the top portion of your spec file should look like the
following:

.. code-block:: spec

    Name:           cello
    Version:        0.1
    Release:        1%{?dist}
    Summary:        Hello World example implemented in C

    License:        GPLv3+
    URL:            https://example.com/%{name}
    Source0:        https://example.com/%{name}/release/%{name}-%{version}.tar.gz

    BuildRequires:  gcc
    BuildRequires:  make

The following directives can be thought of as "section headings" because they
are directives that can define multi-line, multi-instruction, or scripted tasks
to occur. We will walk through them one by one just as we did with the previous
items.

The ``%description`` should be a longer, more full length description of the
software being packaged than what is found in the ``Summary`` directive. For the
sake of our example, this isn't really going to contain much content but this
section can be a full paragraph or more than one paragraph if desired.

The ``%prep`` section is where we *prepare* our build environment or workspace
for building. Most often what happens here is the expansion of compressed
archives of the source code, application of patches, and potentially parsing of
information provided in the source code that is necessary in a later portion of
the SPEC. In this section we will simply use the provided macro ``%setup -q``.

The ``%build`` section is where we tell the system how to actually build the
software we are packaging. Since wrote a simple ``Makefile`` for our `C`_
implementation, we can simply use the `GNU make`_ command provided by
``rpmdev-newspec``. However, we need to remove the call to ``%configure``
because we did not provide a `configure script`_. The ``%build`` section of our
SPEC file should look as follows.

.. code-block:: spec

    %build
    make %{?_smp_mflags}

The ``%install`` section is where we instruct ``rpmbuild`` how to install our
previously built software into the ``BUILDROOT`` which is effectively a
`chroot`_ base directory with nothing in it and we will have to construct any
paths or directory hierarchies that we will need in order to install our
software here in their specific locations. However, our RPM Macros help us
accomplish this task without having to hardcode paths.

Once again, since we have a simple ``Makefile`` the installation step can be
accomplished easily by leaving in place the ``%make_install`` macro that was
again provided for us by the ``rpmdev-newspec`` command.

The ``%install`` section should look like the following after your edits:

.. code-block:: spec

    %install
    %make_install

The ``%files`` section is where we provide the list of files that this RPM
provides and where it's intended for them to live on the system that the RPM is
installed upon. Note here that this isn't relative to the ``%{buildroot}`` but
the full path for the files as they are expected to exist on the end system
after installation. Therefore, the listing for the ``cello`` file we are
installing will be ``%{_bindir}/cello``.

Also within this section, you will sometimes need a built-in macro to provide
context on a file. This can be useful for Systems Administrators and end users
who might want to query the system with ``rpm`` about the resulting package.
The built-in macro we will use here is ``%license`` which will tell ``rpmbuild``
that this is a software license file in the package file manifest metadata.

The ``%files`` section should look like the following after your edits:

.. code-block:: spec

    %files
    %license LICENSE
    %{_bindir}/%{name}


The last section, ``%changelog`` is a list of date-stamped entries that
correlate to a specific Version-Release of the package. This is not meant to be
a log of what changed in the software from release to release, but specifically
to packaging changes. For example, if software in a package needed patching or
there was a change needed in the build procedure listed in the ``%build``
section that information would go here. Each change entry can contain multiple
items and each item should start on a new line and begin with a ``-`` character.
Below is our example entry:

.. code-block:: spec

    %changelog
    * Tue May 31 2016 Adam Miller <maxamillion@fedoraproject.org> - 0.1-1
    - First cello package

Note the format above, the date-stamp will begin with a ``*`` character,
followed by the calendar day of the week, the month, the day of the month, the
year, then the contact information for the RPM Packager. From there we have
a ``-`` character before the Version-Release, which is an often used convention
but not a requirement. Then finally the Version-Release.

That's it! We've written an entire SPEC file for **cello**! In the next section
we will cover how to build the RPM!

The full SPEC file should now look like the following:

.. code-block:: spec

    Name:           cello
    Version:        1.0
    Release:        1%{?dist}
    Summary:        Hello World example implemented in C

    License:        GPLv3+
    URL:            https://www.example.com/%{name}
    Source0:        https://www.example.com/%{name}/releases/%{name}-%{version}.tar.gz

    Patch0:         cello-output-first-patch.patch

    BuildRequires:  gcc
    BuildRequires:  make

    %description
    The long-tail description for our Hello World Example implemented in
    C

    %prep
    %setup -q

    %patch0

    %build
    make %{?_smp_mflags}

    %install
    %make_install


    %files
    %license LICENSE
    %{_bindir}/%{name}


    %changelog
    * Tue May 31 2016 Adam Miller <maxamillion@fedoraproject.org> - 1.0-1
    - First cello package

Building RPMS
=============

When building RPMs there are is one main command, which is ``rpmbuild`` and we
will use that through out the guide. It has been eluded to in various sections
in the guide but now we're actually going to dig in and get our hands dirty.

We will cover a couple different combinations of arguments we can pass to
``rpmbuild`` based on scenario and desired outcome but we will focus primarily
on the two main targets of building an RPM and that is creating Source and
Binary RPMs.

One of the things you may notice about ``rpmbuild`` is that it expects the
directory structure created in a certain way and for various items such as
source code to exist within the context of that directory structure. Luckily,
this is the same directory structure that was setup by the ``rpmdev-setuptree``
utility that we used previously to setup our RPM workspace and we have been
placing files in the correct place through out the duration of the guide.

Source RPMs
-----------

Before we actually build a Source RPM, let's quickly address why we would want
to do this. First, we might want to preserve the exact source of a
Name-Version-Release of RPM that we deployed to our environment that included
the exact SPEC file, the source code, and all relevant patches. This can be
useful when looking back in history and/or debugging if something has gone
wrong. Another reason is if we want to build a Binary RPM on a different
hardware platform or `architecture`_.

In order to create a Source RPM we need to pass the "build source" or ``-bs``
option to ``rpmbuild`` and we will provide a SPEC file as the argument. We
will do so for each of our examples we've created above.

::

    $ cd ~/rpmbuild/SPECS/

    $ rpmbuild -bs bello.spec
    Wrote: /home/admiller/rpmbuild/SRPMS/bello-0.1-1.el7.src.rpm

    $ rpmbuild -bs pello.spec
    Wrote: /home/admiller/rpmbuild/SRPMS/pello-0.1.1-1.el7.src.rpm

    $ rpmbuild -bs cello.spec
    Wrote: /home/admiller/rpmbuild/SRPMS/cello-1.0-1.el7.src.rpm

That's it! That's all there is to building a Source RPM or SRPM. Do note the
directory that it was placed in though, this is also a part of the directory
hierarchy that we covered previously.

Now it's time to move on to Binary RPMs!

Binary RPMS
-----------

When building Binary RPMs there are a few methods by which we could do this, we
could "rebuild" a SRPM by passing the ``--rebuild`` option to ``rpmbuild``. We
could tell ``rpmbuild`` to "build binary" or ``-bb`` and pass a SPEC file as the
argument similar to how we did for the Source RPMs.


Rebuild
^^^^^^^

Let's first rebuild each of our examples. Below you will see the example output
generated from rebuilding each example SRPM. You will notice the output will
vary differently based on the specific example you view and that the amount of
detail provided is quite verbose. This maybe seem daunting at first but as you
become a seasoned RPM Packager you will learn to appreciate and even welcome
this level of detail as it can prove to be very valuable when diagnosing issues.

One important distinction to make about when ``rpmbuild`` is invoked with the
``--rebuild`` argument is that it actually installs the contents of the SRPM
into your ``~/rpmbuild`` directory which will install the SPEC file and source
code, then the build is performed and the SPEC file and Source code are removed.
This might seem odd at first, but know that this is expected behavior and you
can perform a ``--recompile`` which will not do the "clean up" operation at the
end. We selected to use ``--rebuild`` in this guide to demonstrate how this
happens and how you can "recover" from it to get the SPEC files and SOURCES
back which is covered in the following section.


The commands required for each are as follows, with detailed output provided for
each below:

::

    $ rpmbuild --rebuild ~/rpmbuild/SRPMS/bello-0.1-1.el7.src.rpm

    $ rpmbuild --rebuild ~/rpmbuild/SRPMS/pello-0.1.1-1.el7.src.rpm

    $ rpmbuild --rebuild ~/rpmbuild/SRPMS/cello-1.0-1.el7.src.rpm

Now you've built RPMs!

You will now find the resulting Binary RPMs in ``~/rpmbuild/RPMS/`` depending on
your `architecture`_ and/or if the package was ``noarch``.

At the end of each of these commands you will find that there are no longer SPEC
files or contents in SOURCES for the specific SRPMs that you rebuilt because of
how ``--rebuild`` cleans up after itself. We can resolve this by executing the
following `rpm`_ commands which will perform an install of the SRPMs. You will
want to do this after running a ``--rebuild`` if you want to continue to
interact with the SPEC and SOURCES which we will want to do for the duration of
this guide.

::

    $ rpm -Uvh ~/rpmbuild/SRPMS/bello-0.1-1.el7.src.rpm
    Updating / installing...
       1:bello-0.1-1.el7                  ################################# [100%]

    $ rpm -Uvh ~/rpmbuild/SRPMS/pello-0.1.1-1.el7.src.rpm
    Updating / installing...
       1:pello-0.1.1-1.el7                ################################# [100%]

    $ rpm -Uvh ~/rpmbuild/SRPMS/cello-1.0-1.el7.src.rpm
    Updating / installing...
       1:cello-1.0-1.el7                  ################################# [100%]

bello
"""""

::

    $ rpmbuild --rebuild ~/rpmbuild/SRPMS/bello-0.1-1.el7.src.rpm
    Installing /home/admiller/rpmbuild/SRPMS/bello-0.1-1.el7.src.rpm
    Executing(%prep): /bin/sh -e /var/tmp/rpm-tmp.GHTHCO
    + umask 022
    + cd /home/admiller/rpmbuild/BUILD
    + cd /home/admiller/rpmbuild/BUILD
    + rm -rf bello-0.1
    + /usr/bin/gzip -dc /home/admiller/rpmbuild/SOURCES/bello-0.1.tar.gz
    + /usr/bin/tar -xf -
    + STATUS=0
    + '[' 0 -ne 0 ']'
    + cd bello-0.1
    + /usr/bin/chmod -Rf a+rX,u+w,g-w,o-w .
    + exit 0
    Executing(%build): /bin/sh -e /var/tmp/rpm-tmp.xmnIiZ
    + umask 022
    + cd /home/admiller/rpmbuild/BUILD
    + cd bello-0.1
    + exit 0
    Executing(%install): /bin/sh -e /var/tmp/rpm-tmp.WXBLZ9
    + umask 022
    + cd /home/admiller/rpmbuild/BUILD
    + '[' /home/admiller/rpmbuild/BUILDROOT/bello-0.1-1.el7.x86_64 '!=' / ']'
    + rm -rf /home/admiller/rpmbuild/BUILDROOT/bello-0.1-1.el7.x86_64
    ++ dirname /home/admiller/rpmbuild/BUILDROOT/bello-0.1-1.el7.x86_64
    + mkdir -p /home/admiller/rpmbuild/BUILDROOT
    + mkdir /home/admiller/rpmbuild/BUILDROOT/bello-0.1-1.el7.x86_64
    + cd bello-0.1
    + mkdir -p /home/admiller/rpmbuild/BUILDROOT/bello-0.1-1.el7.x86_64//usr/bin
    + install -m 0755 bello /home/admiller/rpmbuild/BUILDROOT/bello-0.1-1.el7.x86_64//usr/bin/bello
    + /usr/lib/rpm/find-debuginfo.sh --strict-build-id -m --run-dwz --dwz-low-mem-die-limit 10000000 --dwz-max-die-limit 110000000 /home/admiller/rpmbuild/BUILD/bello-0.1
    /usr/lib/rpm/sepdebugcrcfix: Updated 0 CRC32s, 0 CRC32s did match.
    + '[' noarch = noarch ']'
    + case "${QA_CHECK_RPATHS:-}" in
    + /usr/lib/rpm/check-buildroot
    + /usr/lib/rpm/redhat/brp-compress
    + /usr/lib/rpm/redhat/brp-strip-static-archive /usr/bin/strip
    + /usr/lib/rpm/brp-python-bytecompile /usr/bin/python 1
    + /usr/lib/rpm/redhat/brp-python-hardlink
    + /usr/lib/rpm/redhat/brp-java-repack-jars
    Processing files: bello-0.1-1.el7.noarch
    Executing(%license): /bin/sh -e /var/tmp/rpm-tmp.7wU0nl
    + umask 022
    + cd /home/admiller/rpmbuild/BUILD
    + cd bello-0.1
    + LICENSEDIR=/home/admiller/rpmbuild/BUILDROOT/bello-0.1-1.el7.x86_64/usr/share/licenses/bello-0.1
    + export LICENSEDIR
    + /usr/bin/mkdir -p /home/admiller/rpmbuild/BUILDROOT/bello-0.1-1.el7.x86_64/usr/share/licenses/bello-0.1
    + cp -pr LICENSE /home/admiller/rpmbuild/BUILDROOT/bello-0.1-1.el7.x86_64/usr/share/licenses/bello-0.1
    + exit 0
    Provides: bello = 0.1-1.el7
    Requires(rpmlib): rpmlib(CompressedFileNames) <= 3.0.4-1 rpmlib(FileDigests) <= 4.6.0-1 rpmlib(PayloadFilesHavePrefix) <= 4.0-1
    Requires: /bin/bash
    Checking for unpackaged file(s): /usr/lib/rpm/check-files /home/admiller/rpmbuild/BUILDROOT/bello-0.1-1.el7.x86_64
    Wrote: /home/admiller/rpmbuild/RPMS/noarch/bello-0.1-1.el7.noarch.rpm
    Executing(%clean): /bin/sh -e /var/tmp/rpm-tmp.R9eRPW
    + umask 022
    + cd /home/admiller/rpmbuild/BUILD
    + cd bello-0.1
    + /usr/bin/rm -rf /home/admiller/rpmbuild/BUILDROOT/bello-0.1-1.el7.x86_64
    + exit 0
    Executing(--clean): /bin/sh -e /var/tmp/rpm-tmp.S59sAf
    + umask 022
    + cd /home/admiller/rpmbuild/BUILD
    + rm -rf bello-0.1
    + exit 0

pello
"""""

::

    $ rpmbuild --rebuild ~/rpmbuild/SRPMS/pello-0.1.1-1.el7.src.rpm
    Installing /home/admiller/rpmbuild/SRPMS/pello-0.1.1-1.el7.src.rpm
    Executing(%prep): /bin/sh -e /var/tmp/rpm-tmp.kRf2qV
    + umask 022
    + cd /home/admiller/rpmbuild/BUILD
    + cd /home/admiller/rpmbuild/BUILD
    + rm -rf pello-0.1.1
    + /usr/bin/gzip -dc /home/admiller/rpmbuild/SOURCES/pello-0.1.1.tar.gz
    + /usr/bin/tar -xf -
    + STATUS=0
    + '[' 0 -ne 0 ']'
    + cd pello-0.1.1
    + /usr/bin/chmod -Rf a+rX,u+w,g-w,o-w .
    + exit 0
    Executing(%build): /bin/sh -e /var/tmp/rpm-tmp.h0DkgE
    + umask 022
    + cd /home/admiller/rpmbuild/BUILD
    + cd pello-0.1.1
    + python -m compileall pello.py
    Compiling pello.py ...
    + exit 0
    Executing(%install): /bin/sh -e /var/tmp/rpm-tmp.k0YN9m
    + umask 022
    + cd /home/admiller/rpmbuild/BUILD
    + '[' /home/admiller/rpmbuild/BUILDROOT/pello-0.1.1-1.el7.x86_64 '!=' / ']'
    + rm -rf /home/admiller/rpmbuild/BUILDROOT/pello-0.1.1-1.el7.x86_64
    ++ dirname /home/admiller/rpmbuild/BUILDROOT/pello-0.1.1-1.el7.x86_64
    + mkdir -p /home/admiller/rpmbuild/BUILDROOT
    + mkdir /home/admiller/rpmbuild/BUILDROOT/pello-0.1.1-1.el7.x86_64
    + cd pello-0.1.1
    + mkdir -p /home/admiller/rpmbuild/BUILDROOT/pello-0.1.1-1.el7.x86_64//usr/bin
    + mkdir -p /home/admiller/rpmbuild/BUILDROOT/pello-0.1.1-1.el7.x86_64/usr/lib/pello
    + cat
    + chmod 0755 /home/admiller/rpmbuild/BUILDROOT/pello-0.1.1-1.el7.x86_64//usr/bin/pello
    + install -m 0644 pello.py pello.pyc /home/admiller/rpmbuild/BUILDROOT/pello-0.1.1-1.el7.x86_64/usr/lib/pello/
    + /usr/lib/rpm/find-debuginfo.sh --strict-build-id -m --run-dwz --dwz-low-mem-die-limit 10000000 --dwz-max-die-limit 110000000 /home/admiller/rpmbuild/BUILD/pello-0.1.1
    /usr/lib/rpm/sepdebugcrcfix: Updated 0 CRC32s, 0 CRC32s did match.
    find: 'debug': No such file or directory
    + '[' noarch = noarch ']'
    + case "${QA_CHECK_RPATHS:-}" in
    + /usr/lib/rpm/check-buildroot
    + /usr/lib/rpm/redhat/brp-compress
    + /usr/lib/rpm/redhat/brp-strip-static-archive /usr/bin/strip
    + /usr/lib/rpm/brp-python-bytecompile /usr/bin/python 1
    + /usr/lib/rpm/redhat/brp-python-hardlink
    + /usr/lib/rpm/redhat/brp-java-repack-jars
    Processing files: pello-0.1.1-1.el7.noarch
    Executing(%license): /bin/sh -e /var/tmp/rpm-tmp.22ODva
    + umask 022
    + cd /home/admiller/rpmbuild/BUILD
    + cd pello-0.1.1
    + LICENSEDIR=/home/admiller/rpmbuild/BUILDROOT/pello-0.1.1-1.el7.x86_64/usr/share/licenses/pello-0.1.1
    + export LICENSEDIR
    + /usr/bin/mkdir -p /home/admiller/rpmbuild/BUILDROOT/pello-0.1.1-1.el7.x86_64/usr/share/licenses/pello-0.1.1
    + cp -pr LICENSE /home/admiller/rpmbuild/BUILDROOT/pello-0.1.1-1.el7.x86_64/usr/share/licenses/pello-0.1.1
    + exit 0
    Provides: pello = 0.1.1-1.el7
    Requires(rpmlib): rpmlib(CompressedFileNames) <= 3.0.4-1 rpmlib(FileDigests) <= 4.6.0-1 rpmlib(PartialHardlinkSets) <= 4.0.4-1 rpmlib(PayloadFilesHavePrefix) <= 4.0-1
    Requires: /bin/bash
    Checking for unpackaged file(s): /usr/lib/rpm/check-files /home/admiller/rpmbuild/BUILDROOT/pello-0.1.1-1.el7.x86_64
    Wrote: /home/admiller/rpmbuild/RPMS/noarch/pello-0.1.1-1.el7.noarch.rpm
    Executing(%clean): /bin/sh -e /var/tmp/rpm-tmp.kZTRbM
    + umask 022
    + cd /home/admiller/rpmbuild/BUILD
    + cd pello-0.1.1
    + /usr/bin/rm -rf /home/admiller/rpmbuild/BUILDROOT/pello-0.1.1-1.el7.x86_64
    + exit 0
    Executing(--clean): /bin/sh -e /var/tmp/rpm-tmp.WChx3z
    + umask 022
    + cd /home/admiller/rpmbuild/BUILD
    + rm -rf pello-0.1.1
    + exit 0


cello
"""""

::

    $ rpmbuild --rebuild ~/rpmbuild/SRPMS/cello-1.0-1.el7.src.rpm
    Installing /home/admiller/rpmbuild/SRPMS/cello-1.0-1.el7.src.rpm
    Executing(%prep): /bin/sh -e /var/tmp/rpm-tmp.ySAWzh
    + umask 022
    + cd /home/admiller/rpmbuild/BUILD
    + cd /home/admiller/rpmbuild/BUILD
    + rm -rf cello-1.0
    + /usr/bin/gzip -dc /home/admiller/rpmbuild/SOURCES/cello-1.0.tar.gz
    + /usr/bin/tar -xf -
    + STATUS=0
    + '[' 0 -ne 0 ']'
    + cd cello-1.0
    + /usr/bin/chmod -Rf a+rX,u+w,g-w,o-w .
    + echo 'Patch #0 (cello-output-first-patch.patch):'
    Patch #0 (cello-output-first-patch.patch):
    + /usr/bin/cat /home/admiller/rpmbuild/SOURCES/cello-output-first-patch.patch
    + /usr/bin/patch -p0 --fuzz=0
    patching file cello.c
    + exit 0
    Executing(%build): /bin/sh -e /var/tmp/rpm-tmp.LZZAxn
    + umask 022
    + cd /home/admiller/rpmbuild/BUILD
    + cd cello-1.0
    + make -j3
    gcc -o cello cello.c
    + exit 0
    Executing(%install): /bin/sh -e /var/tmp/rpm-tmp.SSAzEt
    + umask 022
    + cd /home/admiller/rpmbuild/BUILD
    + '[' /home/admiller/rpmbuild/BUILDROOT/cello-1.0-1.el7.x86_64 '!=' / ']'
    + rm -rf /home/admiller/rpmbuild/BUILDROOT/cello-1.0-1.el7.x86_64
    ++ dirname /home/admiller/rpmbuild/BUILDROOT/cello-1.0-1.el7.x86_64
    + mkdir -p /home/admiller/rpmbuild/BUILDROOT
    + mkdir /home/admiller/rpmbuild/BUILDROOT/cello-1.0-1.el7.x86_64
    + cd cello-1.0
    + /usr/bin/make install DESTDIR=/home/admiller/rpmbuild/BUILDROOT/cello-1.0-1.el7.x86_64
    mkdir -p /home/admiller/rpmbuild/BUILDROOT/cello-1.0-1.el7.x86_64/usr/bin
    install -m 0755 cello /home/admiller/rpmbuild/BUILDROOT/cello-1.0-1.el7.x86_64/usr/bin/cello
    + /usr/lib/rpm/find-debuginfo.sh --strict-build-id -m --run-dwz --dwz-low-mem-die-limit 10000000 --dwz-max-die-limit 110000000 /home/admiller/rpmbuild/BUILD/cello-1.0
    extracting debug info from /home/admiller/rpmbuild/BUILDROOT/cello-1.0-1.el7.x86_64/usr/bin/cello
    dwz: Too few files for multifile optimization
    /usr/lib/rpm/sepdebugcrcfix: Updated 0 CRC32s, 1 CRC32s did match.
    + '[' '%{buildarch}' = noarch ']'
    + QA_CHECK_RPATHS=1
    + case "${QA_CHECK_RPATHS:-}" in
    + /usr/lib/rpm/check-rpaths
    + /usr/lib/rpm/check-buildroot
    + /usr/lib/rpm/redhat/brp-compress
    + /usr/lib/rpm/redhat/brp-strip-static-archive /usr/bin/strip
    + /usr/lib/rpm/brp-python-bytecompile /usr/bin/python 1
    + /usr/lib/rpm/redhat/brp-python-hardlink
    + /usr/lib/rpm/redhat/brp-java-repack-jars
    Processing files: cello-1.0-1.el7.x86_64
    Executing(%license): /bin/sh -e /var/tmp/rpm-tmp.L0PliA
    + umask 022
    + cd /home/admiller/rpmbuild/BUILD
    + cd cello-1.0
    + LICENSEDIR=/home/admiller/rpmbuild/BUILDROOT/cello-1.0-1.el7.x86_64/usr/share/licenses/cello-1.0
    + export LICENSEDIR
    + /usr/bin/mkdir -p /home/admiller/rpmbuild/BUILDROOT/cello-1.0-1.el7.x86_64/usr/share/licenses/cello-1.0
    + cp -pr LICENSE /home/admiller/rpmbuild/BUILDROOT/cello-1.0-1.el7.x86_64/usr/share/licenses/cello-1.0
    + exit 0
    Provides: cello = 1.0-1.el7 cello(x86-64) = 1.0-1.el7
    Requires(rpmlib): rpmlib(CompressedFileNames) <= 3.0.4-1 rpmlib(FileDigests) <= 4.6.0-1 rpmlib(PayloadFilesHavePrefix) <= 4.0-1
    Requires: libc.so.6()(64bit) libc.so.6(GLIBC_2.2.5)(64bit) rtld(GNU_HASH)
    Processing files: cello-debuginfo-1.0-1.el7.x86_64
    Provides: cello-debuginfo = 1.0-1.el7 cello-debuginfo(x86-64) = 1.0-1.el7
    Requires(rpmlib): rpmlib(FileDigests) <= 4.6.0-1 rpmlib(PayloadFilesHavePrefix) <= 4.0-1 rpmlib(CompressedFileNames) <= 3.0.4-1
    Checking for unpackaged file(s): /usr/lib/rpm/check-files /home/admiller/rpmbuild/BUILDROOT/cello-1.0-1.el7.x86_64
    Wrote: /home/admiller/rpmbuild/RPMS/x86_64/cello-1.0-1.el7.x86_64.rpm
    Wrote: /home/admiller/rpmbuild/RPMS/x86_64/cello-debuginfo-1.0-1.el7.x86_64.rpm
    Executing(%clean): /bin/sh -e /var/tmp/rpm-tmp.oexkNU
    + umask 022
    + cd /home/admiller/rpmbuild/BUILD
    + cd cello-1.0
    + /usr/bin/rm -rf /home/admiller/rpmbuild/BUILDROOT/cello-1.0-1.el7.x86_64
    + exit 0
    Executing(--clean): /bin/sh -e /var/tmp/rpm-tmp.ENKUE1
    + umask 022
    + cd /home/admiller/rpmbuild/BUILD
    + rm -rf cello-1.0
    + exit 0


Build Binary
^^^^^^^^^^^^

Next up, let's "build binary" for each of our examples. Just as in the previous
example, you will again see the example output generated from building each
example. Similarly you will notice the output will vary differently based on the
specific example you view and that the amount of detail provided is quite
verbose.

The commands required for each are as follows, with detailed output provided for
each below:

::

    $ rpmbuild -bb ~/rpmbuild/SPECS/bello.spec

    $ rpmbuild -bb ~/rpmbuild/SPECS/pello.spec

    $ rpmbuild -bb ~/rpmbuild/SPECS/cello.spec

Now you've built RPMs!

You will now find the resulting Binary RPMs in ``~/rpmbuild/RPMS/`` depending on
your `architecture`_ and/or if the package was ``noarch``.

bello
"""""

::

    $ rpmbuild -bb ~/rpmbuild/SPECS/bello.spec
    Executing(%prep): /bin/sh -e /var/tmp/rpm-tmp.aaCBH0
    + umask 022
    + cd /home/admiller/rpmbuild/BUILD
    + cd /home/admiller/rpmbuild/BUILD
    + rm -rf bello-0.1
    + /usr/bin/gzip -dc /home/admiller/rpmbuild/SOURCES/bello-0.1.tar.gz
    + /usr/bin/tar -xf -
    + STATUS=0
    + '[' 0 -ne 0 ']'
    + cd bello-0.1
    + /usr/bin/chmod -Rf a+rX,u+w,g-w,o-w .
    + exit 0
    Executing(%build): /bin/sh -e /var/tmp/rpm-tmp.mOSeGQ
    + umask 022
    + cd /home/admiller/rpmbuild/BUILD
    + cd bello-0.1
    + exit 0
    Executing(%install): /bin/sh -e /var/tmp/rpm-tmp.LW9TFG
    + umask 022
    + cd /home/admiller/rpmbuild/BUILD
    + '[' /home/admiller/rpmbuild/BUILDROOT/bello-0.1-1.el7.x86_64 '!=' / ']'
    + rm -rf /home/admiller/rpmbuild/BUILDROOT/bello-0.1-1.el7.x86_64
    ++ dirname /home/admiller/rpmbuild/BUILDROOT/bello-0.1-1.el7.x86_64
    + mkdir -p /home/admiller/rpmbuild/BUILDROOT
    + mkdir /home/admiller/rpmbuild/BUILDROOT/bello-0.1-1.el7.x86_64
    + cd bello-0.1
    + mkdir -p /home/admiller/rpmbuild/BUILDROOT/bello-0.1-1.el7.x86_64//usr/bin
    + install -m 0755 bello /home/admiller/rpmbuild/BUILDROOT/bello-0.1-1.el7.x86_64//usr/bin/bello
    + /usr/lib/rpm/find-debuginfo.sh --strict-build-id -m --run-dwz --dwz-low-mem-die-limit 10000000 --dwz-max-die-limit 110000000 /home/admiller/rpmbuild/BUILD/bello-0.1
    /usr/lib/rpm/sepdebugcrcfix: Updated 0 CRC32s, 0 CRC32s did match.
    + '[' noarch = noarch ']'
    + case "${QA_CHECK_RPATHS:-}" in
    + /usr/lib/rpm/check-buildroot
    + /usr/lib/rpm/redhat/brp-compress
    + /usr/lib/rpm/redhat/brp-strip-static-archive /usr/bin/strip
    + /usr/lib/rpm/brp-python-bytecompile /usr/bin/python 1
    + /usr/lib/rpm/redhat/brp-python-hardlink
    + /usr/lib/rpm/redhat/brp-java-repack-jars
    Processing files: bello-0.1-1.el7.noarch
    Executing(%license): /bin/sh -e /var/tmp/rpm-tmp.wAswQw
    + umask 022
    + cd /home/admiller/rpmbuild/BUILD
    + cd bello-0.1
    + LICENSEDIR=/home/admiller/rpmbuild/BUILDROOT/bello-0.1-1.el7.x86_64/usr/share/licenses/bello-0.1
    + export LICENSEDIR
    + /usr/bin/mkdir -p /home/admiller/rpmbuild/BUILDROOT/bello-0.1-1.el7.x86_64/usr/share/licenses/bello-0.1
    + cp -pr LICENSE /home/admiller/rpmbuild/BUILDROOT/bello-0.1-1.el7.x86_64/usr/share/licenses/bello-0.1
    + exit 0
    Provides: bello = 0.1-1.el7
    Requires(rpmlib): rpmlib(CompressedFileNames) <= 3.0.4-1 rpmlib(FileDigests) <= 4.6.0-1 rpmlib(PayloadFilesHavePrefix) <= 4.0-1
    Requires: /bin/bash
    Checking for unpackaged file(s): /usr/lib/rpm/check-files /home/admiller/rpmbuild/BUILDROOT/bello-0.1-1.el7.x86_64
    Wrote: /home/admiller/rpmbuild/RPMS/noarch/bello-0.1-1.el7.noarch.rpm
    Executing(%clean): /bin/sh -e /var/tmp/rpm-tmp.74OMCd
    + umask 022
    + cd /home/admiller/rpmbuild/BUILD
    + cd bello-0.1
    + /usr/bin/rm -rf /home/admiller/rpmbuild/BUILDROOT/bello-0.1-1.el7.x86_64
    + exit 0


pello
"""""

::

    $ rpmbuild -bb pello.spec
    Executing(%prep): /bin/sh -e /var/tmp/rpm-tmp.dvOeYv
    + umask 022
    + cd /home/admiller/rpmbuild/BUILD
    + cd /home/admiller/rpmbuild/BUILD
    + rm -rf pello-0.1.1
    + /usr/bin/gzip -dc /home/admiller/rpmbuild/SOURCES/pello-0.1.1.tar.gz
    + /usr/bin/tar -xf -
    + STATUS=0
    + '[' 0 -ne 0 ']'
    + cd pello-0.1.1
    + /usr/bin/chmod -Rf a+rX,u+w,g-w,o-w .
    + exit 0
    Executing(%build): /bin/sh -e /var/tmp/rpm-tmp.QD4XFU
    + umask 022
    + cd /home/admiller/rpmbuild/BUILD
    + cd pello-0.1.1
    + python -m compileall pello.py
    Compiling pello.py ...
    + exit 0
    Executing(%install): /bin/sh -e /var/tmp/rpm-tmp.qEbZqj
    + umask 022
    + cd /home/admiller/rpmbuild/BUILD
    + '[' /home/admiller/rpmbuild/BUILDROOT/pello-0.1.1-1.el7.x86_64 '!=' / ']'
    + rm -rf /home/admiller/rpmbuild/BUILDROOT/pello-0.1.1-1.el7.x86_64
    ++ dirname /home/admiller/rpmbuild/BUILDROOT/pello-0.1.1-1.el7.x86_64
    + mkdir -p /home/admiller/rpmbuild/BUILDROOT
    + mkdir /home/admiller/rpmbuild/BUILDROOT/pello-0.1.1-1.el7.x86_64
    + cd pello-0.1.1
    + mkdir -p /home/admiller/rpmbuild/BUILDROOT/pello-0.1.1-1.el7.x86_64//usr/bin
    + mkdir -p /home/admiller/rpmbuild/BUILDROOT/pello-0.1.1-1.el7.x86_64/usr/lib/pello
    + cat
    + chmod 0755 /home/admiller/rpmbuild/BUILDROOT/pello-0.1.1-1.el7.x86_64//usr/bin/pello
    + install -m 0644 pello.py pello.pyc /home/admiller/rpmbuild/BUILDROOT/pello-0.1.1-1.el7.x86_64/usr/lib/pello/
    + /usr/lib/rpm/find-debuginfo.sh --strict-build-id -m --run-dwz --dwz-low-mem-die-limit 10000000 --dwz-max-die-limit 110000000 /home/admiller/rpmbuild/BUILD/pello-0.1.1
    /usr/lib/rpm/sepdebugcrcfix: Updated 0 CRC32s, 0 CRC32s did match.
    find: 'debug': No such file or directory
    + '[' noarch = noarch ']'
    + case "${QA_CHECK_RPATHS:-}" in
    + /usr/lib/rpm/check-buildroot
    + /usr/lib/rpm/redhat/brp-compress
    + /usr/lib/rpm/redhat/brp-strip-static-archive /usr/bin/strip
    + /usr/lib/rpm/brp-python-bytecompile /usr/bin/python 1
    + /usr/lib/rpm/redhat/brp-python-hardlink
    + /usr/lib/rpm/redhat/brp-java-repack-jars
    Processing files: pello-0.1.1-1.el7.noarch
    Executing(%license): /bin/sh -e /var/tmp/rpm-tmp.Vc2ApI
    + umask 022
    + cd /home/admiller/rpmbuild/BUILD
    + cd pello-0.1.1
    + LICENSEDIR=/home/admiller/rpmbuild/BUILDROOT/pello-0.1.1-1.el7.x86_64/usr/share/licenses/pello-0.1.1
    + export LICENSEDIR
    + /usr/bin/mkdir -p /home/admiller/rpmbuild/BUILDROOT/pello-0.1.1-1.el7.x86_64/usr/share/licenses/pello-0.1.1
    + cp -pr LICENSE /home/admiller/rpmbuild/BUILDROOT/pello-0.1.1-1.el7.x86_64/usr/share/licenses/pello-0.1.1
    + exit 0
    Provides: pello = 0.1.1-1.el7
    Requires(rpmlib): rpmlib(CompressedFileNames) <= 3.0.4-1 rpmlib(FileDigests) <= 4.6.0-1 rpmlib(PartialHardlinkSets) <= 4.0.4-1 rpmlib(PayloadFilesHavePrefix) <= 4.0-1
    Requires: /bin/bash
    Checking for unpackaged file(s): /usr/lib/rpm/check-files /home/admiller/rpmbuild/BUILDROOT/pello-0.1.1-1.el7.x86_64
    Wrote: /home/admiller/rpmbuild/RPMS/noarch/pello-0.1.1-1.el7.noarch.rpm
    Executing(%clean): /bin/sh -e /var/tmp/rpm-tmp.4tTJSw
    + umask 022
    + cd /home/admiller/rpmbuild/BUILD
    + cd pello-0.1.1
    + /usr/bin/rm -rf /home/admiller/rpmbuild/BUILDROOT/pello-0.1.1-1.el7.x86_64
    + exit 0

cello
"""""

::

    $ rpmbuild -bb ~/rpmbuild/SPECS/cello.spec
    Executing(%prep): /bin/sh -e /var/tmp/rpm-tmp.FveYdS
    + umask 022
    + cd /home/admiller/rpmbuild/BUILD
    + cd /home/admiller/rpmbuild/BUILD
    + rm -rf cello-1.0
    + /usr/bin/gzip -dc /home/admiller/rpmbuild/SOURCES/cello-1.0.tar.gz
    + /usr/bin/tar -xf -
    + STATUS=0
    + '[' 0 -ne 0 ']'
    + cd cello-1.0
    + /usr/bin/chmod -Rf a+rX,u+w,g-w,o-w .
    + echo 'Patch #0 (cello-output-first-patch.patch):'
    Patch #0 (cello-output-first-patch.patch):
    + /usr/bin/cat /home/admiller/rpmbuild/SOURCES/cello-output-first-patch.patch
    + /usr/bin/patch -p0 --fuzz=0
    patching file cello.c
    + exit 0
    Executing(%build): /bin/sh -e /var/tmp/rpm-tmp.ros7nt
    + umask 022
    + cd /home/admiller/rpmbuild/BUILD
    + cd cello-1.0
    + make -j3
    gcc -o cello cello.c
    + exit 0
    Executing(%install): /bin/sh -e /var/tmp/rpm-tmp.qSW6D4
    + umask 022
    + cd /home/admiller/rpmbuild/BUILD
    + '[' /home/admiller/rpmbuild/BUILDROOT/cello-1.0-1.el7.x86_64 '!=' / ']'
    + rm -rf /home/admiller/rpmbuild/BUILDROOT/cello-1.0-1.el7.x86_64
    ++ dirname /home/admiller/rpmbuild/BUILDROOT/cello-1.0-1.el7.x86_64
    + mkdir -p /home/admiller/rpmbuild/BUILDROOT
    + mkdir /home/admiller/rpmbuild/BUILDROOT/cello-1.0-1.el7.x86_64
    + cd cello-1.0
    + /usr/bin/make install DESTDIR=/home/admiller/rpmbuild/BUILDROOT/cello-1.0-1.el7.x86_64
    mkdir -p /home/admiller/rpmbuild/BUILDROOT/cello-1.0-1.el7.x86_64/usr/bin
    install -m 0755 cello /home/admiller/rpmbuild/BUILDROOT/cello-1.0-1.el7.x86_64/usr/bin/cello
    + /usr/lib/rpm/find-debuginfo.sh --strict-build-id -m --run-dwz --dwz-low-mem-die-limit 10000000 --dwz-max-die-limit 110000000 /home/admiller/rpmbuild/BUILD/cello-1.0
    extracting debug info from /home/admiller/rpmbuild/BUILDROOT/cello-1.0-1.el7.x86_64/usr/bin/cello
    dwz: Too few files for multifile optimization
    /usr/lib/rpm/sepdebugcrcfix: Updated 0 CRC32s, 1 CRC32s did match.
    + '[' '%{buildarch}' = noarch ']'
    + QA_CHECK_RPATHS=1
    + case "${QA_CHECK_RPATHS:-}" in
    + /usr/lib/rpm/check-rpaths
    + /usr/lib/rpm/check-buildroot
    + /usr/lib/rpm/redhat/brp-compress
    + /usr/lib/rpm/redhat/brp-strip-static-archive /usr/bin/strip
    + /usr/lib/rpm/brp-python-bytecompile /usr/bin/python 1
    + /usr/lib/rpm/redhat/brp-python-hardlink
    + /usr/lib/rpm/redhat/brp-java-repack-jars
    Processing files: cello-1.0-1.el7.x86_64
    Executing(%license): /bin/sh -e /var/tmp/rpm-tmp.IqHIpG
    + umask 022
    + cd /home/admiller/rpmbuild/BUILD
    + cd cello-1.0
    + LICENSEDIR=/home/admiller/rpmbuild/BUILDROOT/cello-1.0-1.el7.x86_64/usr/share/licenses/cello-1.0
    + export LICENSEDIR
    + /usr/bin/mkdir -p /home/admiller/rpmbuild/BUILDROOT/cello-1.0-1.el7.x86_64/usr/share/licenses/cello-1.0
    + cp -pr LICENSE /home/admiller/rpmbuild/BUILDROOT/cello-1.0-1.el7.x86_64/usr/share/licenses/cello-1.0
    + exit 0
    Provides: cello = 1.0-1.el7 cello(x86-64) = 1.0-1.el7
    Requires(rpmlib): rpmlib(CompressedFileNames) <= 3.0.4-1 rpmlib(FileDigests) <= 4.6.0-1 rpmlib(PayloadFilesHavePrefix) <= 4.0-1
    Requires: libc.so.6()(64bit) libc.so.6(GLIBC_2.2.5)(64bit) rtld(GNU_HASH)
    Processing files: cello-debuginfo-1.0-1.el7.x86_64
    Provides: cello-debuginfo = 1.0-1.el7 cello-debuginfo(x86-64) = 1.0-1.el7
    Requires(rpmlib): rpmlib(FileDigests) <= 4.6.0-1 rpmlib(PayloadFilesHavePrefix) <= 4.0-1 rpmlib(CompressedFileNames) <= 3.0.4-1
    Checking for unpackaged file(s): /usr/lib/rpm/check-files /home/admiller/rpmbuild/BUILDROOT/cello-1.0-1.el7.x86_64
    Wrote: /home/admiller/rpmbuild/RPMS/x86_64/cello-1.0-1.el7.x86_64.rpm
    Wrote: /home/admiller/rpmbuild/RPMS/x86_64/cello-debuginfo-1.0-1.el7.x86_64.rpm
    Executing(%clean): /bin/sh -e /var/tmp/rpm-tmp.ZRORXv
    + umask 022
    + cd /home/admiller/rpmbuild/BUILD
    + cd cello-1.0
    + /usr/bin/rm -rf /home/admiller/rpmbuild/BUILDROOT/cello-1.0-1.el7.x86_64
    + exit 0

Checking RPMs For Sanity
========================

Once we have created a package, we may desire to perform some sort of checks for
quality on the package itself and not necessarily just the software we're
delivering with the RPM.

For this the main tool of choice for RPM Packagers is `rpmlint`_ which performs
many sanity and error checks that help assist with packaging in more
maintainable and less error prone fashion. Something to keep in mind is that
this is going to report things based on very strict guidelines and by way of
static analysis. There is going to be lack of perspective by the `rpmlint`_ tool
and what your primary objective is and thus it is sometimes alright to allow
Errors or Warnings reported by `rpmlint`_ to persist in your packages, but the
key is to understand **why** we would allow these to persist. In the follow
sections we will explore a couple examples of just that.

Another really useful feature of `rpmlint`_ is that we can use it to check
against Binary RPMs, Source RPMs, and SPEC files so that it can be used during
all stages of packaging and not just after the fact. We will show examples of
each below.

.. note::
    For each example below we run `rpmlint`_ without any options, if you would
    like detailed explanations of what each Error or Warning means, then you can
    pass the ``-i`` option and run each command as ``rpmlint -i`` instead of
    just ``rpmlint``. The shorter output is selected for brevity of the
    document.

bello
-----

Let's get started by looking at some output and dive into each set of output.

::

    $ rpmlint bello.spec
    bello.spec: W: invalid-url Source0: https://www.example.com/bello/releases/bello-0.1.tar.gz HTTP Error 404: Not Found
    0 packages and 1 specfiles checked; 0 errors, 1 warnings.


When checking *bello*'s spec file we can see that we only have one warning and
that is the URL listed in the ``Source0`` directive can not be reached which is
something that we would expect given that example.com doesn't actually exist out
in the real world and we've not setup a system with a local DNS entry to point
to this URL. Since we know why the Warning was emitted and that it was expect,
this can be safely ignored.

::

    $ rpmlint ~/rpmbuild/SRPMS/bello-0.1-1.el7.src.rpm
    bello.src: W: invalid-url URL: https://www.example.com/bello HTTP Error 404: Not Found
    bello.src: W: invalid-url Source0: https://www.example.com/bello/releases/bello-0.1.tar.gz HTTP Error 404: Not Found
    1 packages and 0 specfiles checked; 0 errors, 2 warnings.

When checking *bello*'s SRPM we can see very similar output from the check
against the spec file but we also see that the check against the SRPM looks for
the ``URL`` directive as well as the ``Source0`` directive, neither can be
reached but as we know is expected and these can also be safely ignored.

::

    $ rpmlint ~/rpmbuild/RPMS/noarch/bello-0.1-1.el7.noarch.rpm
    bello.noarch: W: invalid-url URL: https://www.example.com/bello HTTP Error 404: Not Found
    bello.noarch: W: no-documentation
    bello.noarch: W: no-manual-page-for-binary bello
    1 packages and 0 specfiles checked; 0 errors, 3 warnings.

Now things will change a bit when looking at Binary RPMs as the `rpmlint`_
utility is going to check for other things that should be commonly found in
Binary RPMs such as documentation and/or `man pages`_ as well as things like
consistent use of the `Filesystem Hierarchy Standard`_. As we can see, this is
exactly what is being reported and we know that there are no `man pages`_ or
other documentation because we didn't provide any. Also, once again our old
friend the ``HTTP Error 404: Not Found`` is present but we're well aware as to
why.

Other than our few items that we are carrying over because this is a simple
example, our RPM is passing the `rpmlint`_ checks and all is well!


pello
-----

Next up, let's get look at some more output and dive into it one by one.

::

    $ rpmlint pello.spec
    pello.spec:30: E: hardcoded-library-path in %{buildroot}/usr/lib/%{name}
    pello.spec:34: E: hardcoded-library-path in /usr/lib/%{name}/%{name}.pyc
    pello.spec:39: E: hardcoded-library-path in %{buildroot}/usr/lib/%{name}/
    pello.spec:43: E: hardcoded-library-path in /usr/lib/%{name}/
    pello.spec:45: E: hardcoded-library-path in /usr/lib/%{name}/%{name}.py*
    pello.spec: W: invalid-url Source0: https://www.example.com/pello/releases/pello-0.1.1.tar.gz HTTP Error 404: Not Found
    0 packages and 1 specfiles checked; 5 errors, 1 warnings.

Now, I know you might be thinking "That's a lot of errors, this example must be
really wrong" and you would be correct but it is wrong for good reason. The goal
here is two fold, first to make a byte-compiled example that was not too
complicated and allowed to demonstrate some scripting in a SPEC file and second
to show some examples of what we can expect `rpmlint`_ to report other than just
a simple URL missing.

Looking at the output from the check on *pello*'s spec file we can see that we
have a new Error entitled ``hardcoded-library-path`` and it was mentioned during
the previous section that this was known to be incorrect but we were doing it
anyways. The reality is that this is a half truth. Almost always, you should be
using the ``%{_libdir}`` rpm macro or some other more sophisticated macro (more
on this in the :ref:`Appendix <appendix>`. The reason we do not use
``%{_libdir}`` in this instance is because that macro will expand to be either
``/usr/lib/`` or ``/usr/lib64/`` depending on a 32-bit or 64-bit
`architecture`_. Since we are packaging ``noarch`` that would have become
problematic for one arch or the other in the event of a compile on one, run on
the other. We also don't dive into more clever rpm macros as they are out of
scope when trying to learn RPM Packaging at and introductory level, which is
already a feat of it's own. For the sake of this example, we can ignore this
Error but in a real packaging scenario you should either have a reasonable
justification or find the appropriate rpm macro to use.

Once again, the URL listed in the ``Source0`` directive can not be reached which
is something that we expect for the same reasons given in the previous example.
Since we know why the Warning was emitted and that it was expect, this can be
safely ignored also.

::

    $ rpmlint ~/rpmbuild/SRPMS/pello-0.1.1-1.el7.src.rpm
    pello.src: W: invalid-url URL: https://www.example.com/pello HTTP Error 404: Not Found
    pello.src:30: E: hardcoded-library-path in %{buildroot}/usr/lib/%{name}
    pello.src:34: E: hardcoded-library-path in /usr/lib/%{name}/%{name}.pyc
    pello.src:39: E: hardcoded-library-path in %{buildroot}/usr/lib/%{name}/
    pello.src:43: E: hardcoded-library-path in /usr/lib/%{name}/
    pello.src:45: E: hardcoded-library-path in /usr/lib/%{name}/%{name}.py*
    pello.src: W: invalid-url Source0: https://www.example.com/pello/releases/pello-0.1.1.tar.gz HTTP Error 404: Not Found
    1 packages and 0 specfiles checked; 5 errors, 2 warnings.

When checking *pello*'s SRPM we can see very similar output from the check
against the spec file but we also see that the check against the SRPM looks for
the ``URL`` directive as well as the ``Source0`` directive, neither can be
reached but as we know is expected and these can also be safely ignored.

Once again, the explanation for the ``hardcoded-library-path`` is the same as we
covered previously in the ``rpmlint`` output for the SPEC file.

::

    $ rpmlint ~/rpmbuild/RPMS/noarch/pello-0.1.1-1.el7.noarch.rpm
    pello.noarch: W: invalid-url URL: https://www.example.com/pello HTTP Error 404: Not Found
    pello.noarch: W: only-non-binary-in-usr-lib
    pello.noarch: W: no-documentation
    pello.noarch: E: non-executable-script /usr/lib/pello/pello.py 0644L /usr/bin/env
    pello.noarch: W: no-manual-page-for-binary pello
    1 packages and 0 specfiles checked; 1 errors, 4 warnings.

As with the previous example, things change a bit when looking at Binary RPMs as
the `rpmlint`_ utility is now checking for other things that should be commonly
found in Binary RPMs such as documentation and/or `man pages`_ as well as things
like consistent use of the `Filesystem Hierarchy Standard`_. As we can see, this
is exactly what is being reported and we know that there are no `man pages`_ or
other documentation because we didn't provide any. Also, once again our old
friend the ``HTTP Error 404: Not Found`` is present but we're well aware as to
why.

The two new ones are ``non-executable-script`` and
``only-non-binary-in-usr-lib``.

First is ``W: only-non-binary-in-usr-lib`` which means that we've provided only
non-binary artifacts in ``/usr/lib/`` which is normally reserved for shared
object files which are binary data files and `rpmlint`_ therefore expects at
least some of our files in ``/usr/lib/`` to be binary. This again rounds back to
compliance with the `Filesystem Hierarchy Standard`_ as well as files ending up
in incorrect or inconsistent locations because we are not using the appropriate
rpm macros. This is of course by design *only* for the course of this example.

Next up is ``E: non-executable-script /usr/lib/pello/pello.py 0644L
/usr/bin/env`` which is telling us that `rpmlint`_ has found a file with a
`shebang`_ directive which would normally be an executable and have permissions
more likely to be ``0755`` instead of ``0644`` (meaning it can not be executed),
but since we're simply leaving it as an install artifact reference library
because we used this as an example for doing byte-compilation at build time this
can also be safely ignored.

Other than our items that we are carrying over for the purposes of the example,
our RPM is passing the `rpmlint`_ checks and all is well!

cello
-----

Next up, let's get look at some more output and dive into each.

::

    $ rpmlint ~/rpmbuild/SPECS/cello.spec
    /home/admiller/rpmbuild/SPECS/cello.spec: W: invalid-url Source0: https://www.example.com/cello/releases/cello-1.0.tar.gz HTTP Error 404: Not Found
    0 packages and 1 specfiles checked; 0 errors, 1 warnings.

When checking *cello*'s spec file we can see that things appear much more as
they did in our first example and we only have one warning. This is again that
the URL listed in the ``Source0`` directive can not be reached which is
something expected. Since we know why the Warning was emitted and that it was
expect, this can be safely ignored.

::

    $ rpmlint ~/rpmbuild/SRPMS/cello-1.0-1.el7.src.rpm
    cello.src: W: invalid-url URL: https://www.example.com/cello HTTP Error 404: Not Found
    cello.src: W: invalid-url Source0: https://www.example.com/cello/releases/cello-1.0.tar.gz HTTP Error 404: Not Found
    1 packages and 0 specfiles checked; 0 errors, 2 warnings.

When checking *cello*'s SRPM we can see very similar output from the check
against the spec file but we also see that the check against the SRPM looks for
the ``URL`` directive as well as the ``Source0`` directive, neither can be
reached but as we know is expected and these can also be safely ignored.


::

    $ rpmlint ~/rpmbuild/RPMS/x86_64/cello-1.0-1.el7.x86_64.rpm
    cello.x86_64: W: invalid-url URL: https://www.example.com/cello HTTP Error 404: Not Found
    cello.x86_64: W: no-documentation
    cello.x86_64: W: no-manual-page-for-binary cello
    1 packages and 0 specfiles checked; 0 errors, 3 warnings.


As before, the output has changed when looking at Binary RPMs as the `rpmlint`_
utility is going to check for other things that should be commonly found in
Binary RPMs such as documentation and/or `man pages`_ as well as things like
consistent use of the `Filesystem Hierarchy Standard`_. As we can see, this is
exactly what is being reported just as in the previous examples and we know that
there are no `man pages`_ or other documentation because we didn't provide any.
Also, once again the ``HTTP Error 404: Not Found`` is present but we're well
aware as to why.

Other than our few items that we are carrying over because this is a simple
example, our RPM is passing the `rpmlint`_ checks and all is well!

That's it!

Our RPMs are sanitized (or we know and understand why they aren't) and it is now
time to either go forth and Package RPMs or travel on into the
:ref:`Appendix <appendix>`.


.. include:: citations.rst
