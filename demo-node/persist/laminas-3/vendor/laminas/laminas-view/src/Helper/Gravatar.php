<?php

declare(strict_types=1);

namespace Laminas\View\Helper;

use Laminas\View\Exception;

use function is_string;
use function md5;
use function method_exists;
use function preg_match;
use function sprintf;
use function str_replace;
use function strtolower;
use function trigger_error;
use function trim;
use function ucwords;
use function urlencode;

use const E_USER_DEPRECATED;

/**
 * Helper for retrieving avatars from gravatar.com
 *
 * @deprecated This helper has been deprecated in favour of {@link GravatarImage} and will be removed in version 3.0
 */
class Gravatar extends AbstractHtmlElement
{
    /**
     * URL to gravatar service
     */
    public const GRAVATAR_URL = 'http://www.gravatar.com/avatar';
    /**
     * Secure URL to gravatar service
     */
    public const GRAVATAR_URL_SECURE = 'https://secure.gravatar.com/avatar';

    /**
     * Gravatar rating
     */
    public const RATING_G  = 'g';
    public const RATING_PG = 'pg';
    public const RATING_R  = 'r';
    public const RATING_X  = 'x';

    /**
     * Default gravatar image value constants
     */
    public const DEFAULT_404       = '404';
    public const DEFAULT_MM        = 'mm';
    public const DEFAULT_IDENTICON = 'identicon';
    public const DEFAULT_MONSTERID = 'monsterid';
    public const DEFAULT_WAVATAR   = 'wavatar';

    /**
     * Attributes for HTML image tag
     *
     * @var array<string, mixed>
     */
    protected $attributes;

    /**
     * Email Address
     *
     * @var string
     */
    protected $email;

    /**
     * True or false if the email address passed is already an MD5 hash
     *
     * @var bool
     */
    protected $emailIsHashed;

    /**
     * Options
     *
     * @var array<string, mixed>
     */
    protected $options = [
        'img_size'    => 80,
        'default_img' => self::DEFAULT_MM,
        'rating'      => self::RATING_G,
        'secure'      => null,
    ];

    /**
     * Returns an avatar from gravatar's service.
     *
     * $options may include the following:
     * - 'img_size' int height of img to return
     * - 'default_img' string img to return if email address has not found
     * - 'rating' string rating parameter for avatar
     * - 'secure' bool load from the SSL or Non-SSL location
     *
     * @see    http://pl.gravatar.com/site/implement/url
     * @see    http://pl.gravatar.com/site/implement/url More information about gravatar's service.
     *
     * @param  string|null $email Email address.
     * @param  array<string, mixed> $options Options
     * @param  array<string, mixed> $attributes Attributes for image tag (title, alt etc.)
     * @return Gravatar
     */
    public function __invoke($email = "", $options = [], $attributes = [])
    {
        if (is_string($email) && $email !== '') {
            $this->setEmail($email);
        }
        if (! empty($options)) {
            $this->setOptions($options);
        }
        if (! empty($attributes)) {
            $this->setAttributes($attributes);
        }

        return $this;
    }

    /**
     * Return valid image tag
     *
     * @return string
     */
    public function __toString()
    {
        return $this->getImgTag();
    }

    /**
     * Configure state
     *
     * @param  array<string, mixed> $options
     * @return Gravatar
     */
    public function setOptions(array $options)
    {
        foreach ($options as $key => $value) {
            $method = 'set' . str_replace(' ', '', ucwords(str_replace('_', ' ', $key)));
            if (method_exists($this, $method)) {
                $this->{$method}($value);
            }
        }

        return $this;
    }

    /**
     * Get avatar url (including size, rating and default image options)
     *
     * @return string
     */
    protected function getAvatarUrl()
    {
        return $this->getGravatarUrl()
            . '/' . ($this->emailIsHashed ? $this->getEmail() : md5($this->getEmail() ?: ''))
            . '?s=' . $this->getImgSize()
            . '&d=' . $this->getDefaultImg()
            . '&r=' . $this->getRating();
    }

    /**
     * Get URL to gravatar's service.
     *
     * @return string URL
     */
    protected function getGravatarUrl()
    {
        return $this->getSecure() === false ? self::GRAVATAR_URL : self::GRAVATAR_URL_SECURE;
    }

    /**
     * Return valid image tag
     *
     * @return string
     */
    public function getImgTag()
    {
        $this->setSrcAttribForImg();
        return '<img'
            . $this->htmlAttribs($this->getAttributes())
            . $this->getClosingBracket();
    }

    /**
     * Set attributes for image tag
     *
     * Warning! You shouldn't set src attribute for image tag.
     * This attribute is overwritten in protected method setSrcAttribForImg().
     * This method(_setSrcAttribForImg) is called in public method getImgTag().
     *
     * @param  array<string, mixed> $attributes
     * @return Gravatar
     */
    public function setAttributes(array $attributes)
    {
        $this->attributes = $attributes;
        return $this;
    }

    /**
     * Set attribs for image tag
     *
     * @deprecated Please use Laminas\View\Helper\Gravatar::setAttributes
     *
     * @param  array<string, mixed> $attribs
     * @return Gravatar
     */
    public function setAttribs(array $attribs)
    {
        trigger_error(sprintf(
            '%s is deprecated; please use %s::setAttributes',
            __METHOD__,
            self::class
        ), E_USER_DEPRECATED);

        $this->setAttributes($attribs);
        return $this;
    }

    /**
     * Get attributes of image
     *
     * Warning!
     * If you set src attribute, you get it, but this value will be overwritten in
     * protected method setSrcAttribForImg(). And finally your get other src
     * value!
     *
     * @return array<string, mixed>
     */
    public function getAttributes()
    {
        return $this->attributes;
    }

    /**
     * Get attribs of image
     *
     * Warning!
     * If you set src attrib, you get it, but this value will be overwritten in
     * protected method setSrcAttribForImg(). And finally your get other src
     * value!
     *
     * @deprecated Please use Laminas\View\Helper\Gravatar::getAttributes
     *
     * @return array<string, mixed>
     */
    public function getAttribs()
    {
        trigger_error(sprintf(
            '%s is deprecated; please use %s::getAttributes',
            __METHOD__,
            self::class
        ), E_USER_DEPRECATED);

        return $this->getAttributes();
    }

    /**
     * Set default img
     *
     * Can be either an absolute URL to an image, or one of the DEFAULT_* constants
     *
     * @link   http://pl.gravatar.com/site/implement/url More information about default image.
     *
     * @param  string $defaultImg
     * @return Gravatar
     */
    public function setDefaultImg($defaultImg)
    {
        $this->options['default_img'] = urlencode($defaultImg);
        return $this;
    }

    /**
     * Get default img
     *
     * @return string
     */
    public function getDefaultImg()
    {
        return $this->options['default_img'];
    }

    /**
     * Set email address
     *
     * @param  string $email
     * @return Gravatar
     */
    public function setEmail($email)
    {
        $this->emailIsHashed = (bool) preg_match('/^[A-Za-z0-9]{32}$/', $email);
        $this->email         = strtolower(trim($email));
        return $this;
    }

    /**
     * Get email address
     *
     * @return string
     */
    public function getEmail()
    {
        return $this->email;
    }

    /**
     * Set img size in pixels
     *
     * @param  int $imgSize Size of img must be between 1 and 512
     * @return Gravatar
     */
    public function setImgSize($imgSize)
    {
        $this->options['img_size'] = (int) $imgSize;
        return $this;
    }

    /**
     * Get img size
     *
     * @return int The img size
     */
    public function getImgSize()
    {
        return $this->options['img_size'];
    }

    /**
     *  Set rating value
     *
     * Must be one of the RATING_* constants
     *
     * @link   http://pl.gravatar.com/site/implement/url More information about rating.
     *
     * @param  string $rating Value for rating. Allowed values are: g, px, r,x
     * @return Gravatar
     * @throws Exception\DomainException
     */
    public function setRating($rating)
    {
        switch ($rating) {
            case self::RATING_G:
            case self::RATING_PG:
            case self::RATING_R:
            case self::RATING_X:
                $this->options['rating'] = $rating;
                break;
            default:
                throw new Exception\DomainException(sprintf(
                    'The rating value "%s" is not allowed',
                    $rating
                ));
        }

        return $this;
    }

    /**
     * Get rating value
     *
     * @return string
     */
    public function getRating()
    {
        return $this->options['rating'];
    }

    /**
     * Load from an SSL or No-SSL location?
     *
     * @param  bool $flag
     * @return Gravatar
     */
    public function setSecure($flag)
    {
        $this->options['secure'] = $flag === null ? null : (bool) $flag;
        return $this;
    }

    /**
     * Get an SSL or a No-SSL location
     *
     * @return bool
     */
    public function getSecure()
    {
        if ($this->options['secure'] === null) {
            return isset($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off';
        }

        return $this->options['secure'];
    }

    /**
     * Set src attrib for image.
     *
     * You shouldn't set an own url value!
     * It sets value, uses protected method getAvatarUrl.
     *
     * If already exists, it will be overwritten.
     *
     * @return void
     */
    protected function setSrcAttribForImg()
    {
        $attributes        = $this->getAttributes();
        $attributes['src'] = $this->getAvatarUrl();
        $this->setAttributes($attributes);
    }
}
