indicia-docs
============

Documentation for Indicia online recording

Notes for authors
-----------------

### Links
You can link to any section of any page using
```
:ref:`path/to/page:section_title`
```
E.g. 
```
:ref:`developing/data-model/tables:websites`
```

### Custom CSS
You can add custom CSS in `_static\css\custom.css`. This is only intended for 
minor tweaks where the theme lets us down.

To add a CSS class to an element of content, use the directive
```
.. class:: your_class_name
```

Other directives allow you to add the option `:class:` followed by a space-
separated list of classes to apply.
