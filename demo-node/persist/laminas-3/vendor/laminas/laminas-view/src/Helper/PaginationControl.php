<?php

declare(strict_types=1);

namespace Laminas\View\Helper;

use Laminas\Paginator;
use Laminas\View\Exception;

use function array_merge;
use function count;
use function get_object_vars;
use function is_array;

class PaginationControl extends AbstractHelper
{
    /**
     * Default Scrolling Style
     *
     * @var string
     */
    protected static $defaultScrollingStyle = 'sliding';

    /**
     * Default view partial
     *
     * @var string|array
     */
    protected static $defaultViewPartial;

    /**
     * Render the provided pages.  This checks if $view->paginator is set and,
     * if so, uses that.  Also, if no scrolling style or partial are specified,
     * the defaults will be used (if set).
     *
     * @param  string              $scrollingStyle (Optional) Scrolling style
     * @param  string              $partial        (Optional) View partial
     * @param  array|string        $params         (Optional) params to pass to the partial
     * @throws Exception\RuntimeException If no paginator or no view partial provided.
     * @throws Exception\InvalidArgumentException If partial is invalid array.
     * @return string
     */
    public function __invoke(
        ?Paginator\Paginator $paginator = null,
        $scrollingStyle = null,
        $partial = null,
        $params = null
    ) {
        if ($paginator === null) {
            if (
                isset($this->view->paginator)
                && $this->view->paginator !== null
                && $this->view->paginator instanceof Paginator\Paginator
            ) {
                $paginator = $this->view->paginator;
            } else {
                throw new Exception\RuntimeException('No paginator instance provided or incorrect type');
            }
        }

        if ($partial === null) {
            if (static::$defaultViewPartial === null) {
                throw new Exception\RuntimeException('No view partial provided and no default set');
            }

            $partial = static::$defaultViewPartial;
        }

        if ($scrollingStyle === null) {
            $scrollingStyle = static::$defaultScrollingStyle;
        }

        $pages = get_object_vars($paginator->getPages($scrollingStyle));

        if ($params !== null) {
            $pages = array_merge($pages, (array) $params);
        }

        if (is_array($partial)) {
            if (count($partial) !== 2) {
                throw new Exception\InvalidArgumentException(
                    'A view partial supplied as an array must contain two values: the filename and its module'
                );
            }

            if ($partial[1] !== null) {
                $partialHelper = $this->view->plugin('partial');
                return $partialHelper($partial[0], $pages);
            }

            $partial = $partial[0];
        }

        $partialHelper = $this->view->plugin('partial');
        return $partialHelper($partial, $pages);
    }

    /**
     * Sets the default Scrolling Style
     *
     * @param string $style string 'all' | 'elastic' | 'sliding' | 'jumping'
     * @return void
     */
    public static function setDefaultScrollingStyle($style)
    {
        static::$defaultScrollingStyle = $style;
    }

    /**
     * Gets the default scrolling style
     *
     * @return string
     */
    public static function getDefaultScrollingStyle()
    {
        return static::$defaultScrollingStyle;
    }

    /**
     * Sets the default view partial.
     *
     * @param string|array $partial View partial
     * @return void
     */
    public static function setDefaultViewPartial($partial)
    {
        static::$defaultViewPartial = $partial;
    }

    /**
     * Gets the default view partial
     *
     * @return string|array
     */
    public static function getDefaultViewPartial()
    {
        return static::$defaultViewPartial;
    }
}
