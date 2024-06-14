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
 * @since         CakePHP CodeSniffer 0.1.10
 * @license       https://www.opensource.org/licenses/mit-license.php MIT License
 */

/**
 * Ensures trait names are correct depending on the folder of the file.
 */
namespace CakePHP\Sniffs\NamingConventions;

use PHP_CodeSniffer\Files\File;
use PHP_CodeSniffer\Sniffs\Sniff;

class ValidTraitNameSniff implements Sniff
{
    /**
     * @inheritDoc
     */
    public function register()
    {
        return [T_TRAIT];
    }

    /**
     * @inheritDoc
     */
    public function process(File $phpcsFile, $stackPtr)
    {
        $tokens = $phpcsFile->getTokens();
        $traitName = $tokens[$stackPtr + 2]['content'];

        if (substr($traitName, -5) !== 'Trait') {
            $error = 'Traits must have a "Trait" suffix.';
            $phpcsFile->addError($error, $stackPtr, 'InvalidTraitName');
        }
    }
}
