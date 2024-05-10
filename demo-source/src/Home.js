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
// import rolodexIcon from './icons/rolodex-icon-32.png';
import editorIcon from './icons/editor-icon-32.png';
import nukeIcon from './icons/nuke-icon-32.png';
import donateIcon from './icons/donate-icon-32.png';
import githubIcon from './icons/github-icon-32.png';
import cabinetIcon from './icons/file-cabinet-icon-32.png';

import { useEffect, useState } from 'react';

import { Backup, Clear, Restore } from './Filesystem';
import Confirm from './Confirm';
import DoWithFile from './DoWithFile';
import ErrorDialog from './ErrorDialog';

function Home() {
	const [offset, setOffset] = useState(Math.trunc(Math.random() * 5));
	const [overlay, setOverlay] = useState(null);
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

	const backupSite = () => setOverlay(<Backup
		onComplete = { () => setOverlay(null) }
		onError = { (error) => setOverlay(<ErrorDialog message = {JSON.stringify(error)} onConfirm = { () => setOverlay(null) } />)}
	/>);

	const restoreSite = () => setOverlay(<DoWithFile
		onConfirm = { fileInput => setOverlay(<Restore
			fileInput = {fileInput}
			onComplete = { () => setOverlay(null) }
			onError = { (error) => setOverlay(<ErrorDialog message = {JSON.stringify(error)} onConfirm = { () => setOverlay(null) } />)}
		/>) }
		onCancel = { () => setOverlay(null) }
		message = {(
			<span>Select a zip file to restore from.</span>
		)}
	/>);

	const clearFilesystem = () => setOverlay(<Confirm
		onConfirm = { () => setOverlay(<Clear onComplete = { () => setOverlay(null) } />) }
		onCancel = { () => setOverlay(null) }
		message = {(
			<span>Are you sure you want to clear the filesystem? <b>Reminder:</b> This cannot be undone, you should take a backup first.</span>
		)}
	/>);

	return (
		<div className = "home">
			<div className='home-menu bevel'>
				<h1>Select a demo:</h1>
				<div className='row'>
					<a className = "big-link inset" href = {process.env.PUBLIC_URL + '/embedded'}>
						<div className = "big-icon embedded">
							<img src = {phpPageIcon} />
						</div>
						<span className = "title">PHP Embedded Demo</span>
						<p className='padded'>View, edit & run PHP code right in the browser.</p>
					</a>
					<a className = "big-link inset" href = {process.env.PUBLIC_URL + '/select-framework'}>
						<div className = "big-icon cgi" style={{'--offset': offset}} data-scroll-state = {scrollState}>
							<div className = "offset-column">
								<img src = {cakePhpIcon} alt = "CakePHP" />
								<img src = {codeIgniterIcon} alt = "CodeIgniter" />
								<img src = {drupalIcon} alt = "Drupal" />
								<img src = {laminasIcon} alt = "Laminas" />
								<img src = {laravelIcon} alt = "Laravel" />
								<img src = {cakePhpIcon} alt = "CakePHP" />
							</div>
						</div>
						<span className = "title">PHP CGI Demo</span>
						<p className='padded'>Spin up a CGI service worker and serve a demo from the framework of your choice.</p>
					</a>
				</div>
				&nbsp;
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
				<h2>Filesystem Operations:</h2>
				<div className = "inset button-bar">
					<button onClick = {backupSite}>
						<img src = {cabinetIcon} className = "icon" />
						Backup
					</button>
					<button onClick = {restoreSite}>
						<img src = {floppyIcon} className = "icon" />
						Restore
						</button>
					<button onClick = {clearFilesystem}>
						<img src = {nukeIcon} className = "icon" />
						Clear
					</button>
				</div>
				<div className = "inset right demo-bar">
					<span>Demo powered by React</span> <img src = {reactIcon} className='small-icon'/>
				</div>
			</div>
			<div className = "overlay">{overlay}</div>
		</div>
	);
}

export default Home;
