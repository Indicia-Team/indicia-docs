Security Services API
---------------------

The Security Services API provides the following URLs, each accessed from the
warehouse's base URL, followed by ``index.php/services/`` then the method name
given.

security/get_nonce
^^^^^^^^^^^^^^^^^^

Requires a value for `website_id` in the POST data. Returns a write nonce token.
The nonce token is stored in the cache along with the website_id so that in
future the one-time usage of the token can be checked.

security/get_read_nonce
^^^^^^^^^^^^^^^^^^^^^^^

Requires a value for `website_id` in the POST data. Returns a read nonce token.
The nonce token is stored in the cache along with the website_id so that in
future the usage of the token can be checked. Note that the token is not
technically a nonce, since it has time based rather than usage based expiry;
a read nonce can therefore be used for multiple reads required to populate a
single form.

security/get_read_write_nonces
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Requires a value for `website_id` in the POST data. Returns a JSON object with
properties `read` and `write` corresponding to the read and write nonce tokens
respectively. The tokens are cached as described for the ``get_read_nonce`` and
``get_nonce`` methods.

user_identifier/get_user_id
^^^^^^^^^^^^^^^^^^^^^^^^^^^

A service method designed to allow a user to have a single identity on the
warehouse even if they are logging in on several client websites. This allows
features like lists of "My Records" to work across the boundaries between client
websites. The client website provides a list of the known "user identifiers"
which include email addresses, as well as Twitter IDs or other social networking
"handles". The warehouse then uses the identifiers to see if this user is
already listed in the warehouse's ``users`` table. If not, then an entry for
the user is created and either way, the user ID is returned to the caller. This
method also allows for synchronisation of custom attributes about the person
across sites, for example the taxonomic interests could be entered once and
used across several sites. Please ensure you comply with data protection laws
if using this facility.

This method requires the following parameters in either the GET or POST data:

* **nonce** - a write authorisation nonce
* **auth_token** - a write authorisation token
* **identifiers** - Required. A JSON encoded array of identifiers known for the
  user. Each array entry is an object with a type property (e.g. twitter,
  openid) and identifier property (e.g. twitter account). An identifier of type
  email must always be provided in case a new user account has to be created on
  the warehouse.
* **surname** - Required. Surname of the user, enabling a new user account to be
  created on the warehouse.
* **first_name** - Optional. First name of the user, enabling a new user account
  to be created on the warehouse.
* **force** - Optional. Only relevant after a request has returned an array of
  several possible matches. Set to **merge** or **split** to define the outcome.
* **users_to_merge** - If force=merge, then this parameter can be optionally used to
  limit the list of users in the merge operation. Pass a JSON encoded array of
  user IDs.
* **attribute_values** - Optional list of custom attribute values for the person
  which have been modified on the client website and should be synchronised into
  the warehouse person record. The custom attributes must already exist on the
  warehouse and have a matching caption, as well as being marked as
  synchronisable or the attribute values will be ignored. Provide this as a JSON
  object with the properties being the caption of the attribute and the values
  being the values to change.

The returned data from this web service is a JSON object containing the
following properties:

* **userId** - If a single user account has been identified then returns the
  Indicia user ID for the existing or newly created account. Otherwise not returned.
* **attrs** - If a single user account has been identifed then returns a list of
  captions and values for the attributes to update on the client account.
* **possibleMatches** - If a list of possible users has been identified then
  this property includes a list of people that match from the warehouse - each
  with the user ID, website ID and website title they are members of. If this
  happens then the client must ask the user to confirm that they are the same
  person as the users of this website and if so, the response is sent back with
  a force=merge parameter to force the merge of the people. If they are the same
  person as only some of the other users, then use users_to_merge to supply an
  array of the user IDs that should be merged. Alternatively, if force=split is
  passed through then the best fit user ID is returned and no merge operation
  occurs.
* error - Error string if an error occurred.
