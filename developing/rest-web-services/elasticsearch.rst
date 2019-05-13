Using the REST API to serve Elasticsearch data
==============================================

Whilst PostgreSQL and PostGIS combine to provide a robust, flexible and powerful solution
for Indicia's data storage needs, reporting on very large datasets can slow down. This is
mainly because it is impossible to create an indexing strategy which caters for the wide
range of filtering options required. Unless you create indices which cover all possible
combinations of filtering, sometimes you will find a query is unable to limit the records
sufficiently using an index and resorts to either a table scan, or scanning and filtering
a large results set returned from an index filter where the index wasn't effective at
reducing the number of records. Also, note that PostgreSQL prioritises robustness over
sheer speed, a strategy which makes sense for a primary data store.

`Elasticsearch <https://www.elastic.co>`_, on the other hand, is a reporting and analysis
solution that approaches things from the perspective of optimisation for performance.
Although not ideal as a primary data store both because of the limitations in how it
structures data and the possibility of data loss, it makes an excellent secondary data
store to support reporting. The free, open-source version of Elasticsearch does not
provide any authentication or authorisation which can be a problem for biological records
data, especially if you choose to include confidential or sensitive records in your
search index. Therefore, Indicia includes the tools required to set up proxies to your
Elasticsearch server which restricts access to the data appropriately. The following
points explain how this works:

* Your Elasticsearch cluster is populated with all data at both full precision with a
  second copy of sensitive records in a "public friendly" blurred version. It is also
  populated with confidential records. Therefore the public should not have direct access
  to this cluster.
* Elasticsearch aliases are configured with appropriate filters so that there are aliases
  which provide appropriate levels of access. E.g. a public alias which excludes the full
  precision versions of sensitive records and excludes all confidential records.
* To avoid direct access, all access to the Elasticsearch cluster must be channelled via
  the Indicia warehouse which takes responsibility for ensuring that requests go via an
  alias with an appropriate level of access. To achieve this, at the very least the IP
  address of the cluster is kept secret. Ideally though either:
  * The cluster is set up on the same local area network with the Indicia warehouse but
    only the warehouse is accessible from outside the firewall.
  * The cluster is set up on another network (e.g. a cloud installation) and IP address
    blocking is used to ensure that only the warehouse and other authorised static IP
    addresses can access it.
* The Indicia REST API can then be used to provide an authentication layer which restricts
requests to the appropriate, filtered search index aliases. If the Elasticsearch server is
configured to only receive requests from the Indicia warehouse server, then the
Elasticsearch index can only be accessed via Indicia's warehouse REST API, limiting the
chance that restricted data will be accessed inappropriately.

Documentation on configuring an Elasticsearch index to link to your warehouse is available
at https://github.com/Indicia-Team/support_files/tree/master/Elasticsearch. This includes
an explanation of how to deal with sensitive records by including both full-precision and
blurred versions of each record and to configure index aliases to view the full-precision
or blurred dataset.

There are 3 pieces of configuration required in your REST API's config file on the
warehouse which are illustrated in an example at
https://github.com/Indicia-Team/warehouse/blob/master/modules/rest_api/config/rest.example.php.
First, you need a section in the config file containing an `elasticsearch` entry. The
example below illustrates the content of this block:

.. code-block:: php

  /**
  * If this warehouse is configured to work with an Elasticsearch instance then
  * the REST API can act as a proxy to avoid having to expose all the public
  * APIs. The proxy can point to index aliases to limit the search filter.
  */
  $config['elasticsearch'] = [
    // Name of the end-point, e.g. /index.php/services/rest/es.
    'es' => [
      // Set open = TRUE if this end-point is available without authentication.
      // Otherwise it must be attached to a configured client.
      'open' => FALSE,
      // Name of the elasticsearch index or alias this end-point points to.
      'index' => 'occurrence',
      // URL of the Elasticsearch index.
      'url' => 'http://localhost:9200',
      // If specified, limit the access to the following operations. List of
      // HTTP request types (e.g. get, post, put, delete) each containing a
      // list of regular expressions for allowed requests, along with the
      // description of what that allows.
      // So, this example allows the following call:
      // http://mywarehouse.com/index.php/services/rest/es/_search?q=taxon.name:quercus
      // which proxies to
      // http://my.elastic.url:5601/occurrence/_search?q=taxon.name:quercus
      'allowed' => [
        'get' => [
          '/^_search/' => 'GET requests to the search API (/_search?...)',
        ],
      ],
    ],
  ];

So, the `elasticsearch` configuration entry defines a list of end-points that will be
created within your REST API. There is a single end-point in the example above,
/index.php/services/rest/es, but you can create any number you need to, e.g. to provide
access to multiple filtered versions of the index via Elasticsearch aliases.

The documentation in the code above explains the different possible configuration options
for the configuration section. Take particular care over the `allowed` section. This
declares a list of HTTP methods that are allowed (lowercase, e.g. get, put, post, delete),
and for each a list of regular expressions for the end-points within the elasticsearch
server that may be accessed. These will be appended to the configured index or alias name
so allowing you to selectively expose your Elasticsearch instance via a restricted set of
APIs. The above example is limited to the Search API for example.

This configuration sets up the Elasticsearch index for use in Indicia and links it to a
URL that can be accessed via your REST API, but it does not yet declare any authorisation.
The configuration can be open, allowing it to be accessed without any authorisation, but
in reality we are likely to want to use one of the existing :doc:`authentication`
methods to access Elasticsearch. To do this, add a configuration key within your
authentication method's config called `elasticsearch`, containing an array of the
Elasticsearch end-points you created earlier (just `es` in our case). So, for example you
might enable Elasticsearch via the /index.php/services/rest/es end-point using hmacWebsite
authentication by setting up the configuration as follows:

.. code-block:: php

  $config['authentication_methods'] = [
    'hmacWebsite' => [
      ...
      'resource_options' => [
        ...
        'elasticsearch' => ['es'],
      ],
    ],
    ...
  ];

If using client authentication (directClient or hmacClient) then there is one more step -
you need to attach the appropriate Elasticsearch end-points to the client by adding
a configuration key, similar to the way you attached them to the authentication methods.
This is done by adding an `elasticsearch` configuration entry to the `$config['clients']`
entry for the client you are enabling access for, which contains an array of the
config entries defined in `$config['elasticsearcg']` which you wish this client to be able
to access:

.. code-block:: php

  $config['clients'] = [
    'ABC' => [
      'shared_secret' => 'password',
      'projects' => [
        ...
      ],
      'elasticsearch' => ['es'],
    ],
    ...
  ];

