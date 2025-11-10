<?php  // Moodle configuration file

unset($CFG);
global $CFG;
$CFG = new stdClass();

$CFG->dbtype    = getenv('MOODLE_DBTYPE');
$CFG->dblibrary = 'native';
$CFG->dbhost    = getenv('MOODLE_DB_HOST');
$CFG->dbname    = getenv('MOODLE_DB_NAME');
$CFG->dbuser    = getenv('MOODLE_DB_USER');
$CFG->dbpass    = getenv('MOODLE_DB_PASSWORD');
$CFG->prefix    = 'org_';
$CFG->dboptions = ['dbcollation' => 'utf8mb4_unicode_ci'];

if (empty($_SERVER['HTTP_HOST'])) {
    $_SERVER['HTTP_HOST'] = 'localhost';
}

$CFG->wwwroot   = getenv('MOODLE_APP_URL');
//'https://' . $_SERVER['HTTP_HOST'];
//$CFG->sslproxy = true;
// To avoid registration form.
$CFG->site_is_public = false;

$CFG->dataroot  = getenv('MOODLE_DOCKER_DATAROOT'); //'/var/www/moodledata';
$CFG->admin     = 'admin';
$CFG->directorypermissions = 0777;
$CFG->smtphosts = 'mailpit:1025';
$CFG->noreplyaddress = 'noreply@example.com';

// Debug options - possible to be controlled by flag in future..
$CFG->debug = (E_ALL); // DEBUG_DEVELOPER
$CFG->debugdisplay = 1;
$CFG->debugstringids = 1; // Add strings=1 to url to get string ids.
$CFG->perfdebug = 15;
$CFG->debugpageinfo = 1;
$CFG->allowthemechangeonurl = 1;
$CFG->passwordpolicy = 0;
$CFG->cronclionly = 0;
$CFG->pathtophp = '/usr/local/bin/php';

require_once(__DIR__ . '/lib/setup.php');
