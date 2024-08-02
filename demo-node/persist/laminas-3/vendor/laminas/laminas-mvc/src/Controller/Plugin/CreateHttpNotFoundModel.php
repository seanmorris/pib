<?php

namespace Laminas\Mvc\Controller\Plugin;

use Laminas\Http\Response;
use Laminas\View\Model\ViewModel;

class CreateHttpNotFoundModel extends AbstractPlugin
{
    /**
     * Create an HTTP view model representing a "not found" page
     *
     *
     * @return ViewModel
     */
    public function __invoke(Response $response)
    {
        $response->setStatusCode(404);

        return new ViewModel(['content' => 'Page not found']);
    }
}
