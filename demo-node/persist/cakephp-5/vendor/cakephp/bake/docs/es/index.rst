Consola bake
############

La consola bake de CakePHP es otro esfuerzo para preparar y ejecutar CakePHP rápidamente.

La consola bake puede crear cualquiera de los ingredientes básicos de CakePHP:
modelos, behaviours, vistas, helpers, controladores, componentes, casos de
prueba, fixtures y plugins.

Y no hablamos sólo de esqueletos de clases: Bake puede crear una aplicación
totalmente funcional en solo un par de minutos.

De hecho, Bake es un paso natural a dar una vez ha sido creado el esqueleto de
la aplicación.

Instalación
===========

Antes de intentar utilizar o extender bake asegúrate de que está instalado en tu
aplicación.

Bake está incluido como un plugin que puedes instalar con Composer::

    composer require --dev cakephp/bake:~1.0

La instrucción anterior instalará bake como una dependencia de desarrollo. Esto
significa que no será instalado cuando hagas despliegues en producción.

.. meta::
    :title lang=es: Consola Bake
    :keywords lang=es: interfaz de línea de comando,desarrollo,bake vista, bake sintaxis plantilla,erb tags,asp tags,percent tags
