Génération de Code avec Bake
############################

La console Bake est exécutée en utilisant le CLI PHP
(Interface de Ligne de Commande). Si vous avez des problèmes en exécutant ce
script, vérifiez que :

#. le CLI PHP est installé et qu'il a les bons modules activés (ex: MySQL, intl).
#. Certains utilisateurs peuvent aussi rencontrer des problèmes si l'hôte de la
   base de données est 'localhost' et devront essayer '127.0.0.1' à la place,
   car localhost peut causer des problèmes avec PHP CLI.
#. Selon la configuration de votre ordinateur, vous devrez peut-être donner les
   permissions d'exécution sur le script bash cake pour autoriser le lancement
   par ``bin/cake bake``.

Avant de lancer bake, vous devrez vous assurer que vous avez au moins une
connexion de base de données configurée.

Vous pouvez voir la liste des commandes bake disponibles en lançant
``bin/cake bake --help`` (pour Windows ``bin\cake bake --help``) ::

    $ bin/cake bake --help
    Current Paths:

    * app:  src/
    * root: /path/to/your/app/
    * core: /path/to/your/app/vendor/cakephp/cakephp/

    Available Commands:

    Bake:
    - bake all
    - bake behavior
    - bake cell
    - bake command
    - bake component
    - bake controller
    - bake controller all
    - bake fixture
    - bake fixture all
    - bake form
    - bake helper
    - bake mailer
    - bake middleware
    - bake model
    - bake model all
    - bake plugin
    - bake template
    - bake template all
    - bake test

    To run a command, type `cake command_name [args|options]`
    To get help on a specific command, type `cake command_name --help`

Thèmes de Bake
==============

L'option theme est commune à toutes les commandes de bake, et permet de changer
les fichiers de template utilisés lors de la création avec bake. Pour créer vos
propres templates, référez-vous :ref:`à la documentation sur la création de
theme bake <creating-a-bake-theme>`.

.. meta::
    :title lang=fr: Génération de Code avec Bake
    :keywords lang=fr: interface ligne de commande,application fonctionnelle,base de données,configuration base de données,bash script,ingredients basiques,project,model,path path,génération de code,scaffolding,windows users,configuration file,few minutes,config,view,models,running,mysql
