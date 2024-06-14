<?php
declare(strict_types=1);

/**
 * CakePHP(tm) : Rapid Development Framework (https://cakephp.org)
 * Copyright (c) Cake Software Foundation, Inc. (https://cakefoundation.org)
 * Copyright (c) 2014 Cees-Jan Kiewiet
 *
 * Licensed under The MIT License
 * For full copyright and license information, please see the LICENSE.txt
 * Redistributions of files must retain the above copyright notice
 *
 * @copyright     Copyright (c) Cake Software Foundation, Inc. (https://cakefoundation.org)
 * @link          https://cakephp.org CakePHP(tm) Project
 * @since         1.0.0
 * @license       https://opensource.org/licenses/mit-license.php MIT License
 */

namespace Cake\TwigView\Twig\Node;

use Twig\Compiler;
use Twig\Node\Expression\AbstractExpression;
use Twig\Node\Expression\ArrayExpression;
use Twig\Node\Node;

/**
 * Class Element.
 *
 * @deprecated 1.0.0 Elements are now rendered using `element()` function instead, provided by `ViewExtension`.
 */
class Element extends Node
{
    /**
     * Constructor.
     *
     * @param \Twig\Node\Expression\AbstractExpression $name Name.
     * @param \Twig\Node\Expression\AbstractExpression $data Data.
     * @param \Twig\Node\Expression\AbstractExpression $options Options.
     * @param int $lineno Linenumber.
     * @param string $tag Tag.
     */
    public function __construct(
        AbstractExpression $name,
        ?AbstractExpression $data = null,
        ?AbstractExpression $options = null,
        int $lineno = 0,
        ?string $tag = null
    ) {
        if ($data === null) {
            $data = new ArrayExpression([], $lineno);
        }

        if ($options === null) {
            $options = new ArrayExpression([], $lineno);
        }

        parent::__construct(
            [
                'name' => $name,
                'data' => $data,
                'options' => $options,
            ],
            [],
            $lineno,
            $tag
        );
    }

    /**
     * Compile node.
     *
     * @param \Twig\Compiler $compiler Compiler.
     * @return void
     */
    public function compile(Compiler $compiler): void
    {
        $compiler->addDebugInfo($this);

        $compiler->raw('echo $context[\'_view\']->element(');
        $compiler->subcompile($this->getNode('name'));

        $data = $this->getNode('data');
        $compiler->raw(',');
        $compiler->subcompile($data);

        $options = $this->getNode('options');
        $compiler->raw(',');
        $compiler->subcompile($options);

        $compiler->raw(");\n");
    }
}
