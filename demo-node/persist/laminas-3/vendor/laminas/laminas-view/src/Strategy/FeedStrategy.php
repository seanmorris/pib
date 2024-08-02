<?php

declare(strict_types=1);

namespace Laminas\View\Strategy;

use Laminas\EventManager\AbstractListenerAggregate;
use Laminas\EventManager\EventManagerInterface;
use Laminas\Feed\Writer\Feed;
use Laminas\View\Model;
use Laminas\View\Renderer\FeedRenderer;
use Laminas\View\ViewEvent;

use function is_string;

class FeedStrategy extends AbstractListenerAggregate
{
    /** @var FeedRenderer */
    protected $renderer;

    public function __construct(FeedRenderer $renderer)
    {
        $this->renderer = $renderer;
    }

    /**
     * {@inheritDoc}
     *
     * @param int $priority
     */
    public function attach(EventManagerInterface $events, $priority = 1)
    {
        $this->listeners[] = $events->attach(ViewEvent::EVENT_RENDERER, [$this, 'selectRenderer'], $priority);
        $this->listeners[] = $events->attach(ViewEvent::EVENT_RESPONSE, [$this, 'injectResponse'], $priority);
    }

    /**
     * Detect if we should use the FeedRenderer based on model type
     *
     * @return null|FeedRenderer
     */
    public function selectRenderer(ViewEvent $e)
    {
        $model = $e->getModel();

        if (! $model instanceof Model\FeedModel) {
            // no FeedModel present; do nothing
            return;
        }

        // FeedModel found
        return $this->renderer;
    }

    /**
     * Inject the response with the feed payload and appropriate Content-Type header
     *
     * @return void
     */
    public function injectResponse(ViewEvent $e)
    {
        /** @var FeedRenderer $renderer */
        $renderer = $e->getRenderer();
        if ($renderer !== $this->renderer) {
            // Discovered renderer is not ours; do nothing
            return;
        }

        $result = $e->getResult();
        if (! is_string($result) && ! $result instanceof Feed) {
            // We don't have a string, and thus, no feed
            return;
        }

        // If the result is a feed, export it
        if ($result instanceof Feed) {
            $result = $result->export($renderer->getFeedType());
        }

        // Get the content-type header based on feed type
        $feedType = $renderer->getFeedType();
        $feedType = 'rss' === $feedType
                  ? 'application/rss+xml'
                  : 'application/atom+xml';

        $model   = $e->getModel();
        $charset = '';

        if ($model instanceof Model\FeedModel) {
            $feed = $model->getFeed();

            $charset = '; charset=' . (string) $feed->getEncoding() . ';';
        }

        // Populate response
        $response = $e->getResponse();
        $response->setContent($result);
        $headers = $response->getHeaders();
        $headers->addHeaderLine('content-type', $feedType . $charset);
    }
}
