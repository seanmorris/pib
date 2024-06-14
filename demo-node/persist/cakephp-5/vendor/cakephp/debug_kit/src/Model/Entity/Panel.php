<?php
declare(strict_types=1);

/**
 * Copyright (c) Cake Software Foundation, Inc. (https://cakefoundation.org)
 *
 * Licensed under The MIT License
 * Redistributions of files must retain the above copyright notice.
 *
 * @copyright     Copyright (c) Cake Software Foundation, Inc. (https://cakefoundation.org)
 * @link          https://cakephp.org CakePHP(tm) Project
 * @license       https://www.opensource.org/licenses/mit-license.php MIT License
 */
namespace DebugKit\Model\Entity;

use Cake\ORM\Entity;

/**
 * Panel entity class.
 *
 * @property int $id
 * @property int $request_id
 * @property string $title
 * @property string $element
 * @property string $content
 *
 * @property \DebugKit\Model\Entity\Request $request
 */
class Panel extends Entity
{
    /**
     * Some fields should not be in JSON/array exports.
     *
     * @var list<string>
     */
    protected array $_hidden = ['content'];

    /**
     * Read the stream contents.
     *
     * Over certain sizes PDO will return file handles.
     * For backwards compatibility and consistency we smooth over that difference here.
     *
     * @param mixed $content Content
     * @return string
     */
    protected function _getContent(mixed $content): string
    {
        if (is_resource($content)) {
            return (string)stream_get_contents($content);
        }

        return $content;
    }
}
