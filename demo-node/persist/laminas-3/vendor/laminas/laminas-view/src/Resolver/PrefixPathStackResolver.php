<?php

declare(strict_types=1);

namespace Laminas\View\Resolver;

use Laminas\View\Renderer\RendererInterface as Renderer;

use function is_string;
use function strlen;
use function strpos;
use function substr;

/** @final */
final class PrefixPathStackResolver implements ResolverInterface
{
    /**
     * Array containing prefix as key and "template path stack array" as value
     *
     * @var array<string, list<string>|string|ResolverInterface>
     */
    private array $prefixes = [];

    /**
     * Constructor
     *
     * @param array<string, list<string>|string|ResolverInterface> $prefixes Set of path prefixes
     *     to be matched (array keys), with either a path or an array of paths
     *     to use for matching as in the {@see TemplatePathStack},
     *     or a {@see ResolverInterface}
     *     to use for view path starting with that prefix
     */
    public function __construct(array $prefixes = [])
    {
        $this->prefixes = $prefixes;
    }

    /**
     * {@inheritDoc}
     */
    public function resolve($name, ?Renderer $renderer = null)
    {
        foreach ($this->prefixes as $prefix => &$resolver) {
            if (strpos($name, (string) $prefix) !== 0) {
                continue;
            }

            if (! $resolver instanceof ResolverInterface) {
                $resolver = new TemplatePathStack(['script_paths' => (array) $resolver]);
            }

            /**
             * @todo In V3, this should just try,return and catch,continue.
             *       It relies on internal knowledge that some resolvers return false when really
             *       they should always return a string or throw an exception.
             */
            $result = $resolver->resolve(substr($name, strlen($prefix)), $renderer);
            if (is_string($result)) {
                return $result;
            }
        }

        /**
         * @todo This should be exceptional. All resolvers are exhausted and no template can be found.
         *       It further deviates from the previously un-documented norm, that the return type is false-able
         */
        return; // phpcs:ignore
    }
}
