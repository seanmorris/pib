import './Common.css';
import './SelectFramework.css';
import cakePhpIcon from './cakephp-icon.svg';
import drupalIcon from './drupal-icon.svg';
import codeIgniterIcon from './codeigniter-icon.svg';
import laravelIcon from './laravel-icon.svg';
import laminasIcon from './laminas-icon.svg';
import { useEffect, useState } from 'react';
import Header from './Header';

function SelectFramework() {

	return (
		<div className = "select-framework">
			<div className='framework-menu bevel'>
				<Header />
				<div className='inset frameworks'>
					<h2>Select a Framework:</h2>
					<div className='row'>
						<div className='row'>
							<a href = "/load-demo?framework=cakephp-5">
								<img src = {cakePhpIcon} alt = "cakephp 5" />
							</a>
							<a href = "/load-demo?framework=codeigniter-4">
								<img src = {codeIgniterIcon} alt = "codeigniter 4" />
							</a>
							<a href = "/load-demo?framework=drupal-7">
								<img src = {drupalIcon} alt = "drupal 7" />
							</a>
							<a href = "/load-demo?framework=laravel-11">
								<img src = {laravelIcon} alt = "laravel 11" />
							</a>
							<a href = "/load-demo?framework=laminas-3">
								<img src = {laminasIcon} alt = "laminas 3" />
							</a>
						</div>
					</div>
				</div>
			</div>
		</div>
	);
}

export default SelectFramework;
