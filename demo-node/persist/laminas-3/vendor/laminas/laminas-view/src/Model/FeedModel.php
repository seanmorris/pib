<?php

declare(strict_types=1);

namespace Laminas\View\Model;

use Laminas\Feed\Writer\Feed;
use Laminas\Feed\Writer\FeedFactory;

/**
 * Marker view model for indicating feed data.
 */
class FeedModel extends ViewModel
{
    /** @var Feed */
    protected $feed;

    /** @var false|string */
    protected $type = false;

    /**
     * A feed is always terminal
     *
     * @var bool
     */
    protected $terminate = true;

    /**
     * @return Feed
     */
    public function getFeed()
    {
        if ($this->feed instanceof Feed) {
            return $this->feed;
        }

        if ($this->type === false) {
            $options = $this->getOptions();
            if (isset($options['feed_type'])) {
                $this->type = $options['feed_type'];
            }
        }

        $variables = $this->getVariables();
        $feed      = FeedFactory::factory($variables);
        $this->setFeed($feed);

        return $this->feed;
    }

    /**
     * Set the feed object
     *
     * @return FeedModel
     */
    public function setFeed(Feed $feed)
    {
        $this->feed = $feed;
        return $this;
    }

    /**
     * Get the feed type
     *
     * @return false|string
     */
    public function getFeedType()
    {
        if ($this->type === false) {
            return $this->type;
        }

        $options = $this->getOptions();
        if (isset($options['feed_type'])) {
            $this->type = $options['feed_type'];
        }
        return $this->type;
    }
}
