import { PhpBase } from './PhpBase';

const PhpBinary = require('./php-web');

export class PhpWeb extends PhpBase
{
	constructor(args = {})
	{
		super(PhpBinary, args);
	}
}

const runPhpScript = element => {

	const inlineCode = element.innerText.trim();

	if(!inlineCode)
	{
		return;
	}

	const tags = {stdout: null, stderr: null};

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

	tags.stdin && php.inputString(tags.stdin.innerText);

	let stdout = '';
	let stderr = '';

	const php = new PhpWeb;

	const outListener = event => stdout += event.detail;
	const errListener = event => stderr += event.detail;

	php.addEventListener('output', outListener);
	php.addEventListener('error',  errListener);

	php.addEventListener('ready', () => {
		php.run(inlineCode).finally(() => {
			tags.stdout && (tags.stdout.innerHTML = stdout);
			tags.stderr && (tags.stderr.innerHTML = stderr);
			php.removeEventListener('output', outListener);
			php.removeEventListener('error',  errListener);
		});
	});
}

const runPhpScriptTag = element => {

	const src = element.getAttribute('src');

	if(src)
	{
		fetch(src).then(r => r.text()).then(r => {
			runPhpScript(r).then(exit=>console.log(exit));
		});

		return;
	}

	return runPhpScript(element);
};

const phpSelector = 'script[type="text/php"]';

export const runPhpTags = (doc) => {


	const phpNodes = doc.querySelectorAll(phpSelector);

	for(const phpNode of phpNodes)
	{
		const code = phpNode.innerText.trim();

		runPhpScriptTag(phpNode);
	}
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
