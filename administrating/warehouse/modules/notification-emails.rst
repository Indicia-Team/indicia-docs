Notification Emails Module
--------------------------

This optional module sends notifications as emails or digest emails according to the
settings in the `user_email_notification_settings` table for each user. Settings allow
the user to choose how frequently to send an email for each category of notification -
hourly, daily or weekly.

On staging servers where emails should not be sent, add a setting to
application/config/email.php as follows:

.. code-block:: php

  <?php

  $config['do_not_send'] = true;

  ?>

Enable the **Indicia notification emails** module from the Indicia Features repository to allow the
user to configure their notification settings from their Drupal user profile page.