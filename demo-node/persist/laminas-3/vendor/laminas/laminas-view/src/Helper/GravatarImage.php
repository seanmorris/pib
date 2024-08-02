<?php

declare(strict_types=1);

namespace Laminas\View\Helper;

use Laminas\Escaper\Escaper;
use Laminas\View\HtmlAttributesSet;

use function md5;
use function sprintf;
use function strtolower;
use function trim;

/**
 * @psalm-import-type AttributeSet from HtmlAttributesSet
 */
final class GravatarImage
{
    private const GRAVATAR_URL = '//www.gravatar.com/avatar';

    /**
     * RATING_* constants describe the "rating" of the avatar image that is most suitable for your audience.
     *
     * @link https://en.gravatar.com/site/implement/images/#rating
     */
    public const RATING_G  = 'g';
    public const RATING_PG = 'pg';
    public const RATING_R  = 'r';
    public const RATING_X  = 'x';

    /**
     * DEFAULT_* constants describe the fallback image type that will be displayed when a profile does not exist.
     *
     * @link https://en.gravatar.com/site/implement/images/#default-image
     */
    public const DEFAULT_404       = '404';
    public const DEFAULT_MP        = 'mp';
    public const DEFAULT_IDENTICON = 'identicon';
    public const DEFAULT_MONSTERID = 'monsterid';
    public const DEFAULT_WAVATAR   = 'wavatar';
    public const DEFAULT_RETRO     = 'retro';
    public const DEFAULT_ROBOHASH  = 'robohash';
    public const DEFAULT_BLANK     = 'blank';

    public const RATINGS = [
        self::RATING_G,
        self::RATING_PG,
        self::RATING_R,
        self::RATING_X,
    ];

    public const DEFAULT_IMAGE_VALUES = [
        self::DEFAULT_404,
        self::DEFAULT_MP,
        self::DEFAULT_IDENTICON,
        self::DEFAULT_MONSTERID,
        self::DEFAULT_WAVATAR,
        self::DEFAULT_RETRO,
        self::DEFAULT_ROBOHASH,
        self::DEFAULT_BLANK,
    ];

    private Escaper $escaper;

    public function __construct(?Escaper $escaper = null)
    {
        $this->escaper = $escaper ?: new Escaper();
    }

    /**
     * @param non-empty-string                                  $emailAddress
     * @param positive-int                                      $imageSize
     * @param AttributeSet                                      $imageAttributes
     * @psalm-param value-of<self::DEFAULT_IMAGE_VALUES>|string $defaultImage
     * @psalm-param value-of<self::RATINGS>                     $rating
     */
    public function __invoke(
        string $emailAddress,
        int $imageSize = 80,
        array $imageAttributes = [],
        string $defaultImage = self::DEFAULT_MP,
        string $rating = self::RATING_G
    ): string {
        $imageAttributes['width'] = $imageAttributes['height'] = $imageSize;
        $imageAttributes['alt']   = $imageAttributes['alt'] ?? '';
        $imageAttributes['src']   = sprintf(
            '%s/%s?s=%d&r=%s&d=%s',
            self::GRAVATAR_URL,
            md5(strtolower(trim($emailAddress))),
            $imageSize,
            $rating,
            $this->escaper->escapeUrl($defaultImage)
        );

        return sprintf(
            '<img%s />',
            (string) new HtmlAttributesSet($this->escaper, $imageAttributes)
        );
    }
}
