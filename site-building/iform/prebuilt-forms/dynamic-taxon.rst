Enter a taxon (customisable)
============================

This form provides a configurable way to create an edit page for a taxon. The following
controls are available in its user interface:

User Interface
~~~~~~~~~~~~~~

The content of the generated page is entirely driven by the *User interface > Form
structure* configuration. Like other Indicia customisable page types, the *Form Structure*
is a text area in which you can place tokens which are replaced by controls when the page
is viewed. You can intersperse the control tokens with HTML to build a custom layout if
required.

Controls are represented by their name in square brackets and must be the only thing on
their line. They are followed by any number of parameters on the subsequent lines which
start with @, are followed by the property name then equals then the value. The list of
properties associated with a control stops as soon as something else is found which is not
A property definition. Property names and values are normally on one line but if a large
property value is required you can wrap the value in an XML comment (<!-- ... -->). For
example::

  [myControl]
  @myProperty=foo
  @myLongProperty=<!--
    bar
    baz
  -->

Controls availabe are as follows:

[taxon]
"""""""

An input for the accepted taxon name. Has the following common options:

* label - Override the control label.
* helpText - Override the control help text.

[language]
""""""""""

A drop down for selecting the language of the accepted name. Or, provide an option
@code=lat (or other ISO code for a supported language) to force the name to saved as a
particular language. Has the following common options:

* label - Override the control label.
* helpText - Override the control help text.

[attribute]
"""""""""""

An input for the taxon attribute (e.g. sensu lato). Has the following common options:

* label - Override the control label.
* helpText - Override the control help text.

[authority]
"""""""""""
A text input for the taxon name's authority information. Has the following common options:

* label - Override the control label.
* helpText - Override the control help text.

[common names]
""""""""""""""

A text area for inputting a list of common names into. Has the following common options:

* label - Override the control label.
* helpText - Override the control help text.

[synonyms]
""""""""""

A text area for inputting a list of synonyms. Has the following common options:

* label - Override the control label.
* helpText - Override the control help text.

[parent]
""""""""

A search box for choosing the taxon's parent. Alternatively the parent's ID can be forced
by providing a URL parameter parent_id containing the parent's taxa_taxon_list_id.

[taxon group]
"""""""""""""

A drop down for choosing the taxon group.

[taxon rank]
""""""""""""

A drop down for choosing the taxon rank.

[photos]
""""""""

An uploader for photos of the taxon. Has the following common options:

* resizeWidth - set the maximum width in pixels that images will be resized to before
  uploading to save bandwidth. Defaults to 1600.
* resizeHeight - set the maximum height in pixels that images will be resized to before
  uploading to save bandwidth. Defaults to 1600.

[description]
"""""""""""""

A text area for inputting a description which will be stored against the taxon.

[description in list]
"""""""""""""""""""""

A text area for inputting a description which will be stored against the taxon within the
context of this list.

[external key]
""""""""""""""

An input for an externally provided key where the taxon is derived from an external
source.

[search code]
"""""""""""""

An input for a taxon search code.

[sort order]
""""""""""""

An input for a taxonomic sort order numeric value.

[taxon dynamic attributes]
""""""""""""""""""""""""""

A placeholder where any dynamically linked attributes will be placed, e.g. attributes that
are associated with one of the taxon's parents.

[taxon associations]
""""""""""""""""""""

Provides a grid for adding, editing and deleting associations between taxa. Has the
following options:

* taxon_list_id - ID of the list that associated taxa can be looked up from. Required.
* association_type_id - termlist_term_id of the association type of associations in the
  grid if they are all the same.
* association_type_termlist_id - termlist_id of the termlists which the association type
  of each association in the grid can be chosen from. Either association_type_id or
  association_type_termlist_id must be specified.
* part_termlist_id - if specified then a column is added for selecting the part of the
  other taxon affected by this association.
* position_termlist_id - if specified then a column is added for selecting the position on
  the other taxon affected by this association.
* impact_termlist_id - if specified then a column is added for selecting the impact on the
  other taxon of this association.

[taxon designations]
""""""""""""""""""""

Provides a grid for adding, editing and deleting designations linked to the currently
edited taxon (conservation statuses). Designations need to be configured on the warehouse
first.

There are no options for this control.