<?php

declare(strict_types=1);

namespace Laminas\SkeletonInstaller;

use Composer\Factory;
use Composer\Json\JsonFile;

trait ComposerJsonRetrievalTrait
{
    /** @var callable Factory to use for returning the composer.json path */
    private $composerFileFactory = [Factory::class, 'getComposerFile'];

    /**
     * Retrieve the project composer.json as a JsonFile.
     *
     * @return JsonFile
     */
    private function getComposerJson()
    {
        $composerFile = ($this->composerFileFactory)();
        return new JsonFile($composerFile);
    }
}
