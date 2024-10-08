# laminas-http

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

> This package is considered feature-complete, and is now in **security-only** maintenance mode, following a [decision by the Technical Steering Committee](https://github.com/laminas/technical-steering-committee/blob/2b55453e172a1b8c9c4c212be7cf7e7a58b9352c/meetings/minutes/2020-08-03-TSC-Minutes.md#vote-on-components-to-mark-as-security-only).
> If you have a security issue, please [follow our security reporting guidelines](https://getlaminas.org/security/).
> If you wish to take on the role of maintainer, please [nominate yourself](https://github.com/laminas/technical-steering-committee/issues/new?assignees=&labels=Nomination&template=Maintainer_Nomination.md&title=%5BNOMINATION%5D%5BMAINTAINER%5D%3A+%7Bname+of+person+being+nominated%7D)
>
> You can continue using laminas/laminas-http safely.
> Its successor will be [PSR-7](https://www.php-fig.org/psr/psr-7/) in a later revision of laminas/laminas-mvc.

[![Build Status](https://travis-ci.com/laminas/laminas-http.svg?branch=master)](https://travis-ci.com/laminas/laminas-http)
[![Coverage Status](https://coveralls.io/repos/github/laminas/laminas-http/badge.svg?branch=master)](https://coveralls.io/github/laminas/laminas-http?branch=master)

laminas-http provides the HTTP message abstraction used by
[laminas-mvc](https://docs.laminas.dev/laminas-mvc/), and also provides an
extensible, adapter-driven HTTP client library.

This library **does not** support [PSR-7](http://www.php-fig.org/psr/psr-7), as
it predates that specification. For PSR-7 support, please see our
[Diactoros component](https://docs.laminas.dev/laminas-diactoros/).

## Installation

Run the following to install this library:

```bash
$ composer require laminas/laminas-http
```

## Documentation

Browse the documentation online at https://docs.laminas.dev/laminas-http/

## Support

* [Issues](https://github.com/laminas/laminas-http/issues/)
* [Chat](https://laminas.dev/chat/)
* [Forum](https://discourse.laminas.dev/)
