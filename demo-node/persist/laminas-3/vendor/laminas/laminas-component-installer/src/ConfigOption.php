<?php

declare(strict_types=1);

namespace Laminas\ComponentInstaller;

use Laminas\ComponentInstaller\Injector\InjectorInterface;

/**
 * @internal
 */
final class ConfigOption
{
    private InjectorInterface $injector;

    /** @var non-empty-string */
    private string $promptText;

    /**
     * @param non-empty-string $promptText
     */
    public function __construct(string $promptText, InjectorInterface $injector)
    {
        $this->promptText = $promptText;
        $this->injector   = $injector;
    }

    /**
     * @return non-empty-string
     */
    public function getPromptText(): string
    {
        return $this->promptText;
    }

    public function getInjector(): InjectorInterface
    {
        return $this->injector;
    }
}
