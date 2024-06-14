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
 * @license       https://www.opensource.org/licenses/mit-license.php MIT License
 */
namespace DebugKit\Panel;

use Cake\Core\Configure;
use Cake\Datasource\EntityInterface;
use Cake\Error\Debugger;
use Cake\Event\EventInterface;
use Cake\Form\Form;
use Cake\Utility\Hash;
use DebugKit\DebugPanel;
use Exception;

/**
 * Provides debug information on the View variables.
 */
class VariablesPanel extends DebugPanel
{
    /**
     * Extracts nested validation errors
     *
     * @param \Cake\Datasource\EntityInterface $entity Entity to extract
     * @return array
     */
    protected function _getErrors(EntityInterface $entity): array
    {
        $errors = $entity->getErrors();

        foreach ($entity->getVisible() as $property) {
            $v = $entity[$property];
            if ($v instanceof EntityInterface) {
                $errors[$property] = $this->_getErrors($v);
            } elseif (is_array($v)) {
                foreach ($v as $key => $varValue) {
                    if ($varValue instanceof EntityInterface) {
                        $errors[$property][$key] = $this->_getErrors($varValue);
                    }
                }
            }
        }

        return Hash::filter($errors);
    }

    /**
     * Safely retrieves debug information from an object
     * and applies a callback.
     *
     * @param callable $walker The walker to apply on the debug info array.
     * @param object $item The item whose debug info to retrieve.
     * @return array|string
     */
    protected function _walkDebugInfo(callable $walker, object $item): array|string
    {
        try {
            $info = $item->__debugInfo();
        } catch (Exception $exception) {
            return sprintf(
                'Could not retrieve debug info - %s. Error: %s in %s, line %d',
                get_class($item),
                $exception->getMessage(),
                $exception->getFile(),
                $exception->getLine()
            );
        }

        return array_map($walker, $info);
    }

    /**
     * Shutdown event
     *
     * @param \Cake\Event\EventInterface $event The event
     * @return void
     */
    public function shutdown(EventInterface $event): void
    {
        /** @var \Cake\Controller\Controller $controller */
        $controller = $event->getSubject();
        $errors = [];
        $content = [];
        $vars = $controller->viewBuilder()->getVars();
        $varsMaxDepth = (int)Configure::read('DebugKit.variablesPanelMaxDepth', 5);

        foreach ($vars as $k => $v) {
            // Get the validation errors for Entity
            if ($v instanceof EntityInterface) {
                $errors[$k] = Debugger::exportVarAsNodes($this->_getErrors($v), $varsMaxDepth);
            } elseif ($v instanceof Form) {
                $formErrors = $v->getErrors();
                if ($formErrors) {
                    $errors[$k] = Debugger::exportVarAsNodes($formErrors, $varsMaxDepth);
                }
            }
            $content[$k] = Debugger::exportVarAsNodes($v, $varsMaxDepth);
        }

        $this->_data = [
            'variables' => $content,
            'errors' => $errors,
            'varsMaxDepth' => $varsMaxDepth,
        ];
    }

    /**
     * Get summary data for the variables panel.
     *
     * @return string
     */
    public function summary(): string
    {
        if (!isset($this->_data['variables'])) {
            return '0';
        }

        return (string)count($this->_data['variables']);
    }
}
