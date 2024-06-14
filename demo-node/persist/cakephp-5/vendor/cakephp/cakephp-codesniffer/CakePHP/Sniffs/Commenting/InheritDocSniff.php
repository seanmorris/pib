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
 * @since         CakePHP CodeSniffer 4.1.0
 * @license       https://www.opensource.org/licenses/mit-license.php MIT License
 */

namespace CakePHP\Sniffs\Commenting;

use PHP_CodeSniffer\Files\File;
use PHP_CodeSniffer\Sniffs\Sniff;

/**
 * Validates proper @inheritDoc use.
 */
class InheritDocSniff implements Sniff
{
    /**
     * @inheritDoc
     */
    public function register()
    {
        return [T_DOC_COMMENT_OPEN_TAG];
    }

    /**
     * @inheritDoc
     */
    public function process(File $phpcsFile, $stackPtr)
    {
        $tokens = $phpcsFile->getTokens();

        $commentEnd = $tokens[$stackPtr]['comment_closer'];

        $empty = [
            T_DOC_COMMENT_WHITESPACE,
            T_DOC_COMMENT_STAR,
        ];

        $inheritDoc = $phpcsFile->findNext($empty, $stackPtr + 1, $commentEnd, true);
        if ($inheritDoc === false) {
            // Ignore empty comments
            return;
        }

        if (
            preg_match('/@inheritDoc/i', $tokens[$inheritDoc]['content']) === 1 &&
            preg_match('/@inheritDoc/', $tokens[$inheritDoc]['content']) === 0
        ) {
            $msg = 'inheritDoc is not capitalized correctly';
            $fix = $phpcsFile->addFixableWarning($msg, $inheritDoc, 'BadSpelling');
            if ($fix === true) {
                $fixed = preg_replace('/inheritDoc/i', 'inheritDoc', $tokens[$inheritDoc]['content']);
                $phpcsFile->fixer->replaceToken($inheritDoc, $fixed);
            }
        }

        if (
            preg_match('/^@inheritDoc/i', $tokens[$inheritDoc]['content']) === 1 &&
            ( preg_match('/^@inheritDoc$/i', $tokens[$inheritDoc]['content']) !== 1 ||
              $phpcsFile->findNext($empty, $inheritDoc + 1, $commentEnd, true) !== false
            )
        ) {
            $msg = 'When using @inheritDoc, it must be the only doc comment.';
            $phpcsFile->addWarning($msg, $inheritDoc, 'NotEmpty');
        }

        if (
            preg_match('/^{@inheritDoc}$/i', $tokens[$inheritDoc]['content']) === 1 &&
            $phpcsFile->findNext($empty, $inheritDoc + 1, $commentEnd, true) === false
        ) {
            $msg = 'When inheriting entire doc comment, @inheritDoc must be used instead of {@inheritDoc}.';
            $fix = $phpcsFile->addFixableWarning($msg, $inheritDoc, 'ShouldNotWrap');
            if ($fix === true) {
                $phpcsFile->fixer->replaceToken($inheritDoc, '@inheritDoc');
            }
        }

        if (
            preg_match('/^{@inheritDoc}/i', $tokens[$inheritDoc]['content']) === 1 &&
            preg_match('/^{@inheritDoc}$/i', $tokens[$inheritDoc]['content']) !== 1
        ) {
            $msg = 'If using {@inheritDoc} to copy description, it must be the first line in doc comment.';
            $phpcsFile->addWarning($msg, $inheritDoc, 'FirstLine');
        }

        $nextComment = $phpcsFile->findNext(T_DOC_COMMENT_STRING, $inheritDoc + 1, $commentEnd);
        while ($nextComment !== false) {
            if (preg_match('/^{@inheritDoc}$/i', $tokens[$nextComment]['content']) === 1) {
                $msg = 'If using {@inheritDoc} to copy description, it must be the first line in doc comment.';
                $phpcsFile->addWarning($msg, $nextComment, 'FirstLine');
            }
            $nextComment = $phpcsFile->findNext(T_DOC_COMMENT_STRING, $nextComment + 1, $commentEnd);
        }
    }
}
