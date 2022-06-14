IForm Release procedure
=======================
There are a number of steps to take to create a new release of the IForm module.
It often coincides with or follows a warehouse release so the media and
client_helper sub-modules will already be tested, tagged and released. If not
you can follow the :doc:`warehouse release procedure
<../warehouse/release-procedure>` to prepare the submodules. The version number
for the release is always the same as the most recent warehouse version number
so the IForm module can have rather erratic numbering.

1. Review outstanding pull requests and merge those that are to be part of the 
   new release.
2. Checkout the dev branch and ``git pull``.
3. Checkout the master branch and ``git merge --no-ff --no-commit develop``.
4. Use a diff tool to review the code changes, writing a list of key points for 
   a release note. If ther are problems, merge abort, then either fix them or go 
   back to the original developer. Git lens in VS Code is great for tracing back 
   from changed lines to commits.
5. If OK, then commit the merge.
6. Set the version number in `iform.info.yml` and commit.
7. Commit the submodule positions at the head of their master branches.
8. ``git tag -a vx.y.z`` and ``git push --follow-tags`` where ``x.y.z`` is the 
   version number.

Having pushed the changes to master and tagged it with the version number

1. Close any issues that have been resolved by the release.
2. Create a release on Github, with the version number as the title and a
   description of the new features in the body. Attach to the release a zip file 
   created with the following (linux) script. 

::

   git clone --recursive https://github.com/Indicia-Team/drupal-8-module-iform.git iform
   rm -rf iform/.git
   rm -rf iform/client_helpers/.git
   rm -rf iform/media/.git
   find . -type f -print0 | xargs -0 dos2unix
   zip -r iform-x.y.z.zip iform

Substitute the version number for ``x.y.z``.
