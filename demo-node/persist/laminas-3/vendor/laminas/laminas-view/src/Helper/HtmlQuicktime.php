<?php

declare(strict_types=1);

namespace Laminas\View\Helper;

use function array_merge;

/** @deprecated */
class HtmlQuicktime extends AbstractHtmlElement
{
    /**
     * Default file type for a movie applet
     */
    public const TYPE = 'video/quicktime';

    /**
     * Object classid
     */
    public const ATTRIB_CLASSID = 'clsid:02BF25D5-8C17-4B23-BC80-D3488ABDDC6B';

    /**
     * Object Codebase
     */
    public const ATTRIB_CODEBASE = 'http://www.apple.com/qtactivex/qtplugin.cab';

    /**
     * Default attributes
     *
     * @var array
     */
    protected $attribs = ['classid' => self::ATTRIB_CLASSID, 'codebase' => self::ATTRIB_CODEBASE];

    /**
     * Output a quicktime movie object tag
     *
     * @param  string $data    The quicktime file
     * @param  array  $attribs Attribs for the object tag
     * @param  array  $params  Params for in the object tag
     * @param  string $content Alternative content
     * @return string
     */
    public function __invoke($data, array $attribs = [], array $params = [], $content = null)
    {
        // Attrs
        $attribs = array_merge($this->attribs, $attribs);

        // Params
        $params = array_merge(['src' => $data], $params);

        $htmlObject = $this->getView()->plugin('htmlObject');
        return $htmlObject($data, self::TYPE, $attribs, $params, $content);
    }
}
