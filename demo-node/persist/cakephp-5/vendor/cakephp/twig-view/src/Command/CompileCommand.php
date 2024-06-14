<?php
declare(strict_types=1);

namespace Cake\TwigView\Command;

use Cake\Console\Arguments;
use Cake\Console\BaseCommand;
use Cake\Console\ConsoleIo;
use Cake\Console\ConsoleOptionParser;
use Cake\TwigView\Filesystem\Scanner;
use Cake\TwigView\View\TwigView;
use Exception;

class CompileCommand extends BaseCommand
{
    /**
     * @var \Cake\TwigView\View\TwigView
     */
    protected TwigView $twigView;

    /**
     * @inheritDoc
     */
    protected function buildOptionParser(ConsoleOptionParser $parser): ConsoleOptionParser
    {
        $parser->addArgument('type', [
            'required' => true,
            'choices' => ['all', 'file', 'plugin'],
            'help' => 'The type you want to compile.',
        ]);

        $parser->addArgument('target', [
            'required' => false,
            'help' => 'The file or plugin you want to compile.',
        ]);

        $parser->addOption('view-class', [
            'help' => 'The class name of the View used to load and compile.',
            'default' => TwigView::class,
        ]);

        return $parser;
    }

    /**
     * @inheritDoc
     */
    public function execute(Arguments $args, ConsoleIo $io)
    {
        $type = $args->getArgumentAt(0);

        /** @psalm-var class-string<\Cake\TwigView\View\TwigView> $viewClass */
        $viewClass = $args->getOption('view-class');

        // Setup cached TwigView to avoid creating for every file
        $this->twigView = new $viewClass();

        // $type is validated by the 'choices' option in buildOptionsParser
        return $this->{"execute{$type}"}($args, $io);
    }

    /**
     * Compile all templates.
     *
     * @param \Cake\Console\Arguments $args The command arguments
     * @param \Cake\Console\ConsoleIo $io The console logger
     * @return int
     */
    protected function executeAll(Arguments $args, ConsoleIo $io): int
    {
        $io->info('Compiling all templates');

        foreach (Scanner::all($this->twigView->getExtensions()) as $section => $templates) {
            $io->info("Compiling section {$section}");
            foreach ($templates as $template) {
                if ($this->compileFile($io, $template) === static::CODE_ERROR) {
                    return static::CODE_ERROR;
                }
            }
        }

        return static::CODE_SUCCESS;
    }

    /**
     * Compile all templates for a plugin.
     *
     * @param \Cake\Console\Arguments $args The command arguments
     * @param \Cake\Console\ConsoleIo $io The console logger
     * @return int
     */
    protected function executePlugin(Arguments $args, ConsoleIo $io): int
    {
        $plugin = $args->getArgumentAt(1);
        if ($plugin === null) {
            $io->error('Plugin name not specified.');

            return static::CODE_ERROR;
        }

        $io->info("Compiling plugin {$plugin}");
        foreach (Scanner::plugin($plugin, $this->twigView->getExtensions()) as $template) {
            if ($this->compileFile($io, $template) === static::CODE_ERROR) {
                return static::CODE_ERROR;
            }
        }

        return static::CODE_SUCCESS;
    }

    /**
     * Compile a single template file.
     *
     * @param \Cake\Console\Arguments $args The command arguments
     * @param \Cake\Console\ConsoleIo $io The console logger
     * @return int
     */
    protected function executeFile(Arguments $args, ConsoleIo $io): int
    {
        $filename = $args->getArgumentAt(1);
        if ($filename === null) {
            $io->error('File name not specified.');

            return static::CODE_ERROR;
        }

        return $this->compileFile($io, $filename);
    }

    /**
     * Compile a single template file.
     *
     * @param \Cake\Console\ConsoleIo $io The console logger
     * @param string $filename The template filename
     * @return int
     */
    protected function compileFile(ConsoleIo $io, string $filename): int
    {
        try {
            $this->twigView->getTwig()->load($filename);
            $io->success("Compiled {$filename}.");
        } catch (Exception $exception) {
            $io->error("Unable to compile {$filename}.");
            $io->error($exception->getMessage());

            return static::CODE_ERROR;
        }

        return static::CODE_SUCCESS;
    }
}
