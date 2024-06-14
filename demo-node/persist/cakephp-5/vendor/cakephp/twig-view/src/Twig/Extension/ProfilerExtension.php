<?php
declare(strict_types=1);

/**
 * CakePHP(tm) : Rapid Development Framework (https://cakephp.org)
 * Copyright (c) Cake Software Foundation, Inc. (https://cakefoundation.org)
 * Copyright (c) 2014 Cees-Jan Kiewiet
 *
 * Licensed under The MIT License
 * For full copyright and license information, please see the LICENSE.txt
 * Redistributions of files must retain the above copyright notice
 *
 * @copyright     Copyright (c) Cake Software Foundation, Inc. (https://cakefoundation.org)
 * @link          https://cakephp.org CakePHP(tm) Project
 * @since         1.0.0
 * @license       https://opensource.org/licenses/mit-license.php MIT License
 */

namespace Cake\TwigView\Twig\Extension;

use DebugKit\DebugTimer;
use Twig\Extension\ProfilerExtension as TwigProfilerExtension;
use Twig\Profiler\Profile;

/**
 * Class ProfilerExtension.
 */
class ProfilerExtension extends TwigProfilerExtension
{
    /**
     * Enter $profile.
     *
     * @param \Twig\Profiler\Profile $profile Profile.
     * @return void
     */
    public function enter(Profile $profile): void
    {
        parent::enter($profile);

        if ($profile->isTemplate()) {
            $name = 'Twig: ' . $profile->getTemplate();
            DebugTimer::start($name, $name);
        }
    }

    /**
     * @param \Twig\Profiler\Profile $profile Profile.
     * @return void
     */
    public function leave(Profile $profile): void
    {
        if ($profile->isTemplate()) {
            $name = 'Twig: ' . $profile->getTemplate();
            DebugTimer::stop($name);
        }

        parent::leave($profile);
    }
}
