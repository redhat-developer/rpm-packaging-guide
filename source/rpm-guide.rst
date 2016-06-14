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

While these distros are the target environment, it should be noted that lessions
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

What is a RPM?
--------------

To kick things off, let's first define what an RPM actually is. An RPM package
is simply a file that contains some software as well as information the system
needs to know about that files. More specifically, it is a file containing a
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

.. _what-is-spec-file:

What is a SPEC File?
--------------------

A SPEC file can be thought of the as the **recipe** for that the ``rpmbuild``
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
not something we control as a RPM Packager but is a side effect of the
``rpmbuild`` build environment, something we will cover in more detail later.


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

A `rpm macro`_ is a straight text substition that can be conditionally assigned
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
packaging software in the SPEC file since this is the receipe we use to tell
``rpmbuild`` how to actually perform a build. In this section we will discuss
how to create and modify a spec file.

When it comes time to package new software, you will want to create a new SPEC
file and we *could* write one from scratch from memory but that sounds boring
and tedious so let's not do that. The good news is that we're in luck and
there's an utility called ``rpmdev-newspec`` which will create one for us and we
will just fill in the various directives or add new fields as needed. This
provides us with a nice baseline template.

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
we created a simulated upstream release of (or you downloaded) and placed it's
source code into ``~/rpmbuild/SOURCES/`` earlier. Let's go ahead and open the
file ``~/rpmbuild/SOURCES/bello.spec`` and start filling in some fields.

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
*bello* source code is, which if we remember we set to be ``0.1`` when we
simulated our upstream source code release earlier (or as it is set by the
example code you downloaded).

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
we will use the rpm macro variable of ``%{name}`` in it's place for consistency.

The ``Source0`` field is where the upstream software's source code should be
able to be downloaded from. This URL should link directly to the specific
version of the source code release that this RPM Package is packaging. Once
again, since this is an example we will use an example value:
``https://example.com/bello/releases/bello-0.1.tar.gz`` and while we might want
to, we should note that this example URL hase hard coded values in it that are
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

Something we need to add here since this is software written in an  interpreted
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
installing will be ``%{_bindir}/%{name}`` (this would be ``%{_bindir}/bello`` if
we weren't using the rpm macro variable instead of the hard coded name).

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
programming language that we created a simulated upstream release of previously
(or you downloaded) and placed it's source code into ``~/rpmbuild/SOURCES/``
earlier.

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
*pello* source code is, which if we remember we set to be ``0.1.1`` when we
simulated our upstream source code release earlier (or as it is set by the
example code you downloaded).

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

We should note that this example URL hase hard coded values in it that are
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
software. For those who read the previous sections, this section of the example
should look familiar. The ``%build`` section of our SPEC file should look as
follows.

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
    the :ref:`Appendix <appendix>` and are specific to the programming language
    in which the software that is being packaged was written in. In this example
    we hard code the path for simplicity as to not cover too many topics
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
*cello* source code is, which if we remember we set to be ``1.0`` when we
simulated our upstream source code release earlier (or as it is set by the
example code you downloaded).

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

We should note that this example URL hase hard coded values in it that are
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
    * Tue May 31 2016 Adam Miller <maxamillion@gmail.com> - 1.0-1
    - First cello package

Prepping Our Build Environment
==============================

FIXME

Building RPMS
=============


FIXME

Checking RPMs For Sanity
========================

FIXME: rpmlint

.. include:: citations.rst
