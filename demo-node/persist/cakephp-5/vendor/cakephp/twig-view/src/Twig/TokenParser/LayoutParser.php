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

namespace Cake\TwigView\Twig\TokenParser;

use Cake\TwigView\Twig\Node\LayoutNode;
use Twig\Node\Node;
use Twig\Token;
use Twig\TokenParser\AbstractTokenParser;

/**
 * layout tag parser
 */
class LayoutParser extends AbstractTokenParser
{
    /**
     * Parse token.
     *
     * @param \Twig\Token $token Token.
     * @return \Twig\Node\Node
     */
    public function parse(Token $token): Node
    {
        $parser = $this->parser;
        $stream = $parser->getStream();

        $layout = $parser->getExpressionParser()->parseExpression();
        $stream->expect(Token::BLOCK_END_TYPE);

        return new LayoutNode($layout, $token->getLine(), $this->getTag());
    }

    /**
     * Tag name.
     *
     * @return string
     */
    public function getTag(): string
    {
        return 'layout';
    }
}
