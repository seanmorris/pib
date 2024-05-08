import './Common.css';
import './Home.css';
import phpPageIcon from './deepin-php-icon.svg';
import cakePhpIcon from './cakephp-icon.svg';
import drupalIcon from './drupal-icon.svg';
import codeIgniterIcon from './codeigniter-icon.svg';
import laravelIcon from './laravel-icon.svg';
import laminasIcon from './laminas-icon.svg';
import reactIcon from './react-icon.svg';
import { useEffect, useState } from 'react';

function Home() {

	const [offset, setOffset] = useState(0);
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
							<img src = {cakePhpIcon} />
							<img src = {codeIgniterIcon} />
							<img src = {drupalIcon} />
							<img src = {laravelIcon} />
							<img src = {laminasIcon} />
							<img src = {cakePhpIcon} />
						</div>
						<span className = "title">PHP CGI Demo</span>
						<p>Spin up a CGI service worker and serve a demo from the framework of your choice.</p>
					</a>
				</div>
				<div className = "inset right demo-bar">
					<span>Demo powered by React</span> <img src = {reactIcon} className='small-icon'/>
				</div>
			</div>
		</div>
	);
}

export default Home;
