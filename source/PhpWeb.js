import { PhpBase } from './PhpBase';

const PhpBinary = require('./php-web');

export class PhpWeb extends PhpBase
{
	constructor(args = {})
	{
		super(PhpBinary, args);
	}
}

const runPhpScriptTag = element => {

	const tags = {stdin: null, stdout: null, stderr: null};

	if(element.hasAttribute('data-stdout'))
	{
		tags.stdout = document.querySelector(element.getAttribute('data-stdout'));
	}
	else
	{
		tags.stdout = document.createElement('div');

		element.parentNode.insertBefore(tags.output, element.nextSibling);
	}

	if(element.hasAttribute('data-stderr'))
	{
		tags.stderr = document.querySelector(element.getAttribute('data-stderr'));
	}

	if(element.hasAttribute('data-stdin'))
	{
		tags.stdin = document.querySelector(element.getAttribute('data-stdin'));
	}

	let stdout = '';
	let stderr = '';

	let getCode = Promise.resolve(element.innerText);

	if(element.hasAttribute('src'))
	{
		getCode = fetch(element.getAttribute('src')).then(response => response.text());
	}

	let getInput = Promise.resolve('');

	if(tags.stdin)
	{
		getInput = Promise.resolve(tags.stdin.innerText);

		if(tags.stdin.hasAttribute('src'))
		{
			getInput = fetch(tags.stdin.getAttribute('src')).then(response => response.text());
		}
	}

	const getAll = Promise.all([getCode, getInput]);

	getAll.then(([code, input,]) => {
		const php = new PhpWeb;

		php.inputString(input);

		const outListener = event => stdout += event.detail;
		const errListener = event => stderr += event.detail;

		php.addEventListener('output', outListener);
		php.addEventListener('error',  errListener);

		php.addEventListener('ready', () => {
			php.run(code)
			.then(exitCode => console.log(exitCode))
			.catch(error => console.warn(error))
			.finally(() => {
				php.flush();
				tags.stdout && (tags.stdout.innerHTML = stdout);
				tags.stderr && (tags.stderr.innerHTML = stderr);
				php.removeEventListener('output', outListener);
				php.removeEventListener('error',  errListener);
			});
		});

		// const observer = new MutationObserver((mutations, observer) => {
		// 	for(const mutation of mutations)
		// 	{
		// 		for(const addedNode of mutation.addedNodes)
		// 		{
		// 			console.log(addedNode);
		// 			// php.inputString(addedNode);
		// 			// php.run(code)
		// 			// .then(exitCode => console.log(exitCode))
		// 			// .catch(error => console.warn(error))
		// 			// .finally(() => {
		// 			// 	php.flush();
		// 			// 	tags.stdout && (tags.stdout.innerHTML = stdout);
		// 			// 	tags.stderr && (tags.stderr.innerHTML = stderr);
		// 			// 	php.removeEventListener('output', outListener);
		// 			// 	php.removeEventListener('error',  errListener);
		// 			// });
		// 		}
		// 	}
		// });

		// observer.observe(element, {childList: true, subtree: true});
	});
}

const phpSelector = 'script[type="text/php"]';

export const runPhpTags = (doc) => {

	const phpNodes = doc.querySelectorAll(phpSelector);

	for(const phpNode of phpNodes)
	{
		const code = phpNode.innerText.trim();

		runPhpScriptTag(phpNode);
	}

	const observer = new MutationObserver((mutations, observer) => {
		for(const mutation of mutations)
		{
			for(const addedNode of mutation.addedNodes)
			{
				if(!addedNode.matches || !addedNode.matches(phpSelector))
				{
					continue;
				}

				runPhpScriptTag(addedNode);
			}
		}
	});

	observer.observe(document.body.parentElement, {childList: true, subtree: true});
}

