<?php

declare(strict_types=1);

namespace Laminas\ModuleManager\Listener;

use Brick\VarExporter\ExportException;
use Brick\VarExporter\VarExporter;
use Laminas\ModuleManager\Listener\Exception\ConfigCannotBeCachedException;
use Webimpress\SafeWriter\FileWriter;

abstract class AbstractListener
{
    /** @var ListenerOptions */
    protected $options;

    public function __construct(?ListenerOptions $options = null)
    {
        $options = $options ?: new ListenerOptions();
        $this->setOptions($options);
    }

    /** @return ListenerOptions */
    public function getOptions()
    {
        return $this->options;
    }

    /**
     * @param ListenerOptions $options the value to be set
     * @return AbstractListener
     */
    public function setOptions(ListenerOptions $options)
    {
        $this->options = $options;
        return $this;
    }

    /**
     * Write a simple array of scalars to a file
     *
     * @param  string $filePath
     * @param  array $array
     * @return AbstractListener
     */
    protected function writeArrayToFile($filePath, $array)
    {
        try {
            $content = "<?php\n" . VarExporter::export(
                $array,
                VarExporter::ADD_RETURN | VarExporter::CLOSURE_SNAPSHOT_USES
            );
        } catch (ExportException $e) {
            throw ConfigCannotBeCachedException::fromExporterException($e);
        }

        FileWriter::writeFile($filePath, $content);

        return $this;
    }
}
