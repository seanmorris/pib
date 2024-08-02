<?php

declare(strict_types=1);

namespace Laminas\ModuleManager\Feature;

interface SerializerProviderInterface
{
    /** @return array */
    public function getSerializerConfig();
}
