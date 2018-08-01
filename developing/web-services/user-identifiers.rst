User Identifiers
================

The User Identifier Services provide a way for client websites to get a unique
identifier (a warehouse User ID) for any user of the website. Because this
identifier is associated with the user's external identifiers, such as Twitter
accounts or Open IDs, one user logging into several client websites linked to
the same warehouse can end up with just 1 warehouse user ID. This makes it
simple to identify a user's records globally for reporting and other purposes.

How it works
------------

Each client website has one or more identifiers for the users that log in. This
must at least include an email address, but any additional types of identifiers
such as twitter, facebook or OpenID URLs can also be used. The client website
should also store the surname and preferably the user's firstname in the user
account profile. When the user logs in to the client website or their user
account profile is updated, the client website should send a request to the
User Identifier Services to retrieve a warehouse User ID for the user. This
request should include a list of all the user's known identifiers as well as the
user's surname and firstname if available. It can optionally include any
additional attributes about the user that the client website would like to
synchronise with the warehouse, for example the user's interests from their user
profile. The Easy Login module feature includes support for all the
required client-side functionality.

The warehouse uses the supplied identifier list to look for a user that has at
least some overlap with the identifiers supplied. If found, then the user ID is
returned. If not, then the surname and first name are used to create a new
warehouse person and user. The user is always added to the list of known users
on the warehouse for the website which made the call, whether existing or new.
The list of identifiers are stored on the warehouse for future use. The warehouse
also updates any synchronised attributes and returns updated attribute values
that should be saved into the client website user profile.

If a situation arises where 2 apparently different users exist on a warehouse,
then a request for a user ID is received which has a list of identifiers which
overlaps the 2 users, then it is likely that these users are all the same
person. The resolution of this is not automated as it would be too prone to
error, though tools to assist resolution will be provided on the warehouse. The
"best fit" user ID is returned, based on an exact name match first, then the
number of identifiers which overlap.

Details of the User Identifiers support in the web services API is provided at
:doc:`security-services-details/security-services-api`.