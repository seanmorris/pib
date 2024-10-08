<?php

declare(strict_types=1);

namespace Laminas\View\Helper;

use function array_merge;

class HtmlPage extends AbstractHtmlElement
{
    /**
     * Default file type for html
     */
    public const TYPE = 'text/html';

    /**
     * Object classid
     */
    public const ATTRIB_CLASSID = 'clsid:25336920-03F9-11CF-8FD0-00AA00686F13';

    /**
     * Default attributes
     *
     * @var array
     */
    protected $attribs = ['classid' => self::ATTRIB_CLASSID];

    /**
     * Output a html object tag
     *
     * @param  string $data    The html url
     * @param  array  $attribs Attribs for the object tag
     * @param  array  $params  Params for in the object tag
     * @param  string $content Alternative content
     * @return string
     */
    public function __invoke($data, array $attribs = [], array $params = [], $content = null)
    {
        // Attribs
        $attribs = array_merge($this->attribs, $attribs);

        // Params
        $params = array_merge(['data' => $data], $params);

        $htmlObject = $this->getView()->plugin('htmlObject');
        return $htmlObject($data, self::TYPE, $attribs, $params, $content);
    }
}
