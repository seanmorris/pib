import './Common.css';
import './Home.css';
import phpPageIcon from './deepin-php-icon.svg';
import cakePhpIcon from './cakephp-icon.svg';
import drupalIcon from './drupal-icon.svg';
import codeIgniterIcon from './codeigniter-icon.svg';
import laravelIcon from './laravel-icon.svg';
import laminasIcon from './laminas-icon.svg';
import reactIcon from './react-icon.svg';

import floppyIcon from './icons/floppy-icon-32.png';
import rolodexIcon from './icons/rolodex-icon-32.png';
import editorIcon from './icons/editor-icon-32.png';
import nukeIcon from './icons/nuke-icon-32.png';
import donateIcon from './icons/donate-icon-32.png';
import githubIcon from './icons/github-icon-32.png';
import cabinetIcon from './icons/file-cabinet-icon-32.png';

import { useEffect, useState } from 'react';

function Home() {

	const [offset, setOffset] = useState(Math.trunc(Math.random() * 5));
	const [scrollState, setScrollState] = useState(1);

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
					<a className = "big-link inset" href = "/embedded">
						<div className = "big-icon embedded">
							<img src = {phpPageIcon} />
						</div>
						<span className = "title">PHP Embedded Demo</span>
						<p>View, edit & run PHP code right in the browser.</p>
					</a>
					<a className = "big-link inset" href = "/select-framework">
						<div className = "big-icon cgi" style={{'--offset': offset}} data-scroll-state = {scrollState}>
							<div class = "offset-column">
								<img src = {cakePhpIcon} alt = "CakePHP" />
								<img src = {codeIgniterIcon} alt = "CodeIgniter" />
								<img src = {drupalIcon} alt = "Drupal" />
								<img src = {laravelIcon} alt = "Laravel" />
								<img src = {laminasIcon} alt = "Laminas" />
								<img src = {cakePhpIcon} alt = "CakePHP" />
							</div>
						</div>
						<span className = "title">PHP CGI Demo</span>
						<p>Spin up a CGI service worker and serve a demo from the framework of your choice.</p>
					</a>
				</div>
				<h2>Extras:</h2>
				<div className = "inset button-bar">
					<button onClick = {() => window.location = '/code-editor'}>
						<img src = {editorIcon} class = "icon" />
						Code Editor
					</button>
					<button>
						<img src = {rolodexIcon} class = "icon" />
						SQL Editor
					</button>
					<button>
						<img src = {donateIcon} class = "icon" />
						Donate
					</button>
					<button>
						<img src = {githubIcon} class = "icon" />
						Github
					</button>
				</div>
				<h2>Filesystem Operations:</h2>
				<div className = "inset button-bar">
					<button>
						<img src = {cabinetIcon} class = "icon" />
						Backup
					</button>
					<button>
						<img src = {floppyIcon} class = "icon" />
						Restore
						</button>
					<button>
						<img src = {nukeIcon} class = "icon" />
						Clear
					</button>
				</div>
				<div className = "inset right demo-bar">
					<span>Demo powered by React</span> <img src = {reactIcon} className='small-icon'/>
				</div>
			</div>
		</div>
	);
}

export default Home;
