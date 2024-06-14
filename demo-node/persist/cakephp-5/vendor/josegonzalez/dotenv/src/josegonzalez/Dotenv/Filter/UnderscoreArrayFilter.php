<?php

namespace josegonzalez\Dotenv\Filter;

class UnderscoreArrayFilter
{
    /**
     * Expands a flat array to a nested array.
     *
     * For example, `['0_Foo_Bar' => 'Far']` becomes
     * `[['Foo' => ['Bar' => 'Far']]]`.
     *
     * @param array $environment Array of environment data
     * @return array
     */
    public function __invoke(array $environment)
    {
        $result = array();
        foreach ($environment as $flat => $value) {
            $keys = explode('_', $flat);
            $keys = array_reverse($keys);
            $child = array(
                $keys[0] => $value
            );
            array_shift($keys);
            foreach ($keys as $k) {
                $child = array(
                    $k => $child
                );
            }

            $stack = array(array($child, &$result));
            while (!empty($stack)) {
                foreach ($stack as $curKey => &$curMerge) {
                    foreach ($curMerge[0] as $key => &$val) {
                        $hasKey = !empty($curMerge[1][$key]);
                        if ($hasKey && (array)$curMerge[1][$key] === $curMerge[1][$key] && (array)$val === $val) {
                            $stack[] = array(&$val, &$curMerge[1][$key]);
                        } else {
                            $curMerge[1][$key] = $val;
                        }
                    }
                    unset($stack[$curKey]);
                }
                unset($curMerge);
            }
        }
        return $result;
    }
}
