<?php

namespace Psr\Container {
    interface ContainerInterface
    {
        /**
         * @psalm-template T of object
         * @psalm-param class-string<T>|string $id
         * @return (
         *      $id is class-string<T>
         *      ? T
         *      : mixed
         * )
         */
        public function get(string $id): mixed;
    }
}
