import React from 'react';
import ReactDOM from 'react-dom/client';
import './index.css';
import { Route, Routes } from 'react-router';
import { BrowserRouter } from 'react-router-dom';

import SelectFramework from './SelectFramework';
import Embeded from './Embeded';
import Home from './Home';
import LoadDemo from './LoadDemo';
import Editor from './Editor';

navigator.serviceWorker.register(process.env.PUBLIC_URL + `/cgi-worker.js`);

if(!navigator.serviceWorker.controller)
{
	window.location.reload();
}

const root = ReactDOM.createRoot(document.getElementById('root'));
root.render(
  <React.StrictMode>
	<BrowserRouter basename={process.env.PUBLIC_URL}>
		<Routes>
			<Route path = "/" element = { <Home /> } />
			<Route path = "/home" element = { <Home /> } />
			<Route path = "/embedded" element = { <Embeded /> } />
			<Route path = "/select-framework" element = { <SelectFramework /> } />
			<Route path = "/load-demo" element = { <LoadDemo /> } />
			<Route path = "/code-editor" element = { <Editor /> } />
		</Routes>
	</BrowserRouter>
  </React.StrictMode>
);
