<?php

declare(strict_types=1);

namespace Laminas\View\Helper;

use function array_merge;

/** @deprecated Adobe Flash is obsolete. This helper will be removed in 3.0 */
class HtmlFlash extends AbstractHtmlElement
{
    /**
     * Default file type for a flash applet
     */
    public const TYPE = 'application/x-shockwave-flash';

    /**
     * Output a flash movie object tag
     *
     * @param  string $data    The flash file
     * @param  array  $attribs Attribs for the object tag
     * @param  array  $params  Params for in the object tag
     * @param  string $content Alternative content
     * @return string
     */
    public function __invoke($data, array $attribs = [], array $params = [], $content = null)
    {
        $params = array_merge(['movie' => $data, 'quality' => 'high'], $params);

        $htmlObject = $this->getView()->plugin('htmlObject');
        return $htmlObject($data, self::TYPE, $attribs, $params, $content);
    }
}
