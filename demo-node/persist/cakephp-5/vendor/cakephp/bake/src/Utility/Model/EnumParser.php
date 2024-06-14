<?php
declare(strict_types=1);

namespace Bake\Utility\Model;

use InvalidArgumentException;

enum EnumParser
{
    /**
     * @param string|null $casesString
     * @param bool $int
     * @return array<string, int|string>
     */
    public static function parseCases(?string $casesString, bool $int): array
    {
        if ($casesString === null || $casesString === '') {
            return [];
        }

        $enumCases = explode(',', $casesString);

        $definition = [];
        foreach ($enumCases as $k => $enumCase) {
            $case = $value = trim($enumCase);
            if (str_contains($case, ':')) {
                $value = trim(mb_substr($case, strpos($case, ':') + 1));
                $case = mb_substr($case, 0, strpos($case, ':'));
            } elseif ($int) {
                $value = $k;
            }

            if (!preg_match('/^[a-zA-Z_\x80-\xff][a-zA-Z0-9_\x80-\xff]*$/', $case)) {
                throw new InvalidArgumentException(sprintf('`%s` is not a valid enum case', $case));
            }
            if (is_string($value) && str_contains($value, '\'')) {
                throw new InvalidArgumentException(sprintf('`%s` value cannot contain `\'` character', $case));
            }

            $definition[$case] = $int ? (int)$value : $value;
        }

        return $definition;
    }

    /**
     * Parses an enum definition from a DB column comment.
     *
     * @param string $comment
     * @return string
     */
    public static function parseDefinitionString(string $comment): string
    {
        $string = trim(mb_substr($comment, strpos($comment, '[enum]') + 6));
        if (str_contains($string, ';')) {
            $string = trim(mb_substr($string, 0, strpos($string, ';')));
        }

        return $string;
    }
}
