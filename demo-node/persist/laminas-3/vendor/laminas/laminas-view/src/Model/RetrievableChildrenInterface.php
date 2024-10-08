<?php

declare(strict_types=1);

namespace Laminas\View\Model;

/**
 * Interface describing a Retrievable Child Model
 *
 * Models implementing this interface provide a way to get there children by capture
 */
interface RetrievableChildrenInterface
{
    /**
     * Returns an array of View models with captureTo value $capture
     *
     * @param string $capture
     * @param bool $recursive search recursive through children, default true
     * @return list<ModelInterface>
     */
    public function getChildrenByCaptureTo($capture, $recursive = true);
}
