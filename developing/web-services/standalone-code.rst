Web Services Code Illustration
==============================

The following code provides a thoroughly commented standalone demonstration of how to use
the Indicia web services to read and write data, with no dependencies on the Client
Helpers API. As such it is useful for anyone wanting to avoid the overhead of the Client
Helpers API or wishing to port the code to other development languages.

.. code:: php

  <html>
  <head>
    <title>Indicia Web Services demonstration</title>
  </head>
  <body>
  <?php

  /**
   * This PHP file is designed to provide a basic illustration of the code required to read
   * information from and write to the Indicia web services without using the Client Helpers
   * API. It could be used as the basis of a port to other languages, or for as the starting
   * point for PHP developments using Indicia where you don't want the overhead of the entire
   * Client Helpers API.
   *
   * The file is in 2 parts. At the top there is example code which demonstrates reading a
   * record from the database, writing a wildlife record back to the database and also
   * accessing data via a report. This code is dependent on a small class provided in the
   * second half of the file which exposes public functions used to interact with the Indicia
   * web services. You can copy this class into your own developments if needs be, though
   * note that it contains hard coded references to the BRC test warehouse which would need
   * to be changed for any real usage.
   */

  /*******************************************************************************
   * Start of example code
   ******************************************************************************/

  /*
  Create an instance of the helper class that will interact with Indicia web services.
  */
  $indiciaWs = new indiciaWs();

  /*
   * Before we can actually post a record, we need to know the ID of the species we want to record. You might either
   * use a lookup control on your form which itself integrates with the data services, or you could have a static
   * list of species in something like an HTML <select> control, in which case you can use a fixed list of IDs.
   * In our case we'll use a web-services call to ask Indicia for the ID of a particular species first. The species
   * data available in the warehouse are organised into a number of lists; we will use list ID 34 which contains a
   * partial import of the UKSI complete list. As this is a partial list copy, not all the species names you might
   * want to look up will be present - this is just a test scenario though.
   */
  $species = $indiciaWs->getData(array(
    'table' => 'cache_taxa_taxon_list',
    'params' => array(
      'taxon_list_id' => 34,
      'taxon' => 'Achillea tomentosa',
      'preferred' => 't' // use the preferred entry for this species
    )
  ));
  echo '<h1>Reading a species to get the ID required in the post</h1>';
  echo '<pre>'.print_r($species, true).'</pre>';

  /*
  We are now going to post a very simple submission to the web services. This will be a sample containing a single
  occurrence record. Typically, the array you are sending to the postSubmission method here might come directly
  from a web form's $_POST data, though you need to ensure that you are mapping to the correct field names for it
  to work.

  Information that is posted into the sample table refers to the event in which the sightings were observed, in other
  words it describes the place, date, people, environmental conditions etc. Within a sample, you can post zero or
  more occurrences which refer to each species sighted as part of the sample.

  When posting a sample, you must prefix the field name with 'sample:' in your array of field/value pairs. Some of the
  fields you can post for a sample are:
  sample:id - Set to an ID of an existing sample if updating. For a new sample, omit this from the array.
  sample:survey_id - Mandatory. This is the ID of the survey dataset you are posting into on the warehouse. In
  our case we are using survey 1 on the testwarehouse. See http://indicia-docs.readthedocs.org/en/latest/site-building/warehouse/surveys.html?highlight=survey
  for more info.
  sample:entered_sref - Mandatory. A formatted British National Grid reference, Irish Grid reference, or decimal lat
  long (WGS84) such as 52.4N, 1.4E.
  sample:entered_sref_system - Mandatory. Either OSGB for British National Grid, OSIE for Irish Grid or 4326 for
  decimal lat long. Note that 4326 is the official EPSG code for the WGS84 lat long projection.
  sample:date - Mandatory. Either ISO format (yyyy-mm-dd) or dd/mm/yyyy.
  sample:location_name - Optional. A free text name of the site.
  sample:comment - Optional. A free text comment.

  Your form array can also contain occurrences. Since you can store multiple occurrences in the flattened form array,
  the structure for an occurrence field name in your array must be occurrence:uniqueId:fieldname. It doesn't matter
  what you use for the uniqueId but it must be the same for all the fields in the same occurrence record. You might,
  for example, use 1 for the first and 2 for the second occurrence etc. Some of the fields you can post for an occurrence
  are:
  occurrence:uniqueID:id
  occurrence:uniqueID:taxa_taxon_list_id
  occurrence:uniqueID:comment
  occurrence:uniqueID:training
  occurrence:uniqueID:zero_abundance
  occurrence:uniqueID:sensitivity_precision

  As well as these "core" fields, you can add custom attributes to your survey dataset, at either the sample level
  or the record level. For example you might create a custom attribute to store a habitat field value against
  each sample, or an abundance against each record. More information at:
  :doc:`../../site-building/warehouse/custom-attributes.html`.
  Once you have set up your custom attributes, you will know the ID allocated to each attribute in the warehouse.
  You can then add a sample custom attribute value to your submission by sending a value for smpAttr:attrId, replacing the
  attrId with your attribute's ID. You can also submit an occurrence custom attribute value by submitting a field
  called occAttr:uniqueId:attrId, replacing uniqueId with the unique ID for your occurrence as described above and
  replacing the attrId with your attribute's ID on the warehouse.

  A final note about custom attributes - if you are resubmitting a record to update it then you will need to know the
  ID of any existing custom attribute value records (e.g. the ID of the record in sample_attribute_values or
  occurrence_attribute_values). Just to be clear - a sample custom attribute has a records in the sample_attributes table
  which describe metadata about each attribute, for example the caption, data type and validation rules for the
  attribute. Then when you save a record which includes a value for that custom attribute, a record is created in the
  sample_attribute_values table which describes the actual value being stored. Therefore this database record has an attribute
  value ID to uniquely identify it, represented by attrValId in the following fieldname construct:
  smpAttr:attrId:attrValId
  */

  /*
   * Our first post example posts a new record, consisting of a sample containing 1 occurrence. We use the
   * Weather sample custom attribute (ID 1) to store a weather value and the Abundance occurrence custom
   * attribute (ID 145) to store an abundance value.
   */
  $response = $indiciaWs->postSubmission(array(
    'sample:survey_id' => 1,
    'sample:entered_sref' => 'SU12345678',
    'sample:entered_sref_system' => 'OSGB',
    'sample:date' => '01/03/2013',
    'smpAttr:1' => 'Sunny',
    'occurrence:1:taxa_taxon_list_id' => 63114, // this value came from the getData call above
    'occAttr:1:145' => '5'
  ));
  echo '<h1>Submitting a new record</h1>';
  // grab out the posted sample's ID so we can load it back later
  $responseArr=json_decode($response, true);
  $sampleId = $responseArr['outer_id'];
  echo '<pre>'.print_r($responseArr, true).'</pre>';

  /*
   * Our second example posts an update to an existing record. We need to know the sample ID, occurrence ID,
   * plus any attribute value IDs in order to be able to overwrite them. The response from the above postSubmission
   * call contains these values in the returned structure - the values below come from a submission created during
   * the writing of this script.
   */
  $response = $indiciaWs->postSubmission(array(
    'sample:survey_id' => 1,
    'sample:id' => 127152,
    'sample:entered_sref' => 'SU12345678',
    'sample:date' => '01/03/2013',
    'smpAttr:1:37480' => 'Sunny',
    'occurrence:1:id' => 137085,
    'occurrence:1:taxa_taxon_list_id' => 63114, // this value came from the getData call above
    'occAttr:1:145:36538' => '5'
  ));
  echo '<h1>Submitting an update to an existing record</h1>';
  echo '<pre>'.print_r(json_decode($response, true), true).'</pre>';

  /*
   * Our third example shows what happens when we post a submission and there is a validation failure,
   * in this case because the mandatory date value was ommitted from the submission. When writing your
   * own code it would be preferable to perform basic validation on the client-side before submitting to
   * the warehouse though, as any communication with the warehouse will incur a slight delay.
   * Information on error responses is at
   * http://indicia-docs.readthedocs.org/en/latest/developing/web-services/data-services-errors.html
   */
  $response = $indiciaWs->postSubmission(array(
    'sample:survey_id' => 1,
    'sample:entered_sref' => 'SU12345678',
    'sample:entered_sref_system' => 'OSGB',
    'smpAttr:1' => 'Sunny',
    'occurrence:1:taxa_taxon_list_id' => 34023,
    'occAttr:1:145' => '5'
  ));
  echo '<h1>Submitting an incomplete record</h1>';
  echo '<pre>'.print_r(json_decode($response, true), true).'</pre>';

  /*
   * In the interests of completing the round trip, this example illustrates using the report services
   * to get our new record back out again. Rather than filtering on sample_id, we could filter on survey_id
   * to get the entire dataset for example. Reports are similar to direct table accesses except that a
   * custom report query with its own parameters handling behaviour can be defined on the server by a report file.
   */
  $response = $indiciaWs->getReport(array(
    'report' => 'library/occurrences/filterable_explore_list',
    'params' => array(
      'sample_id'=>$sampleId,
      'smpattrs'=>'1',
      'occattrs'=>'145'
    )
  ));
  echo '<h1>Submitting an incomplete record</h1>';
  echo '<pre>'.print_r($response, true).'</pre>';

  /*******************************************************************************
   * End of example code
   ******************************************************************************/

  /**
   * The class below exposes several public methods for reading from database tables
   * or reports as well as posting records into the Indicia warehouse.
   *
   * It contains configuration in the variables declared at the top of the class if
   * you want to use it for linking to a different warehouse or survey dataset. Note
   * that this is intended to illustrate the minimal steps required if building your
   * own code to interact with an Indicia warehouse. It is not intended to replace the
   * web services code provided in the Client Helpers API in most cases.
   */

  class indiciaWS {
    // use the test warehouse at BRC
    public $warehouseUrl='http://testwarehouse.indicia.org.uk';
    // demonstration website registration
    public $websiteID=1;
    // use the test website's password - when posting to a real survey this will be a secure password for just your website registration.
    public $websitePassword='password';

    /**
     * Retrieve database records from the Indicia warehouse.
     *
     * @param array $options Provide the following entries in the options array:
     * * table - the singular name of the database table to read from.
     * * params - array of field/value pairs to provide as a filter to the data services request.
     *   E.g. specify a record ID to load.
     * @return array Array of records, with each record being defined by an associative array of field values.
     * @throws exception If table parameter not provided.
     */
    public function getData($options) {
      if (!isset($options['table']))
        throw new exception('Please supply the singular name of the table you want to read data from in the options array');
      $request = $this->warehouseUrl."/index.php/services/data/$options[table]";
      return $this->get($request, $options);
    }

    /**
     * Retrieves report output data from the Indicia warehouse.
     *
     * @param array $options Provide the following entries in the options array:
     * * report - the path to the report file on the warehouse. See the link below.
     * * params - array of field/value pairs to provide as a parameter to the report services request.
     * @return array Array of records, with each record being defined by an associative array of field values.
     * @throws exception If report parameter not provided.
     * @link http://code.google.com/p/indicia/source/browse/#svn%2Fcore%2Ftrunk%2Freports List of report files in the code repository.
     */
    public function getReport($options) {
      if (!isset($options['report']))
        throw new exception('Please supply the singular name of the report you want to read data from in the options array');
      $request = $this->warehouseUrl."/index.php/services/report/requestReport";
      // The report should be an xml file on the server, so add an extension if missing
      if (substr($options['report'], -4) !== '.xml')
        $options['report'] .= '.xml';
      // Move the report setting into the params so that it gets added to the URL query string.
      // Also tell the warehouse to use an existing report from its local reports folder.
      $options['params'] = array_merge(array(
        'report' => $options['report'],
        'reportSource' => 'local'
      ), $options['params']);
      return $this->get($request, $options);
    }

    /**
     * Posts a form save array to the warehouse. Descriptions of the structure of this array
     * are given in the comments at the top of this example file.
     *
     * @param array $arr Form save array
     * @return array Reponse from the data services. May contain the structure of the saved data
     * or an error.
     */
    public function postSubmission($arr) {
      // In a production environment, you are unlikely to do multiple posts from one page hit. Note that you can (and should)
      // do multiple read requests with 1 set of read authorisation tokens, to save multiple round trips to get new tokens
      // from the warehouse.
      $auth = $this->getAuth();
      // The following call converts a set of form array values into the structure required by the Indicia warehouse.
      $submission = $this->buildSubmission($arr);
      $postargs = 'submission='.urlencode(json_encode($submission));
      // Attach the required authorisation details.
      $postargs .= "&auth_token={$auth['write']['auth_token']}";
      $postargs .= "&nonce={$auth['write']['nonce']}";
      // Post the information to the services/data/save endpoint.
      return $this->http_post($this->warehouseUrl.'/index.php/services/data/save', $postargs);

    }

    /**
     * A generic internal method for sending a request to the data or report services.
     *
     * @param string $request The URL to request data from
     * @param array $options If this contains a params entry, then this is added to the URL as a query string.
     * @return array List of records returned by the request.
     */
    private function get($request, $options) {
      $auth = $this->getAuth();
      if (!isset($options['params']))
        $options['params']=array();
      $options['params'] = array_merge(array(
        'mode'=>'json',
        'auth_token'=>$auth['read']['auth_token'],
        'nonce'=>$auth['read']['nonce']
      ), $options['params']);

      $request .= '?' . http_build_query($options['params']);
      return json_decode($this->http_post($request), true);
    }

    /**
     * Internal method to convert a flat form save array into the submission structure
     * required by the warehouse as described in the link below.
     *
     * @param array $arr Form save array
     * @return array Submission structure array required by the warehouse.
     * @throws exception
     * @link http://indicia-docs.readthedocs.org/en/latest/developing/web-services/submission-format.html
     */
    private function buildSubmission($arr) {
      $sample=array();
      $occurrences=array();
      foreach ($arr as $key=>$value) {
        // split the fieldnames up by colons. We want to only split to a max 3 tokens, as if there are
        // 4 then it must be for an existing occurrence custom attribute. In this case, the last 2 tokens
        // can be kept together (they are the attribute ID and the attribute value ID respectively).
        $tokens = explode(':', $key, 3);
        if ($tokens[0]==='sample')
          // a core sample field value
          $sample[$tokens[1]]=array('value'=>$value);
        elseif ($tokens[0]==='smpAttr')
          // a custom attribute field value for the sample
          $sample[$key]=array('value'=>$value);
        elseif ($tokens[0]==='occurrence' || $tokens[0]==='occAttr') {
          // a core occurrence or custom occurrence attribute field value
          if (count($tokens)<>3)
            throw new exception('Form array should have 3 parts to a field for the occurrence table');
          if (!isset($occurrences[$tokens[1]]))
            // This is the first field found for a given record
            $occurrences[$tokens[1]]=array();
          if ($tokens[0]==='occurrence')
            $occurrences[$tokens[1]][$tokens[2]]=array('value'=>$value);
          else
            $occurrences[$tokens[1]]["occAttr:$tokens[2]"]=array('value'=>$value);
        }
      }
      // build the submission required for the sample
      $submission = array(
        'id' => 'sample',
        'fields' => $sample
      );
      // attach the records
      if (count($occurrences)) {
        $submission['subModels']=array();
        foreach ($occurrences as $key=>$occurrence) {
          $occurrence['website_id']="$this->websiteID";
          if (preg_match('/^id=(\d+)$/', $key, $matches)) {
            $occurrence['id']=$matches[1];
          }
          $submission['subModels'][] = array(
            'fkId'=>'sample_id',
            'model'=>array(
              'id'=>'occurrence',
              'fields'=>$occurrence
            )
          );
        }
      }

      return $submission;
    }

    /**
     * Internal method to retrieve the read and write authorisation tokens required for communication with
     * the warehouse.
     *
     * @return array Read and write tokens array.
     */
    private function getAuth() {
      $postargs = "website_id=".$this->websiteID;
      $response = self::http_post($this->warehouseUrl.'/index.php/services/security/get_read_write_nonces', $postargs);
      $nonces = json_decode($response, true);
      return array(
        'read'=>array(
          'auth_token' => sha1("$nonces[read]:".$this->websitePassword),
          'nonce' => $nonces['read']
        ),
        'write'=>array(
          'auth_token' => sha1("$nonces[write]:".$this->websitePassword),
          'nonce' => $nonces['write']
        )
      );
    }

    /**
     * Internal method which posts data to a specified URL.
     *
     * @param string $url Web services URL to post data to
     * @param string $postargs Query string to include in the post.
     * @return string Response from the warehouse
     * @throws exception Exception thrown when an error occurs.
     */
    private function http_post($url, $postargs=null) {
      $session = curl_init();
      // Set the POST options.
      curl_setopt ($session, CURLOPT_URL, $url);
      if ($postargs!==null) {
        curl_setopt ($session, CURLOPT_POST, true);
        curl_setopt ($session, CURLOPT_POSTFIELDS, $postargs);
      }
      curl_setopt($session, CURLOPT_HEADER, false);
      curl_setopt($session, CURLOPT_RETURNTRANSFER, true);
      // Do the POST
      $response = curl_exec($session);
      $httpCode = curl_getinfo($session, CURLINFO_HTTP_CODE);
      // Check for an error, or check if the http response was not OK.
      if (curl_errno($session) || $httpCode!==200) {
        if (curl_errno($session))
          throw new exception(curl_errno($session) . ' - ' . curl_error($session));
        else {
          throw new exception($httpCode . ' - ' . $response);
        }
      }
      curl_close($session);
      return $response;
    }
  }

  ?>
  </body>
  </html>