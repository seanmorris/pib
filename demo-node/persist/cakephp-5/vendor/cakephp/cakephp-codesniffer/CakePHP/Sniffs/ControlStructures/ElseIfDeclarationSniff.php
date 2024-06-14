<?php
/**
 * CakePHP(tm) : Rapid Development Framework (https://cakephp.org)
 * Copyright (c) Cake Software Foundation, Inc. (https://cakefoundation.org)
 *
 * Licensed under The MIT License
 * For full copyright and license information, please see the LICENSE.txt
 * Redistributions of files must retain the above copyright notice.
 *
 * @copyright     Copyright (c) Cake Software Foundation, Inc. (https://cakefoundation.org)
 * @link          https://github.com/cakephp/cakephp-codesniffer
 * @since         CakePHP CodeSniffer 0.1.14
 * @license       https://www.opensource.org/licenses/mit-license.php MIT License
 */

namespace CakePHP\Sniffs\ControlStructures;

use PHP_CodeSniffer\Files\File;
use PHP_CodeSniffer\Sniffs\Sniff;

/**
 * Ensures that elseif is used instead of else if
 */
class ElseIfDeclarationSniff implements Sniff
{
    /**
     * @inheritDoc
     */
    public function register()
    {
        return [T_ELSE];
    }

    /**
     * @inheritDoc
     */
    public function process(File $phpcsFile, $stackPtr)
    {
        $tokens = $phpcsFile->getTokens();

        $nextToken = $phpcsFile->findNext(T_WHITESPACE, $stackPtr + 1, null, true);
        if ($tokens[$nextToken]['code'] !== T_IF) {
            return;
        }

        $error = 'Usage of ELSE IF not allowed; use ELSEIF instead';
        $phpcsFile->addError($error, $stackPtr, 'NotAllowed');
    }
}
