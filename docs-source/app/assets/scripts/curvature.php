<?php // {"autorun":true, "persist":true, "single-expression": false, "render-as": "text"}

$window = $window ?? new Vrzno;

$require = $window->require;

$View = $require('curvature/base/View')->View;

$view = $View->from('
	<div style = "display:flex;flex-direction:row;margin:auto;">

		<div style = "margin-right:1rem">
			<p>Counter</p>

			<div style = "display:flex;flex-direction:row;margin:1rem auto;min-width:4rem;">
				<button cv-on = "click:dec" style = "flex:1">-</button>
				<button cv-on = "click:inc" style = "flex:1">+</button>
			</div>

			<div style = "font-size:6rem;">[[foo]]</div>
		</div>

		<div style = "margin-right:1rem">
			<p>Form</p>
			<p><input cv-bind = "textVal"></p>
			<p>[[textVal]]</p>
		</div>

	</div>
');

$view->args->foo = 0;
$view->args->textVal = "Change me!";

$view->inc = fn() => $view->args->foo++;
$view->dec = fn() => $view->args->foo--;

$view->args->bindTo('textVal', function($value = null) {
	var_dump($value);
});

$view->render($window->document->body);

$window->view = $view;
