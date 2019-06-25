.. _documentation-tutorial:

**********************************************
Contributing to the Documentation - a Tutorial
**********************************************

Let's run through the steps needed for you to start
contributing to the documentation.
You should have read the overview, :ref:`documentation`,
first. To reiterate, We hold a repository ('repo' for
short) of all the
ReStructureed Text (RST) documents that comprise
the Indicia documentation on the GitHub website.
The administrator of the documentation website
converts the RST into HTML for use on the `public
website <https://indicia-docs.readthedocs.io/en/latest/>`_.

Getting to Grips with Git
=========================

Let's start by taking a look at Git. Git is a source control
system used for organising and controlling files.
It gives us a way of controlling and organising the
documentation we are writing. For instance, we need to
avoid people overwriting other contributors' work by
accident and it is also useful to track who has changed
a particular document. In reality this is just a small
selection of the kinds of control that need to be applied
during the development of our documentation.

There's really no way round the fact that to contribute to
the Indicia documentation, you will need to get to grips
with Git.

To contribute to the Indicia documentation, you need to
work with GitHub and a Git client on your
computer. These are two different but related things
as you will see.

A good explanation of the general workflow we are recommedning is 
given in this blog: `The beginner's guide to contributing to a GitHub
project <https://akrabat.com/the-beginners-guide-to-contributing-to-a-github-project>`_.

Get a GitHub account and fork Indica-docs
=========================================

The GitHub website implements Git version control and
acts as a cloud-hosted hub where open source projects can
hold their source code.
Your first task to is to register and get an account for
that website. This is very straightforward and, needless
to say, free!

https://github.com/

Members of the Indicia project team can work directly with
the `indicia-docs GitHub repo 
<https://github.com/Indicia-Team/indicia-docs>`_, but you
don't have to be a member of the project team to contribute
to the documentation. Instead you can use the **Fork** button
(top-right on the indicia-docs GitHub rep page) to
copy the entire repo to your own account. The workflow
is that you will modify this fork and then make a **pull request**
to have your changes merged into the original repo. So
if you haven't yet forked the repo
to your own GitHub account, do that now.

Although you can edit files directly on your fork on
the GitHub website,
it is much more convenient to make a copy on your local computer,
work there and then update your fork before requesting that
your updates be merged into the main repo.

This is where you need a Git client of some sort on 
your computer. 

Set up your Git client
======================

There are many Git clients out there, but
we recommend that you install 
`Visual Studio Code (VS Code) <https://code.visualstudio.com/>`_. 
Not only is it a fully featured code editor that you can use to
edit your Indicia RST files, but it is also a *Git client*.

If you use VS Code you can choose whether to use its GUI
to interact with Git or to use Git from the command line
(which you can do through the Terminal window from within
VS Code if you like). Or you can used a mixture of the
two. Sometimes using the Git command line
interface is unavoidable, so for the sake of simplicity
this tutorial sticks with the Git command line interface.

Clone your fork to your local computer
======================================
Once you have installed VS Code on your coputer, you will also
have installed Git. So now we can take a local copy of our
fork or the Indicia documentation.

Open a command tool (or terminal - whatever your operating
system calls it) on a convenient folder on your computer
where 

Find a folder on your computer where you want to copy
the indicia-docs folder from your fork and open VS Code there.
In VS code, open a Terminal window. If the working directory
of your terminal window is not the folder where you want
to create the indicia-docs folder, first change into 
that folder.

Now type the folloiwng command in the terminal::

  git clone path_to_your_fork

To get the value for 'path_to_your_fork' go to your GitHub
repo (your forked repo) and click on the green 'Clone or
download' button. You sill see there the path the your repo
which you can copy and paste into the terminal window. So
your actual command will look something like this::

  git clone https://github.com/burkmarr/indicia-docs.git

But it will reference your own fork.

This will result in a folder called 'indicia-docs' on
your computer which is 'tracked' by Git.

Add a remote to link with the original repo
===========================================
In your terminal window, move into the new indicia-docs folder::

  cd indicia-docs

The repo on your
computer is already linked to your GitHub fork. Your fork is a known
as a **remote** of the local repo on your computer. To pull from 
the original repo you must also add that as a remote of your local
repo. The following git command will do that::

  git remote add upstream https://github.com/Indicia-Team/indicia-docs.git

Now your local repo has two remotes: 'origin' which is your fork and
'upstream' which is the main repo.

Bringing your remote and local repos into line
==============================================

To keep your local repo and your remote forked repo up to date with
work done by other people, you will periodically need to **pull**
down changes made by others from the main repo into your local
repo and **push** these to your forked repo.
To update your local repo and your fork with the latest changes
from the main repo, you perform these git commands::

  git pull upstream master
  git push origin master

This is normally something you'd do before undertaking a piece
of work of your own.

Note that if you have carried out work on files which have not
yet been incorporated into the main repo, you might at this
point get 'merge conflicts' (pulling actually carries out
a Git merge). It is beyond the scope of this tutorial to
cover dealing with merge conflicts, but there are plenty
of Git resources on the web to help with that. In any case,
if you undertake the pull and push *before* you start work,
you may never need to deal with a merge conflict - Instead
the administrator of the documentation will sort out any
conflicts when processing your **pull request** (covered later).

Create a branch to work in and do some work!
============================================
Branching is a fundamental part of the Git workflow. It helps
us isolate changes we make from the main source until we
(or the project administrator) chooses to merge them in.

Create and **checkout** a branch like so::

  git checkout -b your_branch_name

Keep branch names short and descriptive. Because you where
already in indicia-docs 'master' branch, you have just created
a complete copy of the master branch and checked it out - which
means that any changes you make to files now will occur in 
that branch.

Now you can use VS Code to edit and save files etc. You can use
and extension like 'reStructuredText' to preview changes
you make to files.

When you have completed the work you wanted to do in that
branch you can **commit** the changes you made. Note that
this only updates your new branch - it doesn't change the
master branch. To commit all the changes you made, type::

  git commit -a

An editor will appear in VS Code with text that summarises
the changes you have made. You must now edit the first
line of this to git a **commit message**. Keep is short - no
more than 50 characters. Underneath this, you can insert
lines to give a more detailed explanation of your changes.
Each of these lines should be no more than 72 characters.
(These line length limits enable Git to be able to format
commit messages nicely. Longer line lengths look bad.)

When you are happy with your commit message, save the
file and close the edit window. You will now see the
commit complete in the terminal window.

Note that you can actually make as many commits as you
like as your work progresses - there's no need to wait
and do one big commit at the end. The more you use Git
and understand its other features, e.g. for rolling back
changes, the more likely you will want to commit smaller
chunks of work. Note that we have also glossed over a
step called **adding** or **staging** changes which you
can do before committing (the 'commit -a' command stages
and commits in one fell swoop). Again the more you use
Git, the more likely you are to want to learn about
the subtelties of separate staging and commiting.

Push your new branch to your forked repo
========================================
Now that you have committed your changes in your local work
branch, you can push these to your forked repo like this::

  git push -u origin your_branch_name

This will create a new branch on your GitHub forked repo
with the same name as your local branch and include all
the changes you committed.

Open a pull request on the main repo
====================================
From your GitHub account, go to you forked repo and find
the branch that you've just pushed.





