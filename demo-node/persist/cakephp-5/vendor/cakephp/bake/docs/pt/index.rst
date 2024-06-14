Console Bake
############

O console do **Bake** é outra ferramenta disponível para você sair trabalhando
- e rápido! O console Bake pode criar qualquer ítem básico do CakePHP: models,
behaviors, views, helpers, controllers, components, test cases, fixtures
e plugins. E nós não estamos apenas falando do esqueleto da classes: O Bake
pode criar uma aplicação totalmente funcional em questão de minutos. De fato,
o Bake é um passo natural a se dar uma vez que a aplicação tem sua base
construída.

Instalação
==========

Antes de tentar usar ou estender o Bake, tenha certeza de que ele está instalado em
sua aplicação. O Bake é distribuído como um plugin que você pode instalar com o
Composer::

    composer require --dev cakephp/bake:~2.0

Isto irá instalar o Bake como uma dependência de desenvolvimento, sendo assim,
não será instalado no ambiente de produção.

Ao usar os modelos Twig, verifique se você está carregando o plugin
Cake/TwigView com seu bootstrap. Você também pode omiti-lo completamente,
o que faz com que o plugin Bake carregue esse plugin sob demanda.

.. meta::
    :title lang=pt: Bake Console
    :keywords lang=pt: cli,linha de comando,command line,dev,desenvolvimento,bake view, bake syntax,erb tags,asp tags,percent tags
