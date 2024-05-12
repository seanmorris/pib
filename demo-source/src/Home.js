import './Common.css';
import './Home.css';
import phpPageIcon from './deepin-php-icon.svg';
import cakePhpIcon from './cakephp-icon.svg';
import drupalIcon from './drupal-icon.svg';
import codeIgniterIcon from './codeigniter-icon.svg';
import laravelIcon from './laravel-icon.svg';
import laminasIcon from './laminas-icon.svg';
import reactIcon from './react-icon.svg';

// import rolodexIcon from './icons/rolodex-icon-32.png';
import editorIcon from './icons/editor-icon-32.png';
import donateIcon from './icons/donate-icon-32.png';
import githubIcon from './icons/github-icon-32.png';

import { useEffect, useMemo, useState } from 'react';

function Home() {
	const [offset, setOffset] = useState(Math.trunc(Math.random() * 5));
	const [scrollState, setScrollState] = useState(1);

	const query = useMemo(() => new URLSearchParams(window.location.search), []);

	useEffect(() => {
		if(query.has('code') || query.has('demo'))
		{
			window.location = process.env.PUBLIC_URL + '/embedded' + window.location.search;
		}
	}, [query]);

	useEffect(() => {
		const speed = 1400;
		setTimeout(() => {
			if(offset >= 5)
			{
				setTimeout(() => {
					setScrollState(0);
					setOffset(0);
					setTimeout(() => {
						setScrollState(1);
						setOffset(1);
					}, 32);
				}, 16);
			}
			else
			{
				setScrollState(1);
				setOffset((offset + 1) % 6);
			}

		}, speed);

	}, [offset, scrollState]);

	return (
		<div className = "home">
			<div className='home-menu bevel'>
				<h1>Select a demo:</h1>
				<div className='row'>
					<a className = "big-link inset" href = {process.env.PUBLIC_URL + '/embedded'}>
						<div className = "big-icon embedded">
							<img alt = "page showing php logo" src = {phpPageIcon} />
						</div>
						<span className = "title">PHP Embedded Demo</span>
						<p className='padded'>View, edit & run PHP code right in the browser.</p>
					</a>
					<a className = "big-link inset" href = {process.env.PUBLIC_URL + '/select-framework'}>
						<div className = "big-icon cgi" style={{'--offset': offset}} data-scroll-state = {scrollState}>
							<div className = "offset-column">
								<img src = {cakePhpIcon} alt = "CakePHP logo" />
								<img src = {codeIgniterIcon} alt = "CodeIgniter logo" />
								<img src = {drupalIcon} alt = "Drupal logo" />
								<img src = {laminasIcon} alt = "Laminas logo" />
								<img src = {laravelIcon} alt = "Laravel logo" />
								<img src = {cakePhpIcon} alt = "CakePHP logo" />
							</div>
						</div>
						<span className = "title">PHP CGI Demo</span>
						<p className='padded'>Spin up a CGI service worker and serve a demo from the framework of your choice.</p>
					</a>
				</div>
				{/* <h2>Extras:</h2> */}
				<div className = "inset button-bar">
					<button onClick = {() => window.location = process.env.PUBLIC_URL + '/code-editor'}>
						<img src = {editorIcon} className = "icon" alt = "Code Editor" />
						Code Editor
					</button>
					{/* <button>
						<img src = {rolodexIcon} className = "icon" alt = "SQL Editor" />
						SQL Editor
					</button> */}
					<button onClick = {() => window.open('https://github.com/sponsors/seanmorris')}>
						<img src = {donateIcon} className = "icon" alt = "Donate" />
						Donate
					</button>
					<button onClick = {() => window.open('https://github.com/seanmorris/php-wasm?tab=readme-ov-file#-php-wasm')}>
						<img src = {githubIcon} className = "icon" alt = "Github" />
						Github
					</button>
				</div>
				<div className = "inset right demo-bar">
					<span>Demo powered by React</span> <img alt = "react-logo" src = {reactIcon} className='small-icon'/>
				</div>
			</div>
		</div>
	);
}

export default Home;
