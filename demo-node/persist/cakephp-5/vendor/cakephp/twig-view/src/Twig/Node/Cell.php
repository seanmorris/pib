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
use Twig\Node\NodeOutputInterface;

/**
 * Class Cell.
 *
 * @deprecated 1.0.0 Cells are now rendered using `cell()` function instead, provided by `ViewExtension`.
 */
class Cell extends Node implements NodeOutputInterface
{
    /**
     * Whether to assign the data or not.
     *
     * @var bool
     */
    protected bool $assign = false;

    /**
     * Constructor.
     *
     * @param bool $assign Assign or echo.
     * @param mixed $variable Variable to assign to.
     * @param \Twig\Node\Expression\AbstractExpression $name Name.
     * @param \Twig\Node\Expression\AbstractExpression $data Data array.
     * @param \Twig\Node\Expression\AbstractExpression $options Options array.
     * @param int $lineno Line number.
     * @param string $tag Tag name.
     */
    public function __construct(
        bool $assign,
        mixed $variable,
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
            [
                'variable' => $variable,
            ],
            $lineno,
            $tag
        );

        $this->assign = $assign;
    }

    /**
     * Compile tag.
     *
     * @param \Twig\Compiler $compiler Compiler.
     * @return void
     */
    public function compile(Compiler $compiler): void
    {
        $compiler->addDebugInfo($this);

        if ($this->assign) {
            $compiler->raw('$context[\'' . $this->getAttribute('variable') . '\'] = ');
        } else {
            $compiler->raw('echo ');
        }
        $compiler->raw('$context[\'_view\']->cell(');
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
