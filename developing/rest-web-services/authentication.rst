RESTful web service authentication
==================================

Indicia's web services provide support for a variety of different types of clients,
including:

  * Users (e.g. recorders or people seeking to use the data).
  * Websites with online recording and reporting facilities.
  * Mobile applications.
  * Other databases which synchronise data with the Indicia instance.
  * Developers working on site building or report writing.

In order to meet the needs of the different types of client, there are several
options for approaches to authentication.

  * A website or application might wish to authenticate as a registered website on the
    warehouse and will therefore gain access to all records contributed  via that website
    or shared with the website for reporting purposes.
  * A mobile application (with associated website registration on the warehouse) user might
    authenticate as that specific user/application combination to gain access to just the user's
    app records for reading and writing.
  * A remote database which synchronises with the warehouse needs to identify itself in order for
    the warehouse to ensure the correct filtered set of records is made available to it.
  * A user of the data needs to identify the filtered set of data they have permission to
    view.
  * A developer will want to be able to simulate all these options without the
    authentication process hindering the simplicity of development.

When considering how to authenticate, first identify which of the following entities you want to
authenticate as:

  * **A user** - user of one of the websites registered on the warehouse and stored in the `users`
    table. This allows you to create, update and delete their records and report on their records.
  * **A website** - a website registered on the warehouse stored in the `websites` table (with the
    user being anonymous). This allows you to report on the data available to that website which
    may include other websites if they have elected to share their data.
  * **A client** - a named client system configured on the REST API, which is then allowed to
    report on a specific set of data defined in configuration. For example a client system might be
    able to access the data for a specific project or site only, or the client system might
    represent another online recording system which exchanges data with Indicia. Named clients can
    be defined in the REST API's config file, but defining them via the `rest_api_clients` and
    `rest_api_client_connections` tables via the `Admin > REST API Clients` menu item in the
    warehouse user interface is now the preferred approach. *Support for clients defined in the
    REST API module's config.php file is provided for legacy reasons only.*

For all 3 options, it is possible to use JSON Web Token (JWT) authentication but it is also
possible to authenticate by providing a user/secret combination using one of several approaches if
the warehouse is configured to allow this (e.g. the website ID and password act as the user/secret
combination when authenticating as a website). Using JWT authentication requires that a
public/private key pair is generated and the public key stored in the appropriate warehouse
configuration for either the website or client system.

Authentication methods
----------------------

The following preferred methods of authentication are available but must be enabled in the warehouse's
`modules/rest_api/config/rest.php` file's `$config['authentication_methods']` section (see the
provided example file for more info) before they can be used.

jwtUser
*******

This is the preferred authentication method for authentication when acting as a user who may post
records into the system and provides both read and write access to that user's records. It uses a
``http://indicia.org.uk/user:id`` claim in the token which refers to the user's warehouse user ID,
but it is also possible to post anonymous records into the system by ommitting this claim if the
`websites.allow_anon_jwt_post` flag is set via the website's edit page onthe warehouse. For more
information, see the **JSON Web Token authentication** section below.

jwtClient
*********

Authenticate as a **client** using **JSON Web Token authentication**. This is the preferred method
of authentication when connecting as a read-only data user. Note that in this context a user could
be a person or a reporting system amongst other things. The client must be configured in the REST
API's config file or database tables. For more information, see the **JSON Web Token
authentication** section below. The `jwtClient` authentication method must be enabled in the REST
API's config file and, in addition, you should use the `Admin > Rest API Clients` section to create
a client, along with its public key. Once created, you can use the Connections tab from the
client's Edit tab to define a connection (identified by a proj_id) and appropriate permissions.

Other authentication methods
----------------------------

In addition to the preferred JSON web token methods above, the following alternatives to JWT
authentication are available but please review their advantages and disadvantages before using
them. Note that the direct authentication methods are inherently insecure over http and should
therefore only be used for development purposes unless using https.

directClient
************

This approach allows client systems to authenticate by directly providing their client's username
and secret directly, normally in the auth header:

```
USER:[client system username]:SECRET:[secret]
```

The username and secret must be defined for the client in the rest_api_clients database table
(preferred) or config file's `clients` section (legacy). For more information, see the **Direct
authentication** section below.


directUser
**********

This approach allows users to authenticate in the context of the website they are connecting
from by directly providing their user ID, website ID and secret directly, normally in the auth
header:

```
USER_ID:[user id]:WEBSITE_ID:[website ID]:SECRET:[secret]
```

The user ID must refer to a record in the `users` table, the website ID to a record in the
`websites` table and the secret is the password for the website. For more information, see the #
**Direct authentication** section below.

directWebsite
*************

This approach allows authentication anonymously in the context of a website registration by
providing a website ID and password, normally in the auth header:

```
WEBSITE_ID:[website ID]:SECRET:[secret]
```

The website ID is an ID for a record in the `websites` table and the secret is the password for the
website. For more information, see the **Direct authentication** section below.

hmacClient
**********

This approach is similar to directClient authentication but passes a HMAC token instead of the
secret so there is no need to exchange the secret. For more information, see the **HMAC
authentication** section below.

hmacWebsite
***********

This approach is similar to directWebsite authentication but passes a HMAC token instead of the
secret so there is no need to exchange the secret. For more information, see the **HMAC
authentication** section below.

Authentication method configuration
-----------------------------------

For each method described above, the configuration file can specify the following settings:

* `allow_cors`
* `allow_http` - the default behaviour is to only allow secure connections via https. Set
  `allow_http` to TRUE to override this, e.g. for a development environment.
* `resource_options`

JSON Web Token authentication
-----------------------------

JSON Web Token (JWT) authentication permits warehouse user accounts to access their own records.
JWT tokens can also be anonymous (if allowed in the REST API's configuration file) or can be used
to identify a client as a REST API client connection (configured in the warehouse user interface
via the Admin > REST API Clients menu item).

The generator of the token uses a private key to sign the contents of the token. The warehouse use
a public key to decrypt it. Each website supported by the warehouse can have its own public key
saved in the Public Key field of the website configuration.

Tokens must be in the Authorization header of each API request, prefixed by 'Bearer '. Tokens have
a limited life time and, once they expire, access to the warehouse will be blocked. E.g.

.. code::

  curl --location \
  --request GET '<WAREHOUSE URL>/index.php/services/rest/<ENDPOINT> \
  --header 'Authorization: Bearer <YOUR ACCESS TOKEN>'


The token consists of a header, payload and signature. On receipt, the payload
is base-64 decoded then JSON decoded. The resulting array must contain an
element with key, ``iss``, which can be either:

* the value of the url field of the website, as stored in the configuration for the website in the
  warehouse.
* for a jwtClient authorisation (i.e. when authorising as a particular client project rather than
  as a website or warehouse user) then the iss value must be the value of the url field of the
  website as above, followed by a colon, then the username given for the REST API client record.
  When using jwtClient authentication, the proj_id that identifies the client project which is
  connecting must be passed in the URL query string. One client system can therefore have several
  projects, each identified by a proj_id and each with its own set of permissions.

The `iss` claim then allows the warehouse to look up the relevant public key in order to verify the
signature.

The payload may also contain:

* ``email_verified``, boolean. If this is present and false then the request
  is blocked.
* ``http://indicia.org.uk/user:id``, an integer to identify the user. If set,
  the value of this element is used to confirm that user has a role for the given
  website. If so, the scope of the request is changed to ``userWithinWebsite``
  from the default of ``reporting``. The scope determines the extent of records in
  the response.
* ``scope``, a space-separated string or an array holding the scopes permitted
  to the user when making requests. Meaningful values are  ``userWithinWebsite``,
  ``user``, ``reporting``, ``verification``, ``data_flow``, ``moderation``,
  ``peer_review``, and ``editing``. When set, if the request contains a parameter,
  ``scope``, having a value matching one of those permitted then that scope is
  applied to the request.
* ``http://indicia.org.uk/scope``, a space-separated string or an array holding
  scope values which may be permittted when ``scope`` is not present in the
  payload.

.. tip::

  The `Drupal Indicia API module <https://github.com/Indicia-Team/drupal-8-module-indicia-api>`_
  can be installed on Drupal websites to generate tokens for JWT authentication.
  It depends on the `Simple OAuth module <https://www.drupal.org/project/simple_oauth>`_
  Set this up according to the instructions by providing a public/private key
  pair and configuring a Client with a secret. You can then send a POST request
  to the /oauth/token endpoint on the website to acquire a token, e.g.

  .. code::

    curl --location --request POST '<DRUPAL SITE URL>/oauth/token' \
    --header 'Content-Type: application/x-www-form-urlencoded' \
    --data-urlencode 'grant_type=password' \
    --data-urlencode ‘username=<YOUR EMAIL>' \
    --data-urlencode ‘password=<YOUR PASSWORD>' \
    --data-urlencode 'client_id=<THE CLIENT UUID>' \
    --data-urlencode 'client_secret=<THE CLIENT PASSWORD>'


HMAC authentication
-------------------

This approach to authentication relies on the client process using a shared
secret to build a hash value using the URL plus all the data values supplied in
the request. The hash (HMAC, or keyed-hash message authentication code) is
provided with the request but not the secret. The server side can then hash the
request's data with the secret (which it also knows) to generate the HMAC. If
they match then the request is authentic. Although not as widely recognised as
oAuth2, this approach does provide some protection when using http rather than
https since the secrets are never passed between the client and server. It also
has the advantage of being genuinely stateless and therefore RESTful.

In more detail:

#. The requesting entity creates a HMAC-SHA1 value of the complete request url
   (including parameters). The hash value uses the user password as the shared secret.
#. The requesting entity adds an Authorization header to the request containing the
   following string [user type]:[user identifier]:HMAC:[hmac] where:

     * [user_type] is one of WEBSITE_ID or USER, indicating whether the
       user_identifier is for a registered website, or client defined in the REST API's
       configuration file.
     * [user identifier] is the requesting client's identifier, either the website_id
       or client ID as described above.
     * [hmac] is the HMAC-SHA1 value computed in (1)

   Note that it is not possible to authenticate as a warehouse user account using HMAC. Instead,
   using JWT authentication is suggested when needing to authenticate as a specific warehouse user.
#. The receiving entity recomputes the HMAC-SHA1 in the same manner as (1) and any
   authorisation failure is returned as HTTP 401 Unauthorized.

This authentication should provide suitable protection against tampering and sufficient
level of authentication providing the shared secret is sufficiently long.

The following example PHP snippet illustrates the code required for authentication against
the REST API as a client described in the REST API's configuration file:

.. code-block:: php

  <?php
  $shared_secret = 'mypassword';
  $userId = 'ME';
  $url = 'http://www.example.com/rest/projects';
  $session = curl_init();
  // Set the POST options.
  curl_setopt ($session, CURLOPT_URL, $url);
  curl_setopt($session, CURLOPT_HEADER, false);
  curl_setopt($session, CURLOPT_RETURNTRANSFER, true);
  // Create the authentication HMAC
  $hmac = hash_hmac("sha1", $url, $shared_secret, $raw_output=FALSE);
  curl_setopt($session,
      CURLOPT_HTTPHEADER,
      array("Authorization: USER:$userId:HMAC:$hmac")
  );
  // Do the request
  $response = curl_exec($session);
  $httpCode = curl_getinfo($session, CURLINFO_HTTP_CODE);
  $curlErrno = curl_errno($session);
  // Check for an error, or check if the http response was not OK.
  if ($curlErrno || $httpCode != 200) {
    echo "Error occurred accessing $url<br/>";
    echo "Rest API Sync error $httpCode<br/>";
    if ($curlErrno) {
      echo 'Error number: '.$curlErrno;
      echo 'Error message: '.curl_error($session);
    }
    throw new exception('Request to server failed');
  }
  $data = json_decode($response, true);
  ?>

Direct authentication
---------------------

HMAC authentication never require's the user's secret or password to be passed
across the connection between the client and server so is inherently secure and
it does not require a secure connection (https) to ensure the authentication
details cannot be sniffed. When a secure connection is available over https, or
when developing code so security is not a concern, it can be simpler to pass
a password to the authentication process directly without calculating an HMAC.
Note that the default configuration of a warehouse is to disallow directly
passing a password or secret to the REST API authentication so this needs to be
changed in the REST API's configuration where appropriate. See
:doc:`../../administrating/warehouse/modules/rest-api` for more information.

When using direct authentication, the process is the same as for HMAC but you
set the password or client shared secret in the authentication string
as in the following example (using the token SECRET instead of HMAC)::

  USER_ID:[user id]:WEBSITE_ID:[website id]:SECRET:[user password]
