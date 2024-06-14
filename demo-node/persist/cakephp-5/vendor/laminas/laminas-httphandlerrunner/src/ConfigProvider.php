<?php

declare(strict_types=1);

namespace Laminas\HttpHandlerRunner;

class ConfigProvider
{
    public function __invoke(): array
    {
        return [
            'dependencies' => $this->getDependencies(),
        ];
    }

    public function getDependencies(): array
    {
        return [];
    }
}
