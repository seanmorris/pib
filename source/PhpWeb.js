import { PhpBase } from './PhpBase.js';

const PhpBinary = require('./php-web');

export class PhpWeb extends PhpBase
{
	constructor(args = {})
	{
		super(PhpBinary, args);
	}
}

if(globalThis.document)
{
	const php = new PhpWeb;

	const runScriptTag = element => {

		const src = element.getAttribute('src');

		if(src)
		{
			fetch(src).then(r => r.text()).then(r => {
				php.run(r).then(exit=>console.log(exit));
			});

			return;
		}

		const inlineCode = element.innerText.trim();

		if(inlineCode)
		{
			php.run(inlineCode);
		}

	};

	php.addEventListener('ready', () => {
		const phpSelector = 'script[type="text/php"]';

		const htmlNode = document.body.parentElement;
		const observer = new MutationObserver((mutations, observer)=>{
			for(const mutation of mutations)
			{
				for(const addedNode of mutation.addedNodes)
				{
					if(!addedNode.matches || !addedNode.matches(phpSelector))
					{
						continue;
					}

					runScriptTag(addedNode);
				}

			}
		});

		observer.observe(htmlNode, {childList: true, subtree: true});

		const phpNodes = document.querySelectorAll(phpSelector);

		for(const phpNode of phpNodes)
		{
			const code = phpNode.innerText.trim();

			runScriptTag(phpNode);
		}
	});

}
