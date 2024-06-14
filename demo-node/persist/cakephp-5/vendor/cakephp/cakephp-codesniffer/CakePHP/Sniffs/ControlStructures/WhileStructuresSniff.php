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
 * Ensures that while and do-while use curly brackets
 */
class WhileStructuresSniff implements Sniff
{
    /**
     * @inheritDoc
     */
    public function register()
    {
        return [T_DO, T_WHILE];
    }

    /**
     * @inheritDoc
     */
    public function process(File $phpcsFile, $stackPtr)
    {
        $tokens = $phpcsFile->getTokens();

        $nextToken = $phpcsFile->findNext(T_WHITESPACE, $stackPtr + 1, null, true);
        if ($tokens[$nextToken]['code'] === T_OPEN_PARENTHESIS) {
            $closer = $tokens[$nextToken]['parenthesis_closer'];
            $diff = $closer - $stackPtr;
            $nextToken = $phpcsFile->findNext(T_WHITESPACE, ($stackPtr + $diff + 1), null, true);
        }

        if ($tokens[$stackPtr]['code'] === T_WHILE && $tokens[$nextToken]['code'] === T_SEMICOLON) {
            /* This while is probably part of a do-while construction, skip it .. */
            return;
        }
        if ($tokens[$nextToken]['code'] !== T_OPEN_CURLY_BRACKET && $tokens[$nextToken]['code'] !== T_COLON) {
            $error = 'Curly brackets required in a do-while or while loop';
            $phpcsFile->addError($error, $stackPtr, 'NotAllowed');
        }
    }
}
