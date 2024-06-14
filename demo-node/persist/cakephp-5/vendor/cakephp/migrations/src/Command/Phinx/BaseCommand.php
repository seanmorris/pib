<?php
declare(strict_types=1);

namespace Migrations\Command\Phinx;

use Symfony\Component\Console\Command\Command;

abstract class BaseCommand extends Command
{
    public const CODE_SUCCESS = 0;
    public const CODE_ERROR = 1;
}
