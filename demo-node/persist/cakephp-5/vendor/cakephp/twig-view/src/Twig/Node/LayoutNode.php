<?php
declare(strict_types=1);

/**
 * CakePHP(tm) : Rapid Development Framework (https://cakephp.org)
 * Copyright (c) Cake Software Foundation, Inc. (https://cakefoundation.org)
 *
 * Licensed under The MIT License
 * For full copyright and license information, please see the LICENSE.txt
 * Redistributions of files must retain the above copyright notice
 *
 * @copyright     Copyright (c) Cake Software Foundation, Inc. (https://cakefoundation.org)
 * @link          https://cakephp.org CakePHP(tm) Project
 * @since         1.2.0
 * @license       https://opensource.org/licenses/mit-license.php MIT License
 */

namespace Cake\TwigView\Twig\Node;

use Twig\Compiler;
use Twig\Node\Expression\AbstractExpression;
use Twig\Node\Node;
use Twig\Node\NodeOutputInterface;

/**
 * layout tag node
 */
class LayoutNode extends Node implements NodeOutputInterface
{
    /**
     * Constructor.
     *
     * @param \Twig\Node\Expression\AbstractExpression $layout layout
     * @param int $line Line number.
     * @param string $tag Tag name.
     */
    public function __construct(AbstractExpression $layout, int $line = 0, ?string $tag = null)
    {
        parent::__construct(['layout' => $layout], [], $line, $tag);
    }

    /**
     * Compile tag.
     *
     * @param \Twig\Compiler $compiler Compiler.
     * @return void
     */
    public function compile(Compiler $compiler): void
    {
        $compiler
            ->addDebugInfo($this)
            ->write('$context[\'_view\']->setLayout(')
            ->subcompile($this->getNode('layout'))
            ->raw(");\n");
    }
}
