import './Common.css';
import './SelectFramework.css';
import cakePhpIcon from './cakephp-icon.svg';
import drupalIcon from './drupal-icon.svg';
import codeIgniterIcon from './codeigniter-icon.svg';
import laravelIcon from './laravel-icon.svg';
import laminasIcon from './laminas-icon.svg';
import { useEffect, useState } from 'react';
import Header from './Header';
import { onMessage, sendMessage } from './msg-bus';
import reactIcon from './react-icon.svg';

function SelectFramework() {

	const [cakeInstalled, setCakeInstalled] = useState(false);
	const [codeigniterInstalled, setCodeigniterInstalled] = useState(false);
	const [drupalInstalled, setDrupalInstalled] = useState(false);
	const [laravelInstalled, setLaravelInstalled] = useState(false);
	const [laminasInstalled, setLaminasInstalled] = useState(false);

	sendMessage('analyzePath', ['/persist/cakephp-5']).then(about => setCakeInstalled(about.exists));
	sendMessage('analyzePath', ['/persist/codeigniter-4']).then(about => setCodeigniterInstalled(about.exists));
	sendMessage('analyzePath', ['/persist/drupal-7.95']).then(about => setDrupalInstalled(about.exists));
	sendMessage('analyzePath', ['/persist/laravel-11']).then(about => setLaravelInstalled(about.exists));
	sendMessage('analyzePath', ['/persist/laminas-3']).then(about => setLaminasInstalled(about.exists));

	const onComplete = event => {
		console.log(event.detail);
		sendMessage('analyzePath', ['/persist/cakephp-5']).then(about => setCakeInstalled(about.exists));
		sendMessage('analyzePath', ['/persist/codeigniter-4']).then(about => setCodeigniterInstalled(about.exists));
		sendMessage('analyzePath', ['/persist/drupal-7.95']).then(about => setDrupalInstalled(about.exists));
		sendMessage('analyzePath', ['/persist/laravel-11']).then(about => setLaravelInstalled(about.exists));
		sendMessage('analyzePath', ['/persist/laminas-3']).then(about => setLaminasInstalled(about.exists));
	}

	useEffect(() => {
		window.addEventListener('install-complete', onComplete);
		navigator.serviceWorker.addEventListener('message', onMessage);
		return () => {
			window.removeEventListener('install-complete', onComplete);
			navigator.serviceWorker.removeEventListener('message', onMessage);
		}
	}, []);

	return (
		<div className = "select-framework">
			<div className='framework-menu bevel'>
				<Header />
				<div className='frameworks'>
					<h2>Select a Framework:</h2>
					<div className='inset row icons'>
						<div className='column center'>
							<a onClick = { () => window.open(process.env.PUBLIC_URL + '/load-demo?framework=cakephp-5')}>
								<img src = {cakePhpIcon} alt = "cakephp 5" />
							</a>
							{cakeInstalled && (<span className = "contents">
								<button onClick = { () => window.open(process.env.PUBLIC_URL + '/php-wasm/cgi-bin/cakephp-5')}>Open Demo</button>
								<button onClick = { () => window.open(process.env.PUBLIC_URL + '/code-editor?path=/persist/cakephp-5')}>IDE</button>
								<button onClick = { () => window.open(process.env.PUBLIC_URL + '/load-demo?framework=cakephp-5&overwrite=true')}>Reset</button>
							</span>)}
							{cakeInstalled || (<span className = "contents">
								<button onClick = { () => window.open(process.env.PUBLIC_URL + '/load-demo?framework=cakephp-5')}>Start</button>
							</span>)}
						</div>
						<div className='column center'>
							<a onClick = { () => window.open(process.env.PUBLIC_URL + '/load-demo?framework=codeigniter-4')}>
								<img src = {codeIgniterIcon} alt = "codeigniter 4" />
							</a>
							{codeigniterInstalled && (<span className = "contents">
								<button onClick = { () => window.open(process.env.PUBLIC_URL + '/php-wasm/cgi-bin/codeigniter-4')}>Open Demo</button>
								<button onClick = { () => window.open(process.env.PUBLIC_URL + '/code-editor?path=/persist/codeigniter-4')}>IDE</button>
								<button onClick = { () => window.open(process.env.PUBLIC_URL + '/load-demo?framework=codeigniter-4&overwrite=true')}>Reset</button>
							</span>)}
							{codeigniterInstalled || (<span className = "contents">
								<button onClick = { () => window.open(process.env.PUBLIC_URL + '/load-demo?framework=codeigniter-4')}>Start</button>
							</span>)}
						</div>
						<div className='column center'>
							<a onClick = { () => window.open(process.env.PUBLIC_URL + '/load-demo?framework=drupal-7')}>
								<img src = {drupalIcon} alt = "drupal 7" /> {drupalInstalled}
							</a>
							{drupalInstalled && (<span className = "contents">
								<button onClick = { () => window.open(process.env.PUBLIC_URL + '/php-wasm/cgi-bin/drupal')}>Open Demo</button>
								<button onClick = { () => window.open(process.env.PUBLIC_URL + '/code-editor?path=/persist/drupal-7.95')}>IDE</button>
								<button onClick = { () => window.open(process.env.PUBLIC_URL + '/load-demo?framework=drupal-7&overwrite=true')}>Reset</button>
							</span>)}
							{drupalInstalled || (<span className = "contents">
								<button onClick = { () => window.open(process.env.PUBLIC_URL + '/load-demo?framework=drupal-7')}>Start</button>
							</span>)}
						</div>
						<div className='column center'>
							<a onClick = { () => window.open(process.env.PUBLIC_URL + '/load-demo?framework=laravel-11')}>
								<img src = {laravelIcon} alt = "laravel 11" />
							</a>
							{laravelInstalled && (<span className = "contents">
								<button onClick = { () => window.open(process.env.PUBLIC_URL + '/php-wasm/cgi-bin/laravel-11')}>Open Demo</button>
								<button onClick = { () => window.open(process.env.PUBLIC_URL + '/code-editor?path=/persist/laravel-11')}>IDE</button>
								<button onClick = { () => window.open(process.env.PUBLIC_URL + '/load-demo?framework=laravel-11&overwrite=true')}>Reset</button>
							</span>)}
							{laravelInstalled || (<span className = "contents">
								<button onClick = { () => window.open(process.env.PUBLIC_URL + '/load-demo?framework=laravel-11')}>Start</button>
							</span>)}
						</div>
						<div className='column center'>
							<a onClick = { () => window.open(process.env.PUBLIC_URL + '/load-demo?framework=laminas-3')} >
								<img src = {laminasIcon} alt = "laminas 3" />
							</a>
							{laminasInstalled && (<span className = "contents">
								<button onClick = { () => window.open(process.env.PUBLIC_URL + '/php-wasm/cgi-bin/laminas-3')}>Open Demo</button>
								<button onClick = { () => window.open(process.env.PUBLIC_URL + '/code-editor?path=/persist/laminas-3')}>IDE</button>
								<button onClick = { () => window.open(process.env.PUBLIC_URL + '/load-demo?framework=laminas-3&overwrite=true')}>Reset</button>
							</span>)}
							{laminasInstalled || (<span className = "contents">
								<button onClick = { () => window.open(process.env.PUBLIC_URL + '/load-demo?framework=laminas-3')}>Start</button>
							</span>)}
						</div>
					</div>
				</div>
				<div className = "inset right demo-bar">
					<span>Demo powered by React</span> <img src = {reactIcon} className='small-icon'/>
				</div>
			</div>
		</div>
	);
}

export default SelectFramework;
