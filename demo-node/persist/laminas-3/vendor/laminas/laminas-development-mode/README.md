# laminas-development-mode

[![Build Status](https://github.com/laminas/laminas-development-mode/workflows/continuous-integration.yml/badge.svg)](https://github.com/laminas/laminas-development-mode/actions/workflows/continuous-integration.yml")
[![Total Downloads](https://poser.pugx.org/laminas/laminas-development-mode/downloads)](https://packagist.org/packages/laminas/laminas-development-mode)

> ## 🇷🇺 Русским гражданам
>
> Мы, участники Laminas, родились и живем в разных странах. У многих из нас есть друзья, родственники и коллеги как в России, так и в Украине. Некоторые из нас родились в России. Некоторые из нас живут в России. У некоторых бабушки и дедушки сражались с фашистами во Второй мировой войне. Здесь никто не поддерживает фашизм.
>
> У одного из нас есть украинская родственница, которая спаслась из дома вместе с сыном. Поезд задержался из-за бомбежки на дороге впереди. У нас есть друзья, которые прячутся в бомбоубежищах. Мы с тревогой ждем весточки от них после воздушных налетов, которые беспорядочно наносят удары и попадают по больницам, школам, детским садам и домам. Мы не берем это из каких-либо СМИ. Мы наблюдаем это напрямую.
>
> Вы доверяете нам достаточно, чтоб использовать наши программы, и мы просим вас довериться нам вновь. Мы нуждаемся в помощи. Выходите и протестуйте против этой бесполезной войны. Остановите кровопролитие. Скажите "Нет войне!"
>
> ## 🇺🇸 To Citizens of Russia
>
> We at Laminas come from all over the world. Many of us have friends, family and colleagues in both Russia and Ukraine. Some of us were born in Russia. Some of us currently live in Russia. Some have grandparents who fought Nazis in World War II. Nobody here supports fascism.
>
> One team member has a Ukrainian relative who fled her home with her son. The train was delayed due to bombing on the road ahead. We have friends who are hiding in bomb shelters. We anxiously follow up on them after the air raids, which indiscriminately fire at hospitals, schools, kindergartens and houses. We're not taking this from any media. These are our actual experiences.
>
> You trust us enough to use our software. We ask that you trust us to say the truth on this. We need your help. Go out and protest this unnecessary war. Stop the bloodshed. Say "stop the war!"

This package provides a script to allow you to enable and disable development
mode for [laminas-mvc](https://docs.laminas.dev/laminas-mvc) (both versions 2
and 3) and [Mezzio](https://docs.mezzio.dev/mezzio)
applications. The script allows you to specify configuration and modules that
should only be enabled when in development, and not when in production.

## Note to v2 users

If you were using a v2 version of this package previously, invocation has
changed. Previously, you would invoke it via the MVC CLI bootstrap:

```bash
$ php public/index.php development enable  # enable development mode
$ php public/index.php development disable # disable development mode
```

v3 releases now install this as a vendor binary, with no dependencies on other
components:

```bash
$ ./vendor/bin/laminas-development-mode enable  # enable development mode
$ ./vendor/bin/laminas-development-mode disable # disable development mode
```

## Installation

Install this package using Composer:

```bash
$ composer require laminas/laminas-development-mode
```

Once installed, you will need to copy a base development configuration into your
application; this configuration will allow you to override modules and bootstrap
configuration:

```bash
$ cp vendor/laminas/laminas-development-mode/development.config.php.dist config/
```

Optionally, if you want to also have development-specific application
configuration, you can copy another base configuration into your configuration
autoload directory:

```bash
$ cp vendor/laminas/laminas-development-mode/development.local.php.dist config/autoload/
```

In order for the bootstrap development configuration to run, you may need to
update your application bootstrap. Look for the following lines (or similar) in
`public/index.php`:

```php
// Run the application!
Laminas\Mvc\Application::init(require 'config/application.config.php')->run();
```

Replace the above with the following:

```php
// Config
$appConfig = include 'config/application.config.php';
if (file_exists('config/development.config.php')) {
    $appConfig = Laminas\Stdlib\ArrayUtils::merge($appConfig, include 'config/development.config.php');
}

// Run the application!
Laminas\Mvc\Application::init($appConfig)->run();
```

## To enable development mode

```bash
$ cd path/to/project
$ ./vendor/bin/laminas-development-mode enable
```

Note: enabling development mode will also clear your module configuation cache,
to allow safely updating dependencies and ensuring any new configuration is
picked up by your application.

## To disable development mode

```bash
$ cd path/to/project
$ ./vendor/bin/laminas-development-mode disable
```

**Note:** Don't run development mode on your production server!
