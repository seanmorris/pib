import React from 'react';
import ReactDOM from 'react-dom/client';
import './index.css';
import { Navigate, Route, Routes, redirect } from 'react-router';
import { BrowserRouter } from 'react-router-dom';

import SelectFramework from './SelectFramework';
import Embedded from './Embedded';
import Home from './Home';
import LoadDemo from './LoadDemo';
import Editor from './Editor';

navigator.serviceWorker.register(process.env.PUBLIC_URL + `/cgi-worker.js`);

setTimeout(() => navigator.serviceWorker.controller || window.location.reload(), 350);

const root = ReactDOM.createRoot(document.getElementById('root'));
root.render(
  <React.StrictMode>
	<BrowserRouter basename={process.env.PUBLIC_URL}>
		<Routes>
			<Route path = "/" element = { <Home /> } />
			<Route path = "/home" element = { <Home /> } />
			<Route path = "/embedded" element = { <Embedded /> } />
			<Route path = "/select-framework" element = { <SelectFramework /> } />
			<Route path = "/load-demo" element = { <LoadDemo /> } />
			<Route path = "/code-editor" element = { <Editor /> } />
			<Route
				path = "/php-wasm/code-editor"
				element = { <Navigate to = {process.env.PUBLIC_URL + '/code-editor' + window.location.search} />}
			/>
			<Route
				path = "/php-wasm/cgi-bin/drupal"
				element = { <Navigate to = {process.env.PUBLIC_URL + '/load-demo?framework=drupal-7'} />}
			/>
			<Route
				path = "/php-wasm/cgi-bin/cakephp-5"
				element = { <Navigate to = {process.env.PUBLIC_URL + '/load-demo?framework=cakephp-5'} />}
			/>
			<Route
				path = "/php-wasm/cgi-bin/codeigniter-4"
				element = { <Navigate to = {process.env.PUBLIC_URL + '/load-demo?framework=codeigniter-4'} />}
			/>
			<Route
				path = "/php-wasm/cgi-bin/laminas-3"
				element = { <Navigate to = {process.env.PUBLIC_URL + '/load-demo?framework=laminas-3'} />}
			/>
			<Route
				path = "/php-wasm/cgi-bin/laravel-11"
				element = { <Navigate to = {process.env.PUBLIC_URL + '/load-demo?framework=laravel-11'} />}
			/>
		</Routes>
	</BrowserRouter>
  </React.StrictMode>
);
