<?php

declare(strict_types=1);

namespace Laminas\View\Helper;

use Laminas\View\Exception;
use Laminas\View\Helper\Placeholder\Container\AbstractContainer;
use Laminas\View\Helper\Placeholder\Container\AbstractStandalone;

use function assert;
use function implode;
use function in_array;

/**
 * Helper for setting and retrieving title element for HTML head.
 *
 * Duck-types against Laminas\I18n\Translator\TranslatorAwareInterface.
 *
 * @extends AbstractStandalone<int, string>
 * @method HeadTitle set(string $string)
 * @method HeadTitle prepend(string $string)
 * @method HeadTitle append(string $string)
 * @final
 */
class HeadTitle extends AbstractStandalone
{
    use TranslatorAwareTrait;

    /**
     * Default title rendering order (i.e. order in which each title attached)
     *
     * @var string|null
     */
    protected $defaultAttachOrder;

    /**
     * Retrieve placeholder for title element and optionally set state
     *
     * @param  string|null $title
     * @param  string|null $setType
     * @return HeadTitle
     */
    public function __invoke($title = null, $setType = null)
    {
        if (null === $setType) {
            $setType = $this->getDefaultAttachOrder()
                ?? AbstractContainer::APPEND;
        }

        $title = (string) $title;
        if ($title !== '') {
            if ($setType === AbstractContainer::SET) {
                $this->set($title);
            } elseif ($setType === AbstractContainer::PREPEND) {
                $this->prepend($title);
            } else {
                $this->append($title);
            }
        }

        return $this;
    }

    /**
     * Render title (wrapped by title tag)
     *
     * @param  string|null $indent
     * @return string
     */
    public function toString($indent = null)
    {
        $container = $this->getContainer();
        $indent    = null !== $indent
                ? $container->getWhitespace($indent)
                : $container->getIndent();

        $output = $this->renderTitle();

        return $indent . '<title>' . $output . '</title>';
    }

    /**
     * Render title string
     *
     * @return string
     */
    public function renderTitle()
    {
        $items = [];

        $itemCallback = $this->getTitleItemCallback();
        $container    = $this->getContainer();
        foreach ($container as $item) {
            $items[] = $itemCallback($item);
        }

        $separator = $container->getSeparator();
        $output    = '';

        $prefix = $container->getPrefix();
        if ($prefix) {
            $output .= $prefix;
        }

        $output .= implode($separator, $items);

        $postfix = $container->getPostfix();
        if ($postfix) {
            $output .= $postfix;
        }

        return $this->autoEscape ? $this->escape($output) : $output;
    }

    /**
     * Set a default order to add titles
     *
     * @param  string $setType
     * @throws Exception\DomainException
     * @return $this
     */
    public function setDefaultAttachOrder($setType)
    {
        if (
            ! in_array($setType, [
                AbstractContainer::APPEND,
                AbstractContainer::SET,
                AbstractContainer::PREPEND,
            ], true)
        ) {
            throw new Exception\DomainException(
                "You must use a valid attach order: 'PREPEND', 'APPEND' or 'SET'"
            );
        }
        $this->defaultAttachOrder = $setType;

        return $this;
    }

    /**
     * Get the default attach order, if any.
     *
     * @return string|null
     */
    public function getDefaultAttachOrder()
    {
        return $this->defaultAttachOrder;
    }

    /**
     * Create and return a callback for normalizing title items.
     *
     * If translation is not enabled, or no translator is present, returns a
     * callable that simply returns the provided item; otherwise, returns a
     * callable that returns a translation of the provided item.
     *
     * @return callable(string): string
     */
    private function getTitleItemCallback()
    {
        if (! $this->isTranslatorEnabled() || ! $this->hasTranslator()) {
            return static fn($item) => $item;
        }

        $translator = $this->getTranslator();
        assert($translator !== null);
        $textDomain = $this->getTranslatorTextDomain();
        return static fn($item) => $translator->translate($item, $textDomain);
    }
}
