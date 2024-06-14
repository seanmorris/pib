<?php

namespace Jasny\Twig;

use Twig\Extension\AbstractExtension;
use Twig\TwigFilter;

/**
 * Text functions for Twig.
 */
class TextExtension extends AbstractExtension
{
    /**
     * Return extension name
     *
     * @return string
     */
    public function getName()
    {
        return 'jasny/text';
    }

    /**
     * {@inheritdoc}
     */
    public function getFilters()
    {
        return [
            new TwigFilter('paragraph', [$this, 'paragraph'], ['pre_escape' => 'html', 'is_safe' => ['html']]),
            new TwigFilter('line', [$this, 'line']),
            new TwigFilter('less', [$this, 'less'], ['pre_escape' => 'html', 'is_safe' => ['html']]),
            new TwigFilter('truncate', [$this, 'truncate'], ['pre_escape' => 'html', 'is_safe' => ['html']]),
            new TwigFilter('linkify', [$this, 'linkify'], ['pre_escape' => 'html', 'is_safe' => ['html']])
        ];
    }

    /**
     * Add paragraph and line breaks to text.
     *
     * @param string $value
     * @return string
     */
    public function paragraph($value)
    {
        if (!isset($value)) {
            return null;
        }

        return '<p>' . preg_replace(['~\n(\s*)\n\s*~', '~(?<!</p>)\n\s*~'], ["</p>\n\$1<p>", "<br>\n"], trim($value)) .
            '</p>';
    }

    /**
     * Get a single line
     *
     * @param string $value
     * @param int    $line   Line number (starts at 1)
     * @return string
     */
    public function line($value, $line = 1)
    {
        if (!isset($value)) {
            return null;
        }

        $lines = explode("\n", $value);

        return isset($lines[$line - 1]) ? $lines[$line - 1] : null;
    }

    /**
     * Cut of text on a pagebreak.
     *
     * @param string $value
     * @param string $replace
     * @param string $break
     * @return string
     */
    public function less($value, $replace = '...', $break = '<!-- pagebreak -->')
    {
        if (!isset($value)) {
            return null;
        }

        $pos = stripos($value, $break);
        return $pos === false ? $value : substr($value, 0, $pos) . $replace;
    }

    /**
     * Cut of text if it's to long.
     *
     * @param string $value
     * @param int    $length
     * @param string $replace
     * @return string
     */
    public function truncate($value, $length, $replace = '...')
    {
        if (!isset($value)) {
            return null;
        }

        return strlen($value) <= $length ? $value : substr($value, 0, $length - strlen($replace)) . $replace;
    }

    /**
     * Linkify a HTTP(S) link.
     *
     * @param string $protocol  'http' or 'https'
     * @param string $text
     * @param array  $links     OUTPUT
     * @param string $attr
     * @param string $mode
     * @return string
     */
    protected function linkifyHttp($protocol, $text, array &$links, $attr, $mode)
    {
        $regexp = $mode != 'all'
            ? '~(?:(https?)://([^\s<>]+)|(?<!\w@)\b(www\.[^\s<>]+?\.[^\s<>]+))(?<![\.,:;\?!\'"\|])~i'
            : '~(?:(https?)://([^\s<>]+)|(?<!\w@)\b([^\s<>@]+?\.[^\s<>]+)(?<![\.,:]))~i';

        return preg_replace_callback($regexp, function ($match) use ($protocol, &$links, $attr) {
            if ($match[1]) {
                $protocol = $match[1];
            }
            $link = $match[2] ?: $match[3];

            return '<' . array_push($links, '<a' . $attr . ' href="' . $protocol . '://' . $link . '">'
                . rtrim($link, '/') . '</a>') . '>';
        }, $text);
    }

    /**
     * Linkify a mail link.
     *
     * @param string $text
     * @param array  $links     OUTPUT
     * @param string $attr
     * @return string
     */
    protected function linkifyMail($text, array &$links, $attr)
    {
        $regexp = '~([^\s<>]+?@[^\s<>]+?\.[^\s<>]+)(?<![\.,:;\?!\'"\|])~';

        return preg_replace_callback($regexp, function ($match) use (&$links, $attr) {
            return '<' . array_push($links, '<a' . $attr . ' href="mailto:' . $match[1] . '">' . $match[1] . '</a>')
                . '>';
        }, $text);
    }


    /**
     * Linkify a link.
     *
     * @param string $protocol
     * @param string $text
     * @param array  $links     OUTPUT
     * @param string $attr
     * @param string $mode
     * @return string
     */
    protected function linkifyOther($protocol, $text, array &$links, $attr, $mode)
    {
        if (strpos($protocol, ':') === false) {
            $protocol .= in_array($protocol, ['ftp', 'tftp', 'ssh', 'scp']) ? '://' : ':';
        }

        $regexp = $mode != 'all'
            ? '~' . preg_quote($protocol, '~') . '([^\s<>]+)(?<![\.,:;\?!\'"\|])~i'
            : '~([^\s<>]+)(?<![\.,:])~i';

        return preg_replace_callback($regexp, function ($match) use ($protocol, &$links, $attr) {
            return '<' . array_push($links, '<a' . $attr . ' href="' . $protocol . $match[1] . '">' . $match[1]
                . '</a>') . '>';
        }, $text);
    }

    /**
     * Turn all URLs in clickable links.
     *
     * @param string $value
     * @param array  $protocols   'http'/'https', 'mail' and also 'ftp', 'scp', 'tel', etc
     * @param array  $attributes  HTML attributes for the link
     * @param string $mode        normal or all
     * @return string
     */
    public function linkify($value, $protocols = ['http', 'mail'], array $attributes = [], $mode = 'normal')
    {
        if (!isset($value)) {
            return null;
        }

        // Link attributes
        $attr = '';
        foreach ($attributes as $key => $val) {
            $attr .= ' ' . $key . '="' . htmlentities($val) . '"';
        }

        $links = [];

        // Extract existing links and tags
        $text = preg_replace_callback('~(<a .*?>.*?</a>|<.*?>)~i', function ($match) use (&$links) {
            return '<' . array_push($links, $match[1]) . '>';
        }, $value);

        // Extract text links for each protocol
        foreach ((array)$protocols as $protocol) {
            switch ($protocol) {
                case 'http':
                case 'https':
                    $text = $this->linkifyHttp($protocol, $text, $links, $attr, $mode);
                    break;
                case 'mail':
                    $text = $this->linkifyMail($text, $links, $attr);
                    break;
                default:
                    $text = $this->linkifyOther($protocol, $text, $links, $attr, $mode);
                    break;
            }
        }

        // Insert all link
        return preg_replace_callback('/<(\d+)>/', function ($match) use (&$links) {
            return $links[$match[1] - 1];
        }, $text);
    }
}
