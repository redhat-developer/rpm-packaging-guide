# RPM Packaging Guide

This is an RPM Packaging Guide.

Many of the guides I have found around the internet are either too detailed, not
detailed enough, or are simply showing their age and contain old, incorrect or
outdated information. My hope here is to provide a guide that can be maintained
and expanded upon over time.

The document itself was originally written in
[sphinx-doc](http://www.sphinx-doc.org/en/stable/)
[reStructuredText](http://www.sphinx-doc.org/en/stable/rest.html) and was
published at http://rpm-guide.readthedocs.io/en/latest/.

The document is now being converted to AsciiDoc and its draft is published at
[https://rpm-packaging-guide.github.io/](https://rpm-packaging-guide.github.io/).
Note that this is a work in progress.

You can find the document topic pages in `source` in this git repository. The
`community` and `rhel` directories contain index pages for an upstream community
version and a RHEL 7 downstream version, respectively.

In order to render it, first make sure you have
[asciidoctor](http://asciidoctor.org/) installed.

To render the community version, run:

    asciidoctor community/index.adoc

To render the RHEL 7 version, run:

    asciidoctor rhel/master.adoc

## Publishing Mechanism

The publishing mechanism is using a single configuration file in `.travis.yml`
and is based on a GitHub+Travis CI+Asciidoctor container+GitHub Pages toolchain,
an idea taken from
[http://mgreau.com/asciidoc-to-ghpages/](http://mgreau.com/asciidoc-to-ghpages/).

## Licensing

To make licensing easier, license headers in the source files will be
a single line reference to Unique License Identifiers as defined by
the [Linux Foundation's SPDX project](http://spdx.org/).

For example, in a source file the full "GPL v2.0 or later" header text will be
replaced by a single line:

    SPDX-License-Identifier:    GPL-2.0+

Or alternatively, in a source file the full "CC-BY-SA-4.0" header text will be
replaced by a single line:

    SPDX-License-Identifier:    CC-BY-SA-4.0

the license terms of all files in the source tree should be defined
by such License Identifiers; in no case a file can contain more than
one such License Identifier list.

If a `SPDX-License-Identifier:` line references more than one Unique
License Identifier, then this means that the respective file can be
used under the terms of either of these licenses, i. e. with

    SPDX-License-Identifier:    GPL-2.0+    LGPL-2.1+

All SPDX Unique License Identifiers available [here](http://spdx.org/licenses/).
