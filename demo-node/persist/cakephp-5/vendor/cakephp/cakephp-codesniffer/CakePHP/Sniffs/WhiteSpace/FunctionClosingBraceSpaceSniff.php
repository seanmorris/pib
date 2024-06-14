<?php
/**
 * CakePHP(tm) : Rapid Development Framework (https://cakephp.org)
 * Copyright (c) Cake Software Foundation, Inc. (https://cakefoundation.org)
 *
 * This file is originally written by Greg Sherwood and Marc McIntyre, but
 * modified for CakePHP.
 *
 * @copyright     2006 Squiz Pty Ltd (ABN 77 084 670 600)
 * @link          https://github.com/cakephp/cakephp-codesniffer
 * @since         CakePHP CodeSniffer 0.1.1
 * @license       https://github.com/squizlabs/PHP_CodeSniffer/blob/master/licence.txt BSD Licence
 */

/**
 * Checks that there is one empty line before the closing brace of a function.
 */
namespace CakePHP\Sniffs\WhiteSpace;

use PHP_CodeSniffer\Files\File;
use PHP_CodeSniffer\Sniffs\Sniff;

class FunctionClosingBraceSpaceSniff implements Sniff
{
    /**
     * @inheritDoc
     */
    public function register()
    {
        return [T_FUNCTION];
    }

    /**
     * @inheritDoc
     */
    public function process(File $phpcsFile, $stackPtr)
    {
        $tokens = $phpcsFile->getTokens();

        if (isset($tokens[$stackPtr]['scope_closer']) === false) {
            // Probably an interface method.
            return;
        }

        $closeBrace = $tokens[$stackPtr]['scope_closer'];
        $prevContent = $phpcsFile->findPrevious(T_WHITESPACE, $closeBrace - 1, null, true);

        $braceLine = $tokens[$closeBrace]['line'];
        $prevLine = $tokens[$prevContent]['line'];

        $found = $braceLine - $prevLine - 1;
        if (
            $phpcsFile->hasCondition($stackPtr, T_FUNCTION) === true
            || isset($tokens[$stackPtr]['nested_parenthesis']) === true
        ) {
            // Nested function.
            if ($found < 0) {
                $error = 'Closing brace of nested function must be on a new line';
                $phpcsFile->addError($error, $closeBrace, 'ContentBeforeClose');
            } elseif ($found > 0) {
                $error = 'Expected 0 blank lines before closing brace of nested function; %s found';
                $data = [$found];
                $phpcsFile->addError($error, $closeBrace, 'SpacingBeforeNestedClose', $data);
            }
        } else {
            if ($found !== 0) {
                $error = 'Expected 0 blank lines before closing function brace; %s found';
                $data = [$found];
                $phpcsFile->addError($error, $closeBrace, 'SpacingBeforeClose', $data);
            }
        }
    }
}
