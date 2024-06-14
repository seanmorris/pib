Console Bake
############

La console Bake de CakePHP est un autre outil permettant de réaliser son
application rapidement. La console Bake peut créer chacun des ingrédients
basiques de CakePHP : models, behaviors, views, helpers, controllers,
components, cas de tests, fixtures et plugins. Et nous ne parlons pas
seulement des squelettes de classes : Bake peut créer une application
fonctionnelle complète en seulement quelques minutes. En réalité, Bake est une
étape naturelle à suivre une fois qu'une application a été prototypée.

Installation
============

Avant d'essayer d'utiliser ou d'étendre bake, assurez-vous qu'il est installé
dans votre application. Bake est disponible en tant que plugin que vous pouvez
installer avec Composer::

    composer require --dev cakephp/bake:"^2.0"

Ceci va installer bake en tant que dépendance de développement. Cela signifie
qu'il ne sera pas installé lors d'un déploiement en production.

Quand vous utilisez les templates Twig, vérifiez que vous chargez le plugin
``Cake/TwigView`` avec son bootstrap. Vous pouvez aussi l'omettre complètement,
ce qui fait que Bake chargera ce plugin à la demande.

.. meta::
    :title lang=fr: Console Bake
    :keywords lang=fr: interface ligne de commande,development,bake view, bake template syntaxe,erb tags,asp tags,percent tags
