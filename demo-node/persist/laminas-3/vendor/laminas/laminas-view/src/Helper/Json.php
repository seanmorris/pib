<?php

declare(strict_types=1);

namespace Laminas\View\Helper;

use Laminas\Http\Response;
use Laminas\Json\Json as JsonFormatter;

use function trigger_error;

use const E_USER_DEPRECATED;

/**
 * Helper for simplifying JSON responses
 *
 * @psalm-suppress DeprecatedProperty
 * @final
 */
class Json extends AbstractHelper
{
    use DeprecatedAbstractHelperHierarchyTrait;

    /**
     * @deprecated since >= 2.20.0
     *
     * @var Response
     */
    protected $response;

    /**
     * Encode data as JSON and set response header
     *
     * @param  mixed $data
     * @param  array $jsonOptions Options to pass to JsonFormatter::encode()
     * @return string|void
     */
    public function __invoke($data, array $jsonOptions = [])
    {
        if (isset($jsonOptions['enableJsonExprFinder']) && $jsonOptions['enableJsonExprFinder'] === true) {
            trigger_error(
                'Json Expression functionality is deprecated and will be removed in laminas-view 3.0',
                E_USER_DEPRECATED
            );
        }

        $data = JsonFormatter::encode($data, null, $jsonOptions);

        if ($this->response instanceof Response) {
            $headers = $this->response->getHeaders();
            $headers->addHeaderLine('Content-Type', 'application/json');
        }

        return $data;
    }

    /**
     * Set the response object
     *
     * @deprecated since >= 2.20.0. If you need to set response headers, use the methods available in
     *             the framework. For example in Laminas MVC this can be achieved in the controller or in
     *             Mezzio, you can change response headers in Middleware. This method will be removed in 3.0
     *             without replacement functionality.
     *
     * @return Json
     */
    public function setResponse(Response $response)
    {
        $this->response = $response;
        return $this;
    }
}
