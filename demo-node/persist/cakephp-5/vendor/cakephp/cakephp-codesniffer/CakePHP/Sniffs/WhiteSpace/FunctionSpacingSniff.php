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
 * Checks the separation between methods in a class or interface.
 */
namespace CakePHP\Sniffs\WhiteSpace;

use PHP_CodeSniffer\Files\File;
use PHP_CodeSniffer\Sniffs\Sniff;
use PHP_CodeSniffer\Util\Tokens;

/**
 * There should always be newlines around functions/methods.
 */
class FunctionSpacingSniff implements Sniff
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
    public function process(File $phpCsFile, $stackPointer)
    {
        $tokens = $phpCsFile->getTokens();

        $level = $tokens[$stackPointer]['level'];
        if ($level < 1) {
            return;
        }

        $openingBraceIndex = $phpCsFile->findNext(T_OPEN_CURLY_BRACKET, $stackPointer + 1);
        // Fix interface methods
        if (!$openingBraceIndex) {
            $openingParenthesisIndex = $phpCsFile->findNext(T_OPEN_PARENTHESIS, $stackPointer + 1);
            $closingParenthesisIndex = $tokens[$openingParenthesisIndex]['parenthesis_closer'];

            $semicolonIndex = $phpCsFile->findNext(T_SEMICOLON, $closingParenthesisIndex + 1);

            $nextContentIndex = $phpCsFile->findNext(T_WHITESPACE, $semicolonIndex + 1, null, true);

            // Do not mess with the end of the class
            if ($tokens[$nextContentIndex]['code'] === T_CLOSE_CURLY_BRACKET) {
                return;
            }

            if ($tokens[$nextContentIndex]['line'] - $tokens[$semicolonIndex]['line'] <= 1) {
                $fix = $phpCsFile->addFixableError(
                    'Every function/method needs a newline afterwards',
                    $closingParenthesisIndex,
                    'Abstract'
                );
                if ($fix) {
                    $phpCsFile->fixer->addNewline($semicolonIndex);
                }
            }

            return;
        }

        $closingBraceIndex = $tokens[$openingBraceIndex]['scope_closer'];

        // Ignore closures
        $nextIndex = $phpCsFile->findNext(Tokens::$emptyTokens, $closingBraceIndex + 1, null, true);
        if (in_array($tokens[$nextIndex]['content'], [';', ',', ')'])) {
            return;
        }

        $nextContentIndex = $phpCsFile->findNext(T_WHITESPACE, $closingBraceIndex + 1, null, true);

        // Do not mess with the end of the class
        if ($tokens[$nextContentIndex]['code'] === T_CLOSE_CURLY_BRACKET) {
            return;
        }

        $this->assertNewLineAtTheEnd($phpCsFile, $closingBraceIndex, $nextContentIndex);
        $this->assertNewLineAtTheBeginning($phpCsFile, $stackPointer);
    }

    /**
     * @param \PHP_CodeSniffer\Files\File $phpCsFile File
     * @param int $closingBraceIndex Index
     * @param int|null $nextContentIndex Index
     * @return void
     */
    protected function assertNewLineAtTheEnd(File $phpCsFile, int $closingBraceIndex, ?int $nextContentIndex): void
    {
        $tokens = $phpCsFile->getTokens();

        if (!$nextContentIndex || $tokens[$nextContentIndex]['line'] - $tokens[$closingBraceIndex]['line'] <= 1) {
            $fix = $phpCsFile->addFixableError(
                'Every function/method needs a newline afterwards',
                $closingBraceIndex,
                'Concrete'
            );
            if ($fix) {
                $phpCsFile->fixer->addNewline($closingBraceIndex);
            }
        }
    }

    /**
     * Asserts newline at the beginning, including the doc block.
     *
     * @param \PHP_CodeSniffer\Files\File $phpCsFile File
     * @param int $stackPointer Stack pointer
     * @return void
     */
    protected function assertNewLineAtTheBeginning(File $phpCsFile, int $stackPointer): void
    {
        $tokens = $phpCsFile->getTokens();

        $line = $tokens[$stackPointer]['line'];
        $firstTokenInLineIndex = $stackPointer;
        while ($tokens[$firstTokenInLineIndex - 1]['line'] === $line) {
            $firstTokenInLineIndex--;
        }

        $prevContentIndex = $phpCsFile->findPrevious(T_WHITESPACE, $firstTokenInLineIndex - 1, null, true);

        if ($tokens[$prevContentIndex]['code'] === T_ATTRIBUTE_END) {
            return;
        }

        if ($tokens[$prevContentIndex]['code'] === T_DOC_COMMENT_CLOSE_TAG) {
            $firstTokenInLineIndex = $tokens[$prevContentIndex]['comment_opener'];
            while ($tokens[$firstTokenInLineIndex - 1]['line'] === $line) {
                $firstTokenInLineIndex--;
            }
        }

        $prevContentIndex = $phpCsFile->findPrevious(T_WHITESPACE, $firstTokenInLineIndex - 1, null, true);

        // Do not mess with the start of the class
        if ($tokens[$prevContentIndex]['code'] === T_OPEN_CURLY_BRACKET) {
            return;
        }

        if ($tokens[$prevContentIndex]['line'] < $tokens[$firstTokenInLineIndex]['line'] - 1) {
            return;
        }

        $fix = $phpCsFile->addFixableError(
            'Every function/method needs a newline before',
            $firstTokenInLineIndex,
            'Concrete'
        );
        if ($fix) {
            $phpCsFile->fixer->addNewline($prevContentIndex);
        }
    }
}
