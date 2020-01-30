Adding support for Indicia
--------------------------

When coding for Indicia client websites, we could write all the code we need to
interact with Indicia's web services and to output the relevant form controls 
by hand but this would be very long winded. Having a library of ready made
pieces of code we just need to glue together to build our forms is of course
one of the attractions of Indicia and just because we are writing PHP code by 
hand does not mean we should not benefit from all this Indicia goodness. The 
libraries of code that we need to use in our PHP are contained within a download
called Client Helpers, available from the `Indicia client_helpers GitHub repo
<https://github.com/Indicia-Team/client_helpers>`_. Follow these steps to set
it up:

#. Download the latest version of the Client Helpers library and unzip it into 
   your tutorial folder, so that you have a folder called client_helpers within 
   your tutorial folder.
#. Inside the client_helpers folder find the file called ``_helper_config.php``. 
   Make a copy of this file and name it ``helper_config.php``.
#. Open helper_config.php in a text editor or using your development 
   environment. Inside the file you will see that it defines a list of variables
   which provide configuration options for the client helper libraries.
#. The only option we need to set for this is the ``$base_url`` which needs to 
   be set to the URL of the warehouse. This should be the full URL of the 
   path to the warehouse including trailing slash, e.g. 
   ``http://testwarehouse.indicia.org.uk/`` or ``http://localhost/indicia/``. So
   set this option as appropriate and save the file.
#. On your tutorial.php page, add a new line just after the ``<body>`` element 
   and paste in the following:

.. code-block:: php

  <?php 
  require_once 'client_helpers/data_entry_helper.php';
  echo data_entry_helper::system_check();
  ?>

Now, reload your tutorial page and see what happens. You will hopefully find a 
group of diagnostic messages. Mine looks like the following::

  System check

    Success: PHP version is 5.3.1.
    Success: The cUrl PHP library is installed.
    Success: Indicia Warehouse URL responded to a POST request.
    Warning: The $geoserver_url setting in helper_config.php should include the protocol 
    (e.g. http://).
    Warning: The following configuration entries are not specified in helper_config.php :
    $geoserver_url, $geoplanet_api_key, $bing_api_key, $flickr_api_key, 
    $flickr_api_secret. This means the respective areas of functionality will not be 
    available.
    The cache path setting in helper_config.php points to a read only directory 
    (client_helpers/cache/). This will result in slow form loading performance.

  Just to be sure PHP is working!

So, what has actually happened here? The first of the 2 new lines of code ask
PHP to include the data_entry_helper.php file into our development page. This
is often all you need to do to include Indicia's client helper libraries, 
though there are also other helper files such as report_helper.php and 
map_helper.php which are used for reporting and mapping tasks respectively.
The second of these 2 lines calls one of the methods provided by the 
data_entry_helper class, called system_check, and echos the output to the 
web page. 

.. note

  Because the Indicia helper methods are *static* you do not need to create
  an instance of the class before using them. You can call the methods directly
  on the class itself using the double colon to identify to PHP that you are
  calling the method statically. For more information on static methods see
  `the PHP documentation <http://php.net/manual/en/language.oop5.static.php>`_.

On your web page you should now see that there are a few messages about 
successful tests as well as two warnings relating to missing configuration 
settings; we can safely ignore these for now as they related to 
configuration only required for functionality that is not covered by this 
tutorial. The final warning I have on my version of the page is about a 
permissions issue accessing the client_helpers/cache folder. This folder is not
essential but without it, every single piece of information required from the 
warehouse server will be requested every single time a page is loaded, making 
things pretty slow. Depending on the operating system you are using you may not
see this message anyway, in my case I am going to make the cache folder read
and writeable to the web server process so I can benefit from it. Having done
this, reloading the page shows that ths original message is replaced by a 
success message.