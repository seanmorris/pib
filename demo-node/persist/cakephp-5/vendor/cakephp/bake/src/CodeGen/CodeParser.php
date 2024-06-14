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

use PhpParser\Error;
use PhpParser\Lexer\Emulative;
use PhpParser\Node;
use PhpParser\Node\Stmt\Class_;
use PhpParser\Node\Stmt\GroupUse;
use PhpParser\Node\Stmt\Namespace_;
use PhpParser\Node\Stmt\Use_;
use PhpParser\Node\Stmt\UseUse;
use PhpParser\NodeAbstract;
use PhpParser\NodeTraverser;
use PhpParser\NodeVisitorAbstract;
use PhpParser\Parser;
use PhpParser\ParserFactory;

/**
 * @internal
 */
class CodeParser extends NodeVisitorAbstract
{
    /**
     * @var string
     */
    protected const INDENT = '    ';

    /**
     * @var \PhpParser\Parser
     */
    protected Parser $parser;

    /**
     * @var \PhpParser\NodeTraverser
     */
    protected NodeTraverser $traverser;

    /**
     * @var string
     */
    protected string $fileText = '';

    /**
     * @var array
     */
    protected array $parsed = [];

    /**
     * Constructor
     */
    public function __construct()
    {
        $this->parser = (new ParserFactory())->create(
            ParserFactory::PREFER_PHP7,
            new Emulative([
                'usedAttributes' => ['comments', 'startLine', 'endLine', 'startFilePos', 'endFilePos'],
            ])
        );
        $this->traverser = new NodeTraverser();
        $this->traverser->addVisitor($this);
    }

    /**
     * @param string $code Code to parse
     * @return \Bake\CodeGen\ParsedFile|null
     * @throws \Bake\CodeGen\ParseException
     */
    public function parseFile(string $code): ?ParsedFile
    {
        $this->fileText = $code;
        try {
            $this->traverser->traverse($this->parser->parse($code));
        } catch (Error $e) {
            throw new ParseException($e->getMessage(), null, $e);
        }

        if (!isset($this->parsed['namespace'], $this->parsed['class'])) {
            return null;
        }

        return new ParsedFile(
            $this->parsed['namespace'],
            $this->parsed['imports']['class'],
            $this->parsed['imports']['function'],
            $this->parsed['imports']['const'],
            $this->parsed['class']
        );
    }

    /**
     * @inheritDoc
     */
    public function beforeTraverse(array $nodes)
    {
        $this->parsed = [
            'imports' => [
                'class' => [],
                'function' => [],
                'const' => [],
            ],
        ];

        return null;
    }

    /**
     * @inheritDoc
     */
    public function enterNode(Node $node)
    {
        if ($node instanceof Namespace_) {
            if (isset($this->parsed['namespace'])) {
                throw new ParseException('Multiple namespaces are not not supported, update your file');
            }
            $this->parsed['namespace'] = (string)$node->name;

            return null;
        }

        if ($node instanceof Use_) {
            if (count($node->uses) > 1) {
                throw new ParseException('Multiple use statements per line are not supported, update your file');
            }

            [$alias, $target] = $this->normalizeUse(current($node->uses));
            switch ($node->type) {
                case Use_::TYPE_NORMAL:
                    $this->parsed['imports']['class'][$alias] = $target;
                    break;
                case Use_::TYPE_FUNCTION:
                    $this->parsed['imports']['function'][$alias] = $target;
                    break;
                case Use_::TYPE_CONSTANT:
                    $this->parsed['imports']['const'][$alias] = $target;
                    break;
            }

            return NodeTraverser::DONT_TRAVERSE_CHILDREN;
        }

        if ($node instanceof GroupUse) {
            throw new ParseException('Group use statements are not supported, update your file');
        }

        if ($node instanceof Class_) {
            if (!isset($this->parsed['namespace'])) {
                throw new ParseException('Classes defined in the global namespace is not supported, update your file');
            }
            if (isset($this->parsed['class'])) {
                throw new ParseException('Multiple classes are not supported, update your file');
            }

            $constants = [];
            foreach ($node->getConstants() as $constant) {
                if (count($constant->consts) > 1) {
                    throw new ParseException('Multiple constants per line are not supported, update your file');
                }

                $name = (string)current($constant->consts)->name;
                $constants[$name] = $this->getNodeCode($constant);
            }

            $properties = [];
            foreach ($node->getProperties() as $property) {
                if (count($property->props) > 1) {
                    throw new ParseException('Multiple properties per line are not supported, update your file');
                }

                $name = (string)current($property->props)->name;
                $properties[$name] = $this->getNodeCode($property);
            }

            $methods = [];
            foreach ($node->getMethods() as $method) {
                $name = (string)$method->name;
                $methods[$name] = $this->getNodeCode($method);
            }

            $implements = array_map(function ($name) {
                return (string)$name;
            }, $node->implements);

            $this->parsed['class'] = new ParsedClass(
                (string)$node->name,
                $implements,
                $constants,
                $properties,
                $methods
            );

            return NodeTraverser::DONT_TRAVERSE_CHILDREN;
        }

        return null;
    }

    /**
     * @param \PhpParser\NodeAbstract $node Parser node
     * @return string
     */
    protected function getNodeCode(NodeAbstract $node): string
    {
        $code = '';

        $doc = $node->getDocComment() ? $node->getDocComment()->getText() : '';
        if ($doc) {
            $code = static::INDENT . $doc . "\n";
        }

        $startPos = $node->getStartFilePos();
        $endPos = $node->getEndFilePos();
        $code .= static::INDENT . substr($this->fileText, $startPos, $endPos - $startPos + 1);

        return $code;
    }

    /**
     * @param \PhpParser\Node\Stmt\UseUse $use Use node
     * @param string|null $prefix Group use prefix
     * @return array{string, string}
     */
    protected function normalizeUse(UseUse $use, ?string $prefix = null): array
    {
        $name = (string)$use->name;
        if ($prefix) {
            $name = $prefix . '\\' . $name;
        }

        $alias = $use->alias;
        if (!$alias) {
            $last = strrpos($name, '\\', -1);
            if ($last !== false) {
                $alias = substr($name, strrpos($name, '\\', -1) + 1);
            } else {
                $alias = $name;
            }
        }

        return [(string)$alias, $name];
    }
}
