<?php

declare(strict_types=1);

namespace Laminas\Test\PHPUnit\Controller;

use ArrayIterator;
use Laminas\Http\Header\HeaderInterface;
use Laminas\Test\PHPUnit\Constraint\HasRedirectConstraint;
use Laminas\Test\PHPUnit\Constraint\IsRedirectedRouteNameConstraint;
use PHPUnit\Framework\ExpectationFailedException;
use Symfony\Component\DomCrawler\Crawler;

use function count;
use function implode;
use function preg_match;
use function sprintf;

abstract class AbstractHttpControllerTestCase extends AbstractControllerTestCase
{
    /**
     * XPath namespaces
     *
     * @var array<string,string>
     */
    protected $xpathNamespaces = [];

    /**
     * Get response header by key
     *
     * @param  string $header
     * @return HeaderInterface|false
     */
    protected function getResponseHeader($header)
    {
        return $this->getResponse()->getHeaders()->get($header);
    }

    /**
     * Assert response has the given reason phrase
     *
     * @param string $phrase
     * @return void
     */
    public function assertResponseReasonPhrase($phrase)
    {
        $this->assertEquals($phrase, $this->getResponse()->getReasonPhrase());
    }

    /**
     * Assert response header exists
     *
     * @param string $header
     * @return void
     */
    public function assertHasResponseHeader($header)
    {
        $responseHeader = $this->getResponseHeader($header);
        if (false === $responseHeader) {
            throw new ExpectationFailedException($this->createFailureMessage(sprintf(
                'Failed asserting response header "%s" found',
                $header
            )));
        }
        $this->assertNotEquals(false, $responseHeader);
    }

    /**
     * Assert response header does not exist
     *
     * @param string $header
     * @return void
     */
    public function assertNotHasResponseHeader($header)
    {
        $responseHeader = $this->getResponseHeader($header);
        if (false !== $responseHeader) {
            throw new ExpectationFailedException($this->createFailureMessage(sprintf(
                'Failed asserting response header "%s" WAS NOT found',
                $header
            )));
        }
        $this->assertFalse($responseHeader);
    }

    /**
     * Assert response header exists and contains the given string
     *
     * @param string $header
     * @param string $match
     * @return void
     */
    public function assertResponseHeaderContains($header, $match)
    {
        $responseHeader = $this->getResponseHeader($header);
        if (! $responseHeader) {
            throw new ExpectationFailedException($this->createFailureMessage(sprintf(
                'Failed asserting response header, header "%s" doesn\'t exist',
                $header
            )));
        }

        if (! $responseHeader instanceof ArrayIterator) {
            $responseHeader = [$responseHeader];
        }

        $headerMatched = false;

        foreach ($responseHeader as $currentHeader) {
            if ($match === $currentHeader->getFieldValue()) {
                $headerMatched = true;
                break;
            }
        }

        if (! $headerMatched) {
            throw new ExpectationFailedException($this->createFailureMessage(sprintf(
                'Failed asserting response header "%s" exists and contains "%s", actual content is "%s"',
                $header,
                $match,
                $currentHeader->getFieldValue()
            )));
        }

        $this->assertEquals($match, $currentHeader->getFieldValue());
    }

    /**
     * Assert response header exists and contains the given string
     *
     * @param string $header
     * @param string $match
     * @return void
     */
    public function assertNotResponseHeaderContains($header, $match)
    {
        $responseHeader = $this->getResponseHeader($header);
        if (! $responseHeader) {
            throw new ExpectationFailedException($this->createFailureMessage(sprintf(
                'Failed asserting response header, header "%s" doesn\'t exist',
                $header
            )));
        }

        if (! $responseHeader instanceof ArrayIterator) {
            $responseHeader = [$responseHeader];
        }

        foreach ($responseHeader as $currentHeader) {
            if ($match === $currentHeader->getFieldValue()) {
                throw new ExpectationFailedException($this->createFailureMessage(sprintf(
                    'Failed asserting response header "%s" DOES NOT CONTAIN "%s"',
                    $header,
                    $match
                )));
            }
        }

        $this->assertNotEquals($match, $currentHeader->getFieldValue());
    }

    /**
     * Assert response header exists and matches the given pattern
     *
     * @param string $header
     * @param string $pattern
     * @return void
     */
    public function assertResponseHeaderRegex($header, $pattern)
    {
        $responseHeader = $this->getResponseHeader($header);
        if (! $responseHeader) {
            throw new ExpectationFailedException($this->createFailureMessage(sprintf(
                'Failed asserting response header, header "%s" doesn\'t exist',
                $header
            )));
        }

        if (! $responseHeader instanceof ArrayIterator) {
            $responseHeader = [$responseHeader];
        }

        $headerMatched = false;

        foreach ($responseHeader as $currentHeader) {
            $headerMatched = (bool) preg_match($pattern, $currentHeader->getFieldValue());

            if ($headerMatched) {
                break;
            }
        }

        if (! $headerMatched) {
            throw new ExpectationFailedException($this->createFailureMessage(sprintf(
                'Failed asserting response header "%s" exists and matches regex "%s", actual content is "%s"',
                $header,
                $pattern,
                $currentHeader->getFieldValue()
            )));
        }

        $this->assertTrue($headerMatched);
    }

    /**
     * Assert response header does not exist and/or does not match the given regex
     *
     * @param string $header
     * @param string $pattern
     * @return void
     */
    public function assertNotResponseHeaderRegex($header, $pattern)
    {
        $responseHeader = $this->getResponseHeader($header);
        if (! $responseHeader) {
            throw new ExpectationFailedException($this->createFailureMessage(sprintf(
                'Failed asserting response header, header "%s" doesn\'t exist',
                $header
            )));
        }

        if (! $responseHeader instanceof ArrayIterator) {
            $responseHeader = [$responseHeader];
        }

        $headerMatched = false;

        foreach ($responseHeader as $currentHeader) {
            $headerMatched = (bool) preg_match($pattern, $currentHeader->getFieldValue());

            if ($headerMatched) {
                throw new ExpectationFailedException($this->createFailureMessage(sprintf(
                    'Failed asserting response header "%s" DOES NOT MATCH regex "%s"',
                    $header,
                    $pattern
                )));
            }
        }

        $this->assertFalse($headerMatched);
    }

    /**
     * Assert that response is a redirect
     *
     * @return void
     */
    public function assertRedirect()
    {
        $responseHeader = $this->getResponseHeader('Location');
        if (false === $responseHeader) {
            throw new ExpectationFailedException($this->createFailureMessage(
                'Failed asserting response is a redirect'
            ));
        }
        $this->assertNotEquals(false, $responseHeader);
    }

    /**
     * Assert that response is NOT a redirect
     *
     * @return void
     */
    public function assertNotRedirect()
    {
        $responseHeader = $this->getResponseHeader('Location');
        if (false !== $responseHeader) {
            throw new ExpectationFailedException($this->createFailureMessage(sprintf(
                'Failed asserting response is NOT a redirect, actual redirection is "%s"',
                $responseHeader->getFieldValue()
            )));
        }
        $this->assertFalse($responseHeader);
    }

    /**
     * Assert that response redirects to given URL
     *
     * @param string $url
     * @return void
     */
    public function assertRedirectTo($url)
    {
        $responseHeader = $this->getResponseHeader('Location');
        if (! $responseHeader) {
            throw new ExpectationFailedException($this->createFailureMessage(
                'Failed asserting response is a redirect'
            ));
        }
        if ($url !== $responseHeader->getFieldValue()) {
            throw new ExpectationFailedException($this->createFailureMessage(sprintf(
                'Failed asserting response redirects to "%s", actual redirection is "%s"',
                $url,
                $responseHeader->getFieldValue()
            )));
        }
        $this->assertEquals($url, $responseHeader->getFieldValue());
    }

    /**
     * Assert that response does not redirect to given URL
     *
     * @param string $url
     * @return void
     */
    public function assertNotRedirectTo($url)
    {
        $responseHeader = $this->getResponseHeader('Location');
        if (! $responseHeader) {
            throw new ExpectationFailedException($this->createFailureMessage(
                'Failed asserting response is a redirect'
            ));
        }
        if ($url === $responseHeader->getFieldValue()) {
            throw new ExpectationFailedException($this->createFailureMessage(sprintf(
                'Failed asserting response redirects to "%s"',
                $url
            )));
        }
        $this->assertNotEquals($url, $responseHeader->getFieldValue());
    }

    /**
     * Assert that response redirects to given route
     */
    final public function assertRedirectToRoute(string $route): void
    {
        self::assertThat(
            $route,
            self::logicalAnd(
                new HasRedirectConstraint($this),
                new IsRedirectedRouteNameConstraint($this)
            )
        );
    }

    /**
     * Assert that response does not redirect to given route
     */
    final public function assertNotRedirectToRoute(string $route): void
    {
        self::assertThat(
            $route,
            self::logicalNot(
                self::logicalAnd(
                    new HasRedirectConstraint($this),
                    new IsRedirectedRouteNameConstraint($this)
                )
            )
        );
    }

    /**
     * Assert that redirect location matches pattern
     *
     * @param string $pattern
     * @return void
     */
    public function assertRedirectRegex($pattern)
    {
        $responseHeader = $this->getResponseHeader('Location');
        if (! $responseHeader) {
            throw new ExpectationFailedException($this->createFailureMessage(
                'Failed asserting response is a redirect'
            ));
        }
        if (! preg_match($pattern, $responseHeader->getFieldValue())) {
            throw new ExpectationFailedException($this->createFailureMessage(sprintf(
                'Failed asserting response redirects to URL MATCHING "%s", actual redirection is "%s"',
                $pattern,
                $responseHeader->getFieldValue()
            )));
        }
        $this->assertTrue((bool) preg_match($pattern, $responseHeader->getFieldValue()));
    }

    /**
     * Assert that redirect location does not match pattern
     *
     * @param string $pattern
     * @return void
     */
    public function assertNotRedirectRegex($pattern)
    {
        $responseHeader = $this->getResponseHeader('Location');
        if (! $responseHeader) {
            throw new ExpectationFailedException($this->createFailureMessage(
                'Failed asserting response is a redirect'
            ));
        }
        if (preg_match($pattern, $responseHeader->getFieldValue())) {
            throw new ExpectationFailedException($this->createFailureMessage(sprintf(
                'Failed asserting response DOES NOT redirect to URL MATCHING "%s"',
                $pattern
            )));
        }
        $this->assertFalse((bool) preg_match($pattern, $responseHeader->getFieldValue()));
    }

    /**
     * Register XPath namespaces
     *
     * @param array<string,string> $xpathNamespaces
     * @return void
     */
    public function registerXpathNamespaces(array $xpathNamespaces)
    {
        $this->xpathNamespaces = $xpathNamespaces;
    }

    /**
     * Execute a DOM/XPath query
     *
     * @param  string $path
     * @param  bool $useXpath
     * @return Crawler
     */
    private function query($path, $useXpath = false)
    {
        $response = $this->getResponse();
        $document = new Crawler($response->getContent());

        if ($useXpath) {
            foreach ($this->xpathNamespaces as $prefix => $namespace) {
                $document->registerNamespace($prefix, $namespace);
            }
        }

        return $useXpath ? $document->filterXPath($path) : $document->filter($path);
    }

    /**
     * Execute a xpath query
     *
     * @param string $path
     */
    private function xpathQuery($path): Crawler
    {
        return $this->query($path, true);
    }

    /**
     * Count the dom query executed
     *
     * @param  string $path
     * @return int
     */
    private function queryCount($path)
    {
        return count($this->query($path, false));
    }

    /**
     * Count the dom query executed
     *
     * @param  string $path
     * @return int
     */
    private function xpathQueryCount($path)
    {
        return $this->xpathQuery($path)->count();
    }

    /**
     * @param string $path
     * @param bool $useXpath
     */
    private function queryCountOrxpathQueryCount($path, $useXpath = false): int
    {
        if ($useXpath) {
            return $this->xpathQueryCount($path);
        }

        return $this->queryCount($path);
    }

    /**
     * Assert against DOM/XPath selection
     *
     * @param string $path
     * @param bool $useXpath
     */
    private function queryAssertion($path, $useXpath = false): void
    {
        $match = $this->queryCountOrxpathQueryCount($path, $useXpath);
        if (! $match > 0) {
            throw new ExpectationFailedException($this->createFailureMessage(sprintf(
                'Failed asserting node DENOTED BY %s EXISTS',
                $path
            )));
        }
        $this->assertTrue($match > 0);
    }

    /**
     * Assert against DOM selection
     *
     * @param string $path CSS selector path
     * @return void
     */
    public function assertQuery($path)
    {
        $this->queryAssertion($path, false);
    }

    /**
     * Assert against XPath selection
     *
     * @param string $path XPath path
     * @return void
     */
    public function assertXpathQuery($path)
    {
        $this->queryAssertion($path, true);
    }

    /**
     * Assert against DOM/XPath selection
     *
     * @param string $path CSS selector path
     * @param bool $useXpath
     */
    private function notQueryAssertion($path, $useXpath = false): void
    {
        $match = $this->queryCountOrxpathQueryCount($path, $useXpath);
        if ($match !== 0) {
            throw new ExpectationFailedException($this->createFailureMessage(sprintf(
                'Failed asserting node DENOTED BY %s DOES NOT EXIST',
                $path
            )));
        }
        $this->assertEquals(0, $match);
    }

    /**
     * Assert against DOM selection
     *
     * @param string $path CSS selector path
     * @return void
     */
    public function assertNotQuery($path)
    {
        $this->notQueryAssertion($path, false);
    }

    /**
     * Assert against XPath selection
     *
     * @param string $path XPath path
     * @return void
     */
    public function assertNotXpathQuery($path)
    {
        $this->notQueryAssertion($path, true);
    }

    /**
     * Assert against DOM/XPath selection; should contain exact number of nodes
     *
     * @param string $path CSS selector path
     * @param int $count Number of nodes that should match
     * @param bool $useXpath
     */
    private function queryCountAssertion($path, $count, $useXpath = false): void
    {
        $match = $this->queryCountOrxpathQueryCount($path, $useXpath);
        if ($match !== $count) {
            throw new ExpectationFailedException($this->createFailureMessage(sprintf(
                'Failed asserting node DENOTED BY %s OCCURS EXACTLY %d times, actually occurs %d times',
                $path,
                $count,
                $match
            )));
        }
        $this->assertEquals($match, $count);
    }

    /**
     * Assert against DOM selection; should contain exact number of nodes
     *
     * @param string $path CSS selector path
     * @param int $count Number of nodes that should match
     * @return void
     */
    public function assertQueryCount($path, $count)
    {
        $this->queryCountAssertion($path, $count, false);
    }

    /**
     * Assert against XPath selection; should contain exact number of nodes
     *
     * @param string $path XPath path
     * @param int $count Number of nodes that should match
     * @return void
     */
    public function assertXpathQueryCount($path, $count)
    {
        $this->queryCountAssertion($path, $count, true);
    }

    /**
     * Assert against DOM/XPath selection; should NOT contain exact number of nodes
     *
     * @param string $path CSS selector path
     * @param int $count Number of nodes that should NOT match
     * @param bool $useXpath
     */
    private function notQueryCountAssertion($path, $count, $useXpath = false): void
    {
        $match = $this->queryCountOrxpathQueryCount($path, $useXpath);
        if ($match === $count) {
            throw new ExpectationFailedException($this->createFailureMessage(sprintf(
                'Failed asserting node DENOTED BY %s DOES NOT OCCUR EXACTLY %d times',
                $path,
                $count
            )));
        }
        $this->assertNotEquals($match, $count);
    }

    /**
     * Assert against DOM selection; should NOT contain exact number of nodes
     *
     * @param string $path CSS selector path
     * @param int $count Number of nodes that should NOT match
     * @return void
     */
    public function assertNotQueryCount($path, $count)
    {
        $this->notQueryCountAssertion($path, $count, false);
    }

    /**
     * Assert against XPath selection; should NOT contain exact number of nodes
     *
     * @param string $path XPath path
     * @param int $count Number of nodes that should NOT match
     * @return void
     */
    public function assertNotXpathQueryCount($path, $count)
    {
        $this->notQueryCountAssertion($path, $count, true);
    }

    /**
     * Assert against DOM/XPath selection; should contain at least this number of nodes
     *
     * @param string $path CSS selector path
     * @param int $count Minimum number of nodes that should match
     * @param bool $useXpath
     */
    private function queryCountMinAssertion($path, $count, $useXpath = false): void
    {
        $match = $this->queryCountOrxpathQueryCount($path, $useXpath);
        if ($match < $count) {
            throw new ExpectationFailedException($this->createFailureMessage(sprintf(
                'Failed asserting node DENOTED BY %s OCCURS AT LEAST %d times, actually occurs %d times',
                $path,
                $count,
                $match
            )));
        }
        $this->assertTrue($match >= $count);
    }

    /**
     * Assert against DOM selection; should contain at least this number of nodes
     *
     * @param string $path CSS selector path
     * @param int $count Minimum number of nodes that should match
     * @return void
     */
    public function assertQueryCountMin($path, $count)
    {
        $this->queryCountMinAssertion($path, $count, false);
    }

    /**
     * Assert against XPath selection; should contain at least this number of nodes
     *
     * @param string $path XPath path
     * @param int $count Minimum number of nodes that should match
     * @return void
     */
    public function assertXpathQueryCountMin($path, $count)
    {
        $this->queryCountMinAssertion($path, $count, true);
    }

    /**
     * Assert against DOM/XPath selection; should contain no more than this number of nodes
     *
     * @param string $path CSS selector path
     * @param int $count Maximum number of nodes that should match
     * @param bool $useXpath
     */
    private function queryCountMaxAssertion($path, $count, $useXpath = false): void
    {
        $match = $this->queryCountOrxpathQueryCount($path, $useXpath);
        if ($match > $count) {
            throw new ExpectationFailedException($this->createFailureMessage(sprintf(
                'Failed asserting node DENOTED BY %s OCCURS AT MOST %d times, actually occurs %d times',
                $path,
                $count,
                $match
            )));
        }
        $this->assertTrue($match <= $count);
    }

    /**
     * Assert against DOM selection; should contain no more than this number of nodes
     *
     * @param string $path CSS selector path
     * @param int $count Maximum number of nodes that should match
     * @return void
     */
    public function assertQueryCountMax($path, $count)
    {
        $this->queryCountMaxAssertion($path, $count, false);
    }

    /**
     * Assert against XPath selection; should contain no more than this number of nodes
     *
     * @param string $path XPath path
     * @param int $count Maximum number of nodes that should match
     * @return void
     */
    public function assertXpathQueryCountMax($path, $count)
    {
        $this->queryCountMaxAssertion($path, $count, true);
    }

    /**
     * Assert against DOM/XPath selection; node should contain content
     *
     * @param string $path CSS selector path
     * @param string $match content that should be contained in matched nodes
     * @param bool $useXpath
     */
    private function queryContentContainsAssertion($path, $match, $useXpath = false): void
    {
        $result = $this->query($path, $useXpath);

        if ($result->count() === 0) {
            throw new ExpectationFailedException($this->createFailureMessage(sprintf(
                'Failed asserting node DENOTED BY %s EXISTS',
                $path
            )));
        }

        $nodeValues = [];

        foreach ($result as $node) {
            if ($node->nodeValue === $match) {
                $this->assertEquals($match, $node->nodeValue);
                return;
            }

            $nodeValues[] = $node->nodeValue;
        }

        throw new ExpectationFailedException($this->createFailureMessage(sprintf(
            'Failed asserting node denoted by %s CONTAINS content "%s", Contents: [%s]',
            $path,
            $match,
            implode(',', $nodeValues)
        )));
    }

    /**
     * Assert against DOM selection; node should contain content
     *
     * @param string $path CSS selector path
     * @param string $match content that should be contained in matched nodes
     * @return void
     */
    public function assertQueryContentContains($path, $match)
    {
        $this->queryContentContainsAssertion($path, $match, false);
    }

    /**
     * Assert against XPath selection; node should contain content
     *
     * @param string $path XPath path
     * @param string $match content that should be contained in matched nodes
     * @return void
     */
    public function assertXpathQueryContentContains($path, $match)
    {
        $this->queryContentContainsAssertion($path, $match, true);
    }

    /**
     * Assert against DOM/XPath selection; node should NOT contain content
     *
     * @param string $path CSS selector path
     * @param string $match content that should NOT be contained in matched nodes
     * @param bool $useXpath
     */
    private function notQueryContentContainsAssertion($path, $match, $useXpath = false): void
    {
        $result = $this->query($path, $useXpath);
        if ($result->count() === 0) {
            throw new ExpectationFailedException($this->createFailureMessage(sprintf(
                'Failed asserting node DENOTED BY %s EXISTS',
                $path
            )));
        }
        foreach ($result as $node) {
            if ($node->nodeValue === $match) {
                throw new ExpectationFailedException($this->createFailureMessage(sprintf(
                    'Failed asserting node DENOTED BY %s DOES NOT CONTAIN content "%s"',
                    $path,
                    $match
                )));
            }
        }
        $currentValue = $node->nodeValue;
        $this->assertNotEquals($currentValue, $match);
    }

    /**
     * Assert against DOM selection; node should NOT contain content
     *
     * @param string $path CSS selector path
     * @param string $match content that should NOT be contained in matched nodes
     * @return void
     */
    public function assertNotQueryContentContains($path, $match)
    {
        $this->notQueryContentContainsAssertion($path, $match, false);
    }

    /**
     * Assert against XPath selection; node should NOT contain content
     *
     * @param string $path XPath path
     * @param string $match content that should NOT be contained in matched nodes
     * @return void
     */
    public function assertNotXpathQueryContentContains($path, $match)
    {
        $this->notQueryContentContainsAssertion($path, $match, true);
    }

    /**
     * Assert against DOM/XPath selection; node should match content
     *
     * @param string $path CSS selector path
     * @param string $pattern Pattern that should be contained in matched nodes
     * @param bool $useXpath
     */
    private function queryContentRegexAssertion($path, $pattern, $useXpath = false): void
    {
        $result = $this->query($path, $useXpath);
        if ($result->count() === 0) {
            throw new ExpectationFailedException($this->createFailureMessage(sprintf(
                'Failed asserting node DENOTED BY %s EXISTS',
                $path
            )));
        }

        $found      = false;
        $nodeValues = [];

        foreach ($result as $node) {
            $nodeValues[] = $node->nodeValue;
            if (preg_match($pattern, (string) $node->nodeValue)) {
                $found = true;
                break;
            }
        }

        if (! $found) {
            throw new ExpectationFailedException($this->createFailureMessage(sprintf(
                'Failed asserting node denoted by %s CONTAINS content MATCHING "%s", actual content is "%s"',
                $path,
                $pattern,
                implode('', $nodeValues)
            )));
        }

        $this->assertTrue($found);
    }

    /**
     * Assert against DOM selection; node should match content
     *
     * @param string $path CSS selector path
     * @param string $pattern Pattern that should be contained in matched nodes
     * @return void
     */
    public function assertQueryContentRegex($path, $pattern)
    {
        $this->queryContentRegexAssertion($path, $pattern, false);
    }

    /**
     * Assert against XPath selection; node should match content
     *
     * @param string $path XPath path
     * @param string $pattern Pattern that should be contained in matched nodes
     * @return void
     */
    public function assertXpathQueryContentRegex($path, $pattern)
    {
        $this->queryContentRegexAssertion($path, $pattern, true);
    }

    /**
     * Assert against DOM/XPath selection; node should NOT match content
     *
     * @param string $path CSS selector path
     * @param string $pattern pattern that should NOT be contained in matched nodes
     * @param bool $useXpath
     */
    private function notQueryContentRegexAssertion($path, $pattern, $useXpath = false): void
    {
        $result = $this->query($path, $useXpath);
        if ($result->count() === 0) {
            throw new ExpectationFailedException($this->createFailureMessage(sprintf(
                'Failed asserting node DENOTED BY %s EXISTS',
                $path
            )));
        }
        $node      = $result->getNode(0);
        $nodeValue = $node ? $node->nodeValue : null;

        if ($nodeValue === null || preg_match($pattern, $nodeValue)) {
            throw new ExpectationFailedException($this->createFailureMessage(sprintf(
                'Failed asserting node DENOTED BY %s DOES NOT CONTAIN content MATCHING "%s"',
                $path,
                $pattern
            )));
        }
        $this->assertFalse((bool) preg_match($pattern, $nodeValue));
    }

    /**
     * Assert against DOM selection; node should NOT match content
     *
     * @param string $path CSS selector path
     * @param string $pattern pattern that should NOT be contained in matched nodes
     * @return void
     */
    public function assertNotQueryContentRegex($path, $pattern)
    {
        $this->notQueryContentRegexAssertion($path, $pattern, false);
    }

    /**
     * Assert against XPath selection; node should NOT match content
     *
     * @param string $path XPath path
     * @param string $pattern pattern that should NOT be contained in matched nodes
     * @return void
     */
    public function assertNotXpathQueryContentRegex($path, $pattern)
    {
        $this->notQueryContentRegexAssertion($path, $pattern, true);
    }
}
