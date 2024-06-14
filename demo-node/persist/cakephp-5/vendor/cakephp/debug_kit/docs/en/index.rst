Debug Kit
#########

DebugKit provides a debugging toolbar and enhanced debugging tools for CakePHP
applications. It lets you quickly see configuration data, log messages, SQL
queries, and timing data for your application.

.. warning::

    DebugKit is only intended for use in single-user local development
    environments. You should avoid using DebugKit in shared development
    environments, staging environments, or any environment where you need to
    keep configuration data and environment variables hidden.

Installation
============

By default DebugKit is installed with the default application skeleton. If
you've removed it and want to re-install it, you can do so by running the
following from your application's ROOT directory (where composer.json file is
located)::

    php composer.phar require --dev cakephp/debug_kit "~5.0"

Then, you need to enable the plugin by executing the following line::

    bin/cake plugin load DebugKit

Configuration
=============

* ``DebugKit.panels`` - Enable or disable panels for DebugKit. You can disable any of the
  standard panels by::

    // Before loading DebugKit
    Configure::write('DebugKit.panels', ['DebugKit.Packages' => false]);

* ``DebugKit.includeSchemaReflection`` - Set to true to enable logging of schema
  reflection queries. Disabled by default.

* ``DebugKit.safeTld`` - Set an array of whitelisted TLDs for local development.
  This can be used to make sure DebugKit displays on hosts it otherwise determines unsafe. ::

    // Allow e.g. http://foo.bar.dev or http://my-shop.local domains locally
    Configure::write('DebugKit.safeTld', ['dev', 'local', 'example']);

* ``DebugKit.forceEnable`` - Force DebugKit to display. Careful with this, it is usually
  safer to simply whitelist your local TLDs. Example usage::

    // Before loading DebugKit
    Configure::write('DebugKit.forceEnable', true);

  You can also provide a callable::

    Configure::write('DebugKit.forceEnable', function() {
        return $_SERVER['REMOTE_ADDR'] === '192.168.2.182';
    });

* ``DebugKit.ignorePathsPattern`` - Regex pattern (including delimiter) to ignore paths.
  DebugKit won't save data for request URLs that match this regex. Defaults to ``null``::

    // Ignore image paths
    Configure::write('DebugKit.ignorePathsPattern', '/\.(jpg|png|gif)$/');

* ``DebugKit.ignoreAuthorization`` - Set to true to ignore Cake Authorization plugin for DebugKit requests. Disabled by default.

* ``DebugKit.maxDepth`` - Defines how many levels of nested data should be shown in general for debug output. Default is 5.
  WARNING: Increasing the max depth level can lead to an out of memory error.::

    // Show more levels
    Configure::write('DebugKit.maxDepth', 8);

* ``DebugKit.variablesPanelMaxDepth`` - Defines how many levels of nested data should be shown in the variables tab. Default is 5.
  WARNING: Increasing the max depth level can lead to an out of memory error.::

    // Show more levels
    Configure::write('DebugKit.variablesPanelMaxDepth', 8);

Database Configuration
----------------------

By default DebugKit will store panel data into a SQLite database in your
application's ``tmp`` directory. If you cannot install pdo_sqlite, you can
configure DebugKit to use a different database by defining a ``debug_kit``
connection in the ``Datasources`` variable in your **config/app.php** file. For example::

    /**
     * The debug_kit connection stores DebugKit meta-data.
     */
    'debug_kit' => [
        'className' => 'Cake\Database\Connection',
        'driver' => 'Cake\Database\Driver\Mysql',
        'persistent' => false,
        'host' => 'localhost',
        //'port' => 'nonstandard_port_number',
        'username' => 'dbusername',    // Your DB username here
        'password' => 'dbpassword',    // Your DB password here
        'database' => 'debug_kit',
        'encoding' => 'utf8',
        'timezone' => 'UTC',
        'cacheMetadata' => true,
        'quoteIdentifiers' => false,
        //'init' => ['SET GLOBAL innodb_stats_on_metadata = 0'],
    ],

You can safely remove the **tmp/debug_kit.sqlite** file at any point.
DebugKit will regenerate it when necessary.

Toolbar Usage
=============

The DebugKit Toolbar is comprised of several panels, which are shown by clicking
the CakePHP icon in the bottom right-hand corner of your browser after DebugKit
has been installed and loaded. Each panel is comprised of a panel class and view
element. Typically, a panel handles the collection and display of a single type
of information such as Logs or Request information. You can choose to view panels
from the toolbar or add your own custom panels.

Each panel lets you look at a different aspect of your application:

* **Cache** See cache usage during a request and clear caches.
* **Environment** Display environment variables related to PHP + CakePHP.
* **History** Displays a list of previous requests, and allows you to load
  and view toolbar data from previous requests.
* **Include** View the included files grouped by type.
* **Log** Display any entries made to the log files this request.
* **Packages** Display the list of packages dependencies with their actual
  version and allow you to check for outdated packages.
* **Mail** Display all emails sent during the request and allow to preview
  emails during development without sending them.
* **Request** Displays information about the current request, GET, POST, Cake
  Parameters, Current Route information and Cookies.
* **Session** Display the information currently in the Session.
* **Sql Logs** Displays SQL logs for each database connection.
* **Timer** Display any timers that were set during the request with
  ``DebugKit\DebugTimer``, and memory usage collected with
  ``DebugKit\DebugMemory``.
* **Variables** Display View variables set in controller.
* **Deprecations** Display deprecation warnings in a more readable and less
  disruptive format.

Using the History Panel
=======================

The history panel is one of the most frequently misunderstood features of
DebugKit. It provides a way to view toolbar data from previous requests,
including errors and redirects.

.. figure:: ../_static/history-panel.png
    :alt: Screenshot of the history panel in debug kit.

As you can see, the panel contains a list of requests. On the left you can see
a dot marking the active request. Clicking any request data will load the panel
data for that request. When historical data is loaded the panel titles will
transition to indicate that alternative data has been loaded.

.. only:: html or epub

    .. video:: ../_static/history-panel-use.mp4
        :alt: Video of history panel in action.

Using The Mail Panel
====================

The mail panel allow you to track all emails sent during a request.

.. only:: html or epub

    .. video:: ../_static/mail-panel.mp4
        :alt: Video of Mail panel in action.

The mailer preview allows you to easily check emails during development.

.. only:: html or epub

    .. video:: ../_static/mail-previewer.mp4
        :alt: Video of Mail panel in action.

Creating Preview Classes
------------------------

In order to preview emails before sending them, you need to create a preview
class that defines the receipient and required template variables for your
mailer methods::

    // in src/Mailer/Preview/WelcomePreview.php
    namespace App\Mailer\Preview;

    use DebugKit\Mailer\MailPreview;

    class WelcomePreview extends MailPreview
    {
        public function welcome()
        {
            $mailer = $this->getMailer('Welcome');
            // set any template variables receipients for the mailer.

            return $mailer;
        }
    }

MailPreview classes should live in the ``Mailer\Preview`` namespace of your
application or plugin, and use the ``Preview`` class suffix.

Developing Your Own Panels
==========================

You can create your own custom panels for DebugKit to help in debugging your
applications.

Creating a Panel Class
----------------------

Panel Classes simply need to be placed in the **src/Panel** directory. The
filename should match the classname, so the class ``MyCustomPanel`` would be
expected to have a filename of **src/Panel/MyCustomPanel.php**::

    namespace App\Panel;

    use DebugKit\DebugPanel;

    /**
     * My Custom Panel
     */
    class MyCustomPanel extends DebugPanel
    {
        ...
    }

Notice that custom panels are required to extend the ``DebugPanel`` class.

Callbacks
---------

By default Panel objects have two callbacks, allowing them to hook into the
current request. Panels subscribe to the ``Controller.initialize`` and
``Controller.shutdown`` events. If your panel needs to subscribe to additional
events, you can use the ``implementedEvents()`` method to define all of the events
your panel is interested in.

You should refer to the built-in panels for some examples on how you can build
panels.

Panel Elements
--------------

Each Panel is expected to have a view element that renders the content from the
panel. The element name must be the underscored inflection of the class name.
For example ``SessionPanel`` has an element named **session_panel.ctp**, and
SqllogPanel has an element named **sqllog_panel.ctp**. These elements should be
located in the root of your **src/Template/Element** directory.

Custom Titles and Elements
--------------------------

Panels should pick up their title and element name by convention. However, if
you need to choose a custom element name or title, you can define methods to
customize your panel's behavior:

- ``title()`` - Configure the title that is displayed in the toolbar.
- ``elementName()`` - Configure which element should be used for a given panel.

Panel Hook Methods
------------------

You can also implement the following hook methods to customize how your panel
behaves and appears:

* ``shutdown(Event $event)`` This method typically collects and prepares the
  data for the panel. Data is generally stored in ``$this->_data``.
* ``summary()`` Can return a string of summary data to be displayed in the
  toolbar even when a panel is collapsed. Often this is a counter, or short
  summary information.
* ``data()`` Returns the panel's data to be used as element context. This hook
  method lets you further manipulate the data collected in the ``shutdown()``
  method. This method **must** return data that can be serialized.

Panels in Other Plugins
-----------------------

Panels provided by `plugins <https://book.cakephp.org/3.0/en/plugins.html>`_ work
almost entirely the same as other plugins, with one minor difference:  You must
set ``public $plugin`` to be the name of the plugin directory, so that the
panel's Elements can be located at render time::

    namespace MyPlugin\Panel;

    use DebugKit\DebugPanel;

    class MyCustomPanel extends DebugPanel
    {
        public $plugin = 'MyPlugin';
            ...
    }

To use a plugin or app panel, update your application's DebugKit configuration
to include the panel::

    // in src/Application.php bootstrap() method add
    Configure::write('DebugKit.panels', ['App', 'MyPlugin.MyCustom']);
    $this->addPlugin('DebugKit', ['bootstrap' => true]);

The above would load all the default panels as well as the ``AppPanel``, and
``MyCustomPanel`` panel from ``MyPlugin``.

Accessing Toolbar without a frontend
====================================

If you have an application which only provides an API (and therefore no frontend)
the usual way of accessing the toolbar can't be used.

Instead you have to call http://localhost/debug-kit/toolbar/``<debugkit-id>``

The ``<debugkit-id>`` can be found inside the HTTP headers of your API response. It should look something like that::

    X-DEBUGKIT-ID: 5ef39604-ad5d-4ca4-85d8-8595e52373bb

So you would have to call http://localhost/debug-kit/toolbar/5ef39604-ad5d-4ca4-85d8-8595e52373bb

Helper Functions
================

* ``sql()`` Dumps out the SQL from an ORM query.
* ``sqld()`` Dumps out the SQL from an ORM query, and exits.

Tracing query execution
=======================

Sometimes you need to know where specific queries are being executed in your app.
To get this kind of information you can add the ``SqlTraceTrait`` to your Table class like so::

    use DebugKit\Model\Table\SqlTraceTrait;

    class CategoriesTable extends Table
    {
        use SqlTraceTrait;
    }

This will add the following information to the SQL log::

    /* APP/Controller/CategoriesController.php (line 20) */
