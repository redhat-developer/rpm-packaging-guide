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

Later, the document was converted to AsciiDoc and is published at
[https://rpm-packaging-guide.github.io/](https://rpm-packaging-guide.github.io/).

You can find the document topic pages in the `source` directory in this Git
repository. The `community` and `rhel` directories contain index pages for an
upstream community version and a RHEL downstream version, respectively.

In order to render it, first make sure you have
[asciidoctor](http://asciidoctor.org/) installed.

To render the community version, run:

    asciidoctor community/index.adoc

To render the RHEL version, run:

    asciidoctor rhel/master.adoc

## Publishing Mechanism

The publishing mechanism uses two configuration files
`.github/workflows/asciidoc.sh` and `.github/workflows/ci.yml`
and is based on GitHub Actions
https://github.com/marketplace/actions/convert-asciidoctor-docker-action
and https://github.com/marketplace/actions/push-directory-to-another-repository.

Each commit pushed to the `master` branch automatically triggers a community
version build, so you don't need an extra tool installed locally in order to
publish and update the document. GitHub Actions push the built HTML and PDF to a
staging repository
https://github.com/rpm-packaging-guide/rpm-packaging-guide.github.io,
and GitHub Pages then publishes the HTML and PDF to
https://rpm-packaging-guide.github.io/
and https://rpm-packaging-guide.github.io/rpm-packaging-guide.pdf.

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
