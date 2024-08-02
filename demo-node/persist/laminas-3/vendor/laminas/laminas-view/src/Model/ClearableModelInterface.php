<?php

declare(strict_types=1);

namespace Laminas\View\Model;

/**
 * Interface describing methods for clearing the state of a view model.
 *
 * View models implementing this interface allow clearing children, options,
 * and variables.
 */
interface ClearableModelInterface
{
    public function clearChildren();

    public function clearOptions();

    public function clearVariables();
}
