<?php

/**
 * This file is part of the m1\env library
 *
 * (c) m1 <hello@milescroxford.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 *
 * @package     m1/env
 * @version     2.0.0
 * @author      Miles Croxford <hello@milescroxford.com>
 * @copyright   Copyright (c) Miles Croxford <hello@milescroxford.com>
 * @license     http://github.com/m1/env/blob/master/LICENSE.md
 * @link        http://github.com/m1/env/blob/master/README.md Documentation
 */

namespace M1\Env\Parser;

/**
 * The abstract parser for Env
 *
 * @since 0.2.0
 */
abstract class AbstractParser
{
    /**
     * The parent parser
     *
     * @var \M1\Env\Parser $parser
     */
    protected $parser;

    /**
     * The abstract parser constructor for Env
     *
     * @param \M1\Env\Parser $parser The parent parser
     */
    public function __construct($parser)
    {
        $this->parser = $parser;
    }
}
