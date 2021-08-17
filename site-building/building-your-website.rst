*********************
Building your website
*********************

To set up an Indicia based online recording website, there are key things that 
need to be in place. Firstly, you need a website to add your recording web pages 
to. Indicia provides the online recording forms, maps and reports to integrate
into your site. This could be a site which already exists if you are looking to 
add recording functionality to the site or it could be a site which you are 
building from scratch. At the very least, the server your website is running on 
needs to support **PHP version 7.3 or higher**, which fortunately is supported 
by most low cost shared server web hosts. There are several possible scenarios 
regarding the website development: You are starting from scratch to build a new 
website. You already have a website which uses a Content Management System You 
already have a website with static HTML pages.

Starting from scratch
=====================

If you are starting from scratch you might like to consider using the `Drupal <http://www.drupal.org>`_
content management system to build your website. Like Indicia, Drupal is free, open source and based on
the PHP programming language. Drupal provides a very capable environment 
for setting up online recording websites and integrates with Indicia
through the installation of modules that have been created for this purpose. Moreover, there are a 
number of other sites using this combination of technology so you won't be on 
your own. Drupal not only provides a system for building and publishing the 
content of the website, but it can be extended with a choice of many thousands 
of available modules. For example you can add a forum, online shopping and many 
other features just by using the modules. With Drupal installed, it is possible 
to setup Indicia forms as a site editor without needing to understand any PHP 
code, though if you do have PHP skills available then more possibilities will be 
available to you.

Another option when starting from scratch would be to develop a site using hand 
coded PHP. This approach is useful if you have good PHP programming skills 
available and want to be able to finely control the forms produced using Indicia 
or prefer to avoid the overhead of running a system such as Drupal. Don’t forget 
though that even within Drupal you are not restricted to using particular forms 
and can still write your own customised forms using PHP directly.

Existing website using a content management system
==================================================

There are hundreds, if not thousands of different content management systems 
based on a variety of different technologies. Unless the content management 
system is Drupal (the only one which we provide an Indicia module for) you will 
need to find out if it is possible to embed your own PHP code into the web 
pages. This will depend both on the web server and the selected content 
management system. Fortunately all web servers are capable of running PHP as 
long as it is installed and many content management systems are able to embed 
PHP into their web pages. If this is not possible then another option is to have 
the Indicia web pages running in PHP files in a separate folder to the rest of 
the website. This is not a perfect solution though as you then cannot easily use 
the content management system login to control access to the web pages and will 
have to craft your Indicia pages to look like they are part of the same site.

Existing website with static HTML pages
=======================================
If you have an existing website with static HTML pages then first, you need to 
check that your server has PHP installed so you can embed PHP code into your web 
pages. To test this, create a file called phpinfo.php in a folder on your 
website and add the following:

.. code-block:: php

  <?php echo phpinfo(); ?>

Save this file and load it using a web browser, e.g. at 
http://www.example.com/phpinfo.php. If PHP is enabled then you should see a dump 
summarising information about your PHP configuration. You should also check that 
the PHP version described on this page is at least PHP 7.3. If PHP is not 
installed or the PHP version is older then you will need to check with your web 
host to see if they can install PHP 7.3 or higher for you.

Something you should also consider if you have an existing website is whether it 
is worth converting into a content management system. This allows you to manage 
the site and create new content without having to create new HTML files and can 
be much more efficient for larger sites. For example you can have site editors 
who work on content without being coders. Of course there is a lot of effort 
required in the initial conversion but it may be worth it in the longer term.

About the Indicia Warehouse
===========================

The second component that needs to be in place is the Indicia Warehouse. This 
will normally run on a second web server and it provides both an interface for 
you to administer your website and also allows the Indicia components on your 
website to store and access data including species lists, sites, recorders and 
the observation records themselves. If you have your own web hosting capability 
you may like to install your own Warehouse. Don't worry if this is not possible, 
a single Warehouse is designed to be able to support multiple recording websites 
so the overheads of running a Warehouse can be shared. For example, in the UK 
the Biological Records Centre host a Warehouse which is available to recording 
schemes or other small organisation in the UK subject to agreement.
