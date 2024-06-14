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
 * @since         CakePHP CodeSniffer 2.1.0
 * @license       https://www.opensource.org/licenses/mit-license.php MIT License
 */

namespace CakePHP\Sniffs\Formatting;

use PHP_CodeSniffer\Files\File;
use PHP_CodeSniffer\Sniffs\Sniff;

/**
 * Throws errors if there's no blank line before return statements.
 *
 * @author   Authors <Symfony2-coding-standard@escapestudios.github.com>
 * @license  https://spdx.org/licenses/MIT MIT License
 * @link     https://github.com/escapestudios/Symfony2-coding-standard
 */
class BlankLineBeforeReturnSniff implements Sniff
{
    /**
     * @inheritDoc
     */
    public function register()
    {
        return [T_RETURN];
    }

    /**
     * @inheritDoc
     */
    public function process(File $phpcsFile, $stackPtr)
    {
        $tokens = $phpcsFile->getTokens();
        $current = $stackPtr;
        $previousLine = $tokens[$stackPtr]['line'] - 1;
        $prevLineTokens = [];

        while ($current >= 0 && $tokens[$current]['line'] >= $previousLine) {
            if (
                $tokens[$current]['line'] == $previousLine
                && $tokens[$current]['code'] !== T_WHITESPACE
                && $tokens[$current]['code'] !== T_COMMENT
                && $tokens[$current]['code'] !== T_DOC_COMMENT_OPEN_TAG
                && $tokens[$current]['code'] !== T_DOC_COMMENT_TAG
                && $tokens[$current]['code'] !== T_DOC_COMMENT_STRING
                && $tokens[$current]['code'] !== T_DOC_COMMENT_CLOSE_TAG
                && $tokens[$current]['code'] !== T_DOC_COMMENT_WHITESPACE
            ) {
                $prevLineTokens[] = $tokens[$current]['code'];
            }
            $current--;
        }

        if (
            isset($prevLineTokens[0])
            && ($prevLineTokens[0] === T_OPEN_CURLY_BRACKET
                || $prevLineTokens[0] === T_COLON
                || $prevLineTokens[0] === T_OPEN_TAG)
        ) {
            return;
        } elseif (count($prevLineTokens) > 0) {
            $fix = $phpcsFile->addFixableError(
                'Missing blank line before return statement',
                $stackPtr,
                'BlankLineBeforeReturn'
            );
            if ($fix === true) {
                $phpcsFile->fixer->beginChangeset();
                $phpcsFile->fixer->addNewlineBefore($stackPtr - 1);
                $phpcsFile->fixer->endChangeset();
            }
        }
    }
}
