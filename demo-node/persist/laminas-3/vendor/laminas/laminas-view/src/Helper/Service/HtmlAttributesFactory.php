<?php

declare(strict_types=1);

namespace Laminas\View\Helper\Service;

use Laminas\Escaper\Escaper;
use Laminas\View\Helper\HtmlAttributes;
use Psr\Container\ContainerInterface;

final class HtmlAttributesFactory
{
    public function __invoke(ContainerInterface $container): HtmlAttributes
    {
        $escaper = $container->has(Escaper::class)
            ? $container->get(Escaper::class)
            : new Escaper();

        return new HtmlAttributes($escaper);
    }
}
