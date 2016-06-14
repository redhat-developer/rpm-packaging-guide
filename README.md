# RPM Packaging Guide
[![Documentation
Status](https://readthedocs.org/projects/rpm-guide/badge/?version=latest)](http://rpm-guide.readthedocs.io/en/latest/?badge=latest)

This is an RPM Packaging Guide.

Many of the guides I have found around the internet are either too detailed, not
detailed enough, or are simply showing their age and contain old, incorrect or
outdated information. My hope here is to provide a guide that can be maintained
and expanded upon over time.

The document itself is written in
[sphinx-doc](http://www.sphinx-doc.org/en/stable/)
[reStructuredText](http://www.sphinx-doc.org/en/stable/rest.html) and uses the
[sphinx_rtd_theme](https://github.com/snide/sphinx_rtd_theme).

You can find the document source in `source` in this git repository. In order
to render it, make sure you have
[sphinx-doc](http://www.sphinx-doc.org/en/stable/) installed and run [gnu
make](http://www.gnu.org/software/make/).

Example:

    make html

## Rendered Docs

To find a Rendered Version of the latest Docs, you can find them on ReadTheDocs:

http://rpm-guide.readthedocs.io/en/latest/


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
