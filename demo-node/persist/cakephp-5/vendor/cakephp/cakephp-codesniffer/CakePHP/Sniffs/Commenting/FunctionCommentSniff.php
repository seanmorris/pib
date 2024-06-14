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
 * @since         CakePHP CodeSniffer 0.1.24
 * @license       https://www.opensource.org/licenses/mit-license.php MIT License
 */
namespace CakePHP\Sniffs\Commenting;

use PHP_CodeSniffer\Files\File;
use PHP_CodeSniffer\Sniffs\Sniff;

/**
 * Parses and verifies the doc comments for functions.
 *
 * Verifies that :
 * <ul>
 *  <li>A comment exists</li>
 *  <li>No spacing between doc comment and function</li>
 *  <li>Any throw tag must have a comment</li>
 * </ul>
 *
 * @category  PHP
 * @package   PHP_CodeSniffer
 * @author    Greg Sherwood <gsherwood@squiz.net>
 * @author    Marc McIntyre <mmcintyre@squiz.net>
 * @copyright 2006-2014 Squiz Pty Ltd (ABN 77 084 670 600)
 * @license   https://github.com/squizlabs/PHP_CodeSniffer/blob/master/licence.txt BSD Licence
 * @version   Release: @package_version@
 * @link      https://pear.php.net/package/PHP_CodeSniffer
 */
class FunctionCommentSniff implements Sniff
{
    /**
     * Returns an array of tokens this test wants to listen for.
     *
     * @return array
     * @phpcsSuppress SlevomatCodingStandard.TypeHints.ReturnTypeHint.MissingNativeTypeHint
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

        $docCommentEnd = $phpcsFile->findPrevious(
            [T_DOC_COMMENT_CLOSE_TAG, T_SEMICOLON, T_CLOSE_CURLY_BRACKET, T_OPEN_CURLY_BRACKET],
            $stackPtr - 1,
            null
        );
        if ($docCommentEnd === false || $tokens[$docCommentEnd]['code'] !== T_DOC_COMMENT_CLOSE_TAG) {
            $phpcsFile->addError(
                'Missing doc comment for function %s()',
                $stackPtr,
                'Missing',
                [$phpcsFile->getDeclarationName($stackPtr)]
            );

            return;
        }

        $lastEndToken = $docCommentEnd;
        do {
            $attribute = $phpcsFile->findNext(
                [T_ATTRIBUTE],
                $lastEndToken + 1,
                $stackPtr
            );
            if ($attribute !== false) {
                if ($tokens[$lastEndToken]['line'] !== $tokens[$attribute]['line'] - 1) {
                    $phpcsFile->addError(
                        'There must be no blank lines after the function comment or attribute',
                        $lastEndToken,
                        'SpacingAfter'
                    );

                    return;
                }

                $lastEndToken = $tokens[$attribute]['attribute_closer'];
            }
        } while ($attribute !== false);

        if ($tokens[$lastEndToken]['line'] !== $tokens[$stackPtr]['line'] - 1) {
            $phpcsFile->addError(
                'There must be no blank lines after the function comment or attribute',
                $lastEndToken,
                'SpacingAfter'
            );
        }

        $commentStart = $tokens[$docCommentEnd]['comment_opener'];
        $this->processTagSpacing($phpcsFile, $stackPtr, $commentStart);
        $this->processThrows($phpcsFile, $stackPtr, $commentStart);
    }

    /**
     * @param \PHP_CodeSniffer\Files\File $phpcsFile The file being scanned.
     * @param int $stackPtr The position of the current token in the stack passed in $tokens.
     * @return void
     */
    protected function processTagSpacing(File $phpcsFile, int $stackPtr, int $commentStart): void
    {
        $tokens = $phpcsFile->getTokens();
        $tags = $tokens[$commentStart]['comment_tags'];
        foreach ($tags as $tag) {
            if (
                $tokens[$tag + 2]['code'] === T_DOC_COMMENT_STRING &&
                $phpcsFile->fixer->getTokenContent($tag + 1) !== ' '
            ) {
                $fix = $phpcsFile->addFixableWarning('Should be only one space after tag', $tag, 'TagAlignment');
                if ($fix) {
                    $phpcsFile->fixer->beginChangeset();
                    $phpcsFile->fixer->replaceToken($tag + 1, ' ');
                    $phpcsFile->fixer->endChangeset();
                }
            }
        }
    }

    /**
     * Process any throw tags that this function comment has.
     *
     * @param \PHP_CodeSniffer\Files\File $phpcsFile The file being scanned.
     * @param int $stackPtr The position of the current token in the stack passed in $tokens.
     * @param int $commentStart The position in the stack where the comment started.
     * @return void
     */
    protected function processThrows(File $phpcsFile, int $stackPtr, int $commentStart): void
    {
        $tokens = $phpcsFile->getTokens();

        foreach ($tokens[$commentStart]['comment_tags'] as $tag) {
            if ($tokens[$tag]['content'] !== '@throws') {
                continue;
            }

            $exception = null;
            if ($tokens[$tag + 2]['code'] === T_DOC_COMMENT_STRING) {
                $matches = [];
                preg_match('/([^\s]+)(?:\s+(.*))?/', $tokens[$tag + 2]['content'], $matches);
                $exception = $matches[1];
            }

            if ($exception === null) {
                $error = 'Exception type and comment missing for @throws tag in function comment';
                $phpcsFile->addWarning($error, $tag, 'InvalidThrows');
            }
        }
    }
}
