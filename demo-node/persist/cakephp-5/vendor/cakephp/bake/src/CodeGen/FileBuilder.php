<?php
declare(strict_types=1);

/**
 * CakePHP(tm) : Rapid Development Framework (https://cakephp.org)
 * Copyright (c) Cake Software Foundation, Inc. (https://cakefoundation.org)
 *
 * Licensed under The MIT License
 * For full copyright and license information, please see the LICENSE.txt
 * Redistributions of files must retain the above copyright notice.
 *
 * @copyright     Copyright (c) Cake Software Foundation, Inc. (https://cakefoundation.org)
 * @link          https://cakephp.org CakePHP(tm) Project
 * @since         2.8.0
 * @license       https://www.opensource.org/licenses/mit-license.php MIT License
 */
namespace Bake\CodeGen;

use Cake\Console\ConsoleIo;

class FileBuilder
{
    /**
     * @var \Cake\Console\ConsoleIo
     */
    protected ConsoleIo $io;

    /**
     * @var string
     */
    protected string $namespace;

    /**
     * @var \Bake\CodeGen\ParsedFile|null
     */
    protected ?ParsedFile $parsedFile;

    /**
     * @var \Bake\CodeGen\ClassBuilder
     */
    protected ClassBuilder $classBuilder;

    /**
     * @param \Cake\Console\ConsoleIo $io Console io
     * @param string $namespace File namespace
     * @param \Bake\CodeGen\ParsedFile $parsedFile Parsed file it already exists
     */
    public function __construct(ConsoleIo $io, string $namespace, ?ParsedFile $parsedFile = null)
    {
        if ($parsedFile && $parsedFile->namespace !== $namespace) {
            throw new ParseException(sprintf(
                'Existing namespace `%s` does not match expected namespace `%s`, cannot update existing file',
                $parsedFile->namespace,
                $namespace
            ));
        }

        $this->io = $io;
        $this->namespace = $namespace;
        $this->parsedFile = $parsedFile;
        $this->classBuilder = new ClassBuilder($parsedFile->class ?? null);
    }

    /**
     * Returns the file namespace.
     *
     * @return string
     */
    public function getNamespace(): string
    {
        return $this->namespace;
    }

    /**
     * @return \Bake\CodeGen\ClassBuilder
     */
    public function classBuilder(): ClassBuilder
    {
        return $this->classBuilder;
    }

    /**
     * Returns class imports merged with user imports from file.
     *
     * @param array<string|int, string> $imports Class imports to merge with file imports
     * @return array<string, string>
     */
    public function getClassImports(array $imports = []): array
    {
        return ImportHelper::merge($imports, $this->parsedFile->classImports ?? [], $this->io);
    }

    /**
     * Returns function imports merged with user imports from file.
     *
     * @param array<string|int, string> $imports Function imports to merge with file imports
     * @return array<string, string>
     */
    public function getFunctionImports(array $imports = []): array
    {
        return ImportHelper::merge($imports, $this->parsedFile->functionImports ?? [], $this->io);
    }

    /**
     * Returns const imports merged with user imports from file.
     *
     * @param array<string|int, string> $imports Const imports to merge with file imports
     * @return array<string, string>
     */
    public function getConstImports(array $imports = []): array
    {
        return ImportHelper::merge($imports, $this->parsedFile->constImports ?? [], $this->io);
    }
}
