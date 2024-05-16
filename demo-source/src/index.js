import React from 'react';
import ReactDOM from 'react-dom/client';
import './index.css';
import { Navigate, Route, Routes, redirect } from 'react-router';
import { BrowserRouter } from 'react-router-dom';

import SelectFramework from './SelectFramework';
import Embedded from './Embedded';
import Home from './Home';
import InstallDemo from './InstallDemo';
import Editor from './Editor';
import { onMessage } from 'php-cgi-wasm/msg-bus';

navigator.serviceWorker.register(process.env.PUBLIC_URL + `/cgi-worker.js`);

navigator.serviceWorker.addEventListener('message', onMessage);

setTimeout(() => navigator.serviceWorker.controller || window.location.reload(), 350);

const root = ReactDOM.createRoot(document.getElementById('root'));
root.render(
  <React.StrictMode>
	<BrowserRouter basename={process.env.PUBLIC_URL}>
		<Routes>
			<Route path = "/" element = { <Home /> } />
			<Route path = "/home.html" element = { <Home /> } />
			<Route path = "/embedded-php.html" element = { <Embedded /> } />
			<Route path = "/select-framework.html" element = { <SelectFramework /> } />
			<Route path = "/install-demo.html" element = { <InstallDemo /> } />
			<Route path = "/code-editor.html" element = { <Editor /> } />
			<Route
				path = "/php-wasm/code-editor"
				element = { <Navigate to = {process.env.PUBLIC_URL + '/code-editor.html' + window.location.search} />}
			/>
			<Route
				path = "/php-wasm/code-editor.html"
				element = { <Navigate to = {process.env.PUBLIC_URL + '/code-editor.html' + window.location.search} />}
			/>
			<Route
				path = "/php-wasm/cgi-bin/drupal"
				element = { <Navigate to = {process.env.PUBLIC_URL + '/install-demo.html?framework=drupal-7'} />}
			/>
			<Route
				path = "/php-wasm/cgi-bin/cakephp-5"
				element = { <Navigate to = {process.env.PUBLIC_URL + '/install-demo.html?framework=cakephp-5'} />}
			/>
			<Route
				path = "/php-wasm/cgi-bin/codeigniter-4"
				element = { <Navigate to = {process.env.PUBLIC_URL + '/install-demo.html?framework=codeigniter-4'} />}
			/>
			<Route
				path = "/php-wasm/cgi-bin/laminas-3"
				element = { <Navigate to = {process.env.PUBLIC_URL + '/install-demo.html?framework=laminas-3'} />}
			/>
			<Route
				path = "/php-wasm/cgi-bin/laravel-11"
				element = { <Navigate to = {process.env.PUBLIC_URL + '/install-demo.html?framework=laravel-11'} />}
			/>
		</Routes>
	</BrowserRouter>
  </React.StrictMode>
);
