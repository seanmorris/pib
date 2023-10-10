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

	const output = document.createElement('div');

	element.parentNode.insertBefore(output, element.nextSibling);

	let buffer = '';

	const php = new PhpWeb;

	php.addEventListener('output', (event) => buffer += event.detail);

	php.addEventListener('ready', () => {
		php.run(inlineCode).then(() => {
			output.innerHTML = buffer;
		});
	});

	php.addEventListener('error', (event) => {
			event.detail.forEach(error => {
			error = error.trim();
			if(error) console.log(error);
		})
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

export const runPhpTags = (doc) => {

	const phpSelector = 'script[type="text/php"]';

	const htmlNode = doc.body.parentElement;
	const observer = new MutationObserver((mutations, observer)=>{
		for(const mutation of mutations)
		{
			for(const addedNode of mutation.addedNodes)
			{
				if(!addedNode.matches || !addedNode.matches(phpSelector))
				{
					continue;
				}

				runPhpScriptTag(addedNode.innerText);
			}
		}
	});

	observer.observe(htmlNode, {childList: true, subtree: true});

	const phpNodes = doc.querySelectorAll(phpSelector);

	for(const phpNode of phpNodes)
	{
		const code = phpNode.innerText.trim();

		runPhpScriptTag(phpNode);
	}
}
