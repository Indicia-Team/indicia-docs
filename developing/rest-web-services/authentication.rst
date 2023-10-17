RESTful web service authentication
==================================

Indicia's web services provide support for a variety of different types of clients,
including:

  * Websites with online recording and reporting facilities.
  * Mobile applications.
  * Other databases which synchronise data with the Indicia instance.
  * Users of the data.
  * Developers working on site building or report writing.

In order to meet the needs of the different types of client, there are several
options for approaches to authentication.

  * A website or application might wish to authenticate as the registered website on the
    warehouse and will therefore gain access to all records contributed  via that website
    or shared with the website for reporting purposes.
  * A mobile application user might authenticate as that specific user/application
    combination to gain access to just their records.
  * A remote database which synchronises with the warehouse needs to identify itself in
    order for the warehouse to ensure the correct filtered set of records is made available
    to it.
  * A user of the data needs to identify the filtered set of data they have permission to
    view.
  * A developer will want to be able to simulate all these options without the
    authentication process hindering the simplicity of development.

Given the above requirements, Indicia provides 3 types of identification that
can be used when accessing the web services:

#. The warehouse has a list of website registrations in the websites table. This describes
   each of the online recording websites that contribute records to the warehouse.
   Authentication of web service requests can be achieved by providing a website_id and
   using the website's password as the secret for authentication. This gives the client
   access to the records belonging to the given website registration as well as any which
   are shared with the website via warehouse configuration.

   .. tip::

     Before giving a client the website_id and password for a website registration,  bear
     in mind this grants them full permissions to read and write that website's data which
     will not be appropriate in many cases. It also means you cannot disable that client's
     access without also disabling your website or application's access since they share
     the same authentication details. A better way is to create a "client"  for your data
     users in the configuration file as described below and create a project which enables
     them to access the website's records without a filter.

#. The warehouse also has a list of user accounts which can be used for
   authentication. Authentication of web service requests can be achieved by
   providing a user_id and website_id and using the user's warehouse password as
   the secret for authentication. This gives the client access to the user's
   records which they've contributed to the website identified by the given
   website_id. The user must of course be a member of the website. Optionally,
   provide a filter_id for a filter linked to the user which has
   defines_permissions=t (e.g. a filter granting verification rights) to give
   the client access to the filtered set of records.
#. The REST API has a list of clients in its configuration file which
   are being given access to the web services. Clients listed in the configuration file
   can be other systems (e.g. other online recording databases) or could equally be a user
   of the data. Provide the client ID and use the configured secret for authentication.
   Each client has a number of projects defined in the configuration which define filtered
   access to records for a given website, for example a project might be the Odonata
   records available to the iRecord website registration.

The following methods of authentication using these 3 categories of client user
are available for the REST API:


JSON Web Token
--------------------

JSON Web Token (JWT) authentication permits warehouse user accounts to
access their own records.

The generator of the tokens uses a private key to sign the contents of the
token. The warehouse use a public key to decrypt it. Each website supported by
the warehouse can have its own public key saved in the Public Key field of the website configuration.

Tokens must be in the Authorization header of each API request, prefixed by
'Bearer '. Tokens have a limited life time and, once they expire, access to the
warehouse will be blocked. E.g.

.. code::

  curl --location \
  --request GET '<WAREHOUSE URL>/index.php/services/rest/<ENDPOINT> \
  --header 'Authorization: Bearer <YOUR ACCESS TOKEN>'


The token consists of a header, payload and signature. On receipt, the payload
is base-64 decoded then JSON decoded. The resulting array must contain an
element with key, ``iss``, having the value of the url field of the website, as
stored in the configuration for the website in the warehouse. This allows the
relevant public key to be looked up in order to verify the signature.

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


HMAC
----

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
