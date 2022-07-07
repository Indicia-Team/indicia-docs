Release procedure
=================
There are a number of steps to take to create a new release of the warehouse.
The media and client_helper sub-modules are released at the same time and 
must be done first, as follows.

Submodule release
-----------------
1. Review outstanding pull requests and merge those that are to be part of the
   new release.
2. Confirm that continuous integration tests are passing on the develop branch.

There is a low-key route and a more involved route to the end point of merging
the code from dev in to master.
Either

3. Checkout the dev branch and ``git pull``.
4. Checkout the master branch and ``git merge --no-ff --no-commit develop``.
5. Use a diff tool to review the code changes, writing a list of key points
   for a release note. If ther are problems, merge abort, then either fix them 
   or go back to the original developer. Git lens in VS Code is great for 
   tracing back from changed lines to commits.
6. If OK, then commit the merge, plus ``git tag -a vx.y.z`` and 
   ``git push --follow-tags``

Or

3. Checkout the develop branch and ensure your local copy is up to date by
   pulling any updates, then create a release branch named `release-x.y.z` 
   where x.y.z is the new version number.
4. Create a merge request in Github to merge the release branch in to master.
   In the comments, list the features and fixes. Git hub shows the files 
   changed which should be reviewed.
5. If OK, then merge the pull request and delete the branch in Github.
6. Separately, tag the master branch with `vx.y.z` wher x.y.z is the version
   number and push the tag to the repo. Git Graph in VS Code allows you to do 
   this prettily.
7. Merge any changes you made in the release branch back in to dev.

Warehouse release
-----------------
Repeat the same process for the warehouse as described for the submodules but, 
before merging to master,

- Set the version number and date in `application/config/version` and commit.
- Update `CHANGELOG.md` and commit.
- Commit the submodule positions at the head of their master branches.

Having pushed the changes to master and tagged it with the version number

1. Close any issues that have been resolved by the release.
2. Create a release on Github, with the version number as the title and a
   description of the new features in the body. Attach to the release a zip file 
   created with the following (linux) script.

::

   git clone --recursive https://github.com/Indicia-Team/warehouse.git
   rm -rf warehouse/.git
   rm -rf warehouse/client_helpers/.git
   rm -rf warehouse/media/.git
   composer install --working-dir=warehouse --no-dev
   zip -r warehouse-<version>.zip warehouse

Documentation
-------------
The source of this documentation can be found in 
https://github.com/Indicia-Team/indicia-docs. The documentation is provided in
two versions, 

* `latest`, which is tied to the head of the master branch, and may document 
  features that are still in development.
* `stable`, which is tied to the most recently tagged commit, and should reflect
  the current release.

On a warehouse release

1. Review and merge outstanding pull requests.
2. In `conf.py`, set the following and commit

   * `version = <major_version>`
   * `release = <major.minor version>`
3. Tag the commit with the the version of the warehouse.

