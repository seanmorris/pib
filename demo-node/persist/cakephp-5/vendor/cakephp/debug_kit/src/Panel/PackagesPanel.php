<?php
declare(strict_types=1);

/**
 * CakePHP(tm) : Rapid Development Framework (https://cakephp.org)
 * Copyright (c) Cake Software Foundation, Inc. (https://cakefoundation.org)
 *
 * Licensed under The MIT License
 * Redistributions of files must retain the above copyright notice.
 *
 * @copyright     Copyright (c) Cake Software Foundation, Inc. (https://cakefoundation.org)
 * @link          https://cakephp.org CakePHP(tm) Project
 * @since         DebugKit 3.5.2
 * @license       https://www.opensource.org/licenses/mit-license.php MIT License
 */
namespace DebugKit\Panel;

use Composer\Json\JsonFile;
use DebugKit\DebugPanel;

/**
 * Packages Panel - Reads all installed packages in the project.
 */
class PackagesPanel extends DebugPanel
{
    /**
     * Get the panel data
     *
     * @return array
     */
    public function data(): array
    {
        $packages = $devPackages = [];

        $lockFile = new JsonFile(ROOT . DIRECTORY_SEPARATOR . 'composer.lock');
        if ($lockFile->exists()) {
            $lockContent = $lockFile->read();
            $packages = $lockContent['packages'];
            $devPackages = $lockContent['packages-dev'];
        }

        return [
            'packages' => $packages,
            'devPackages' => $devPackages,
        ];
    }
}
