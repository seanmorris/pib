import './Common.css';
import './EditorEntry.css';
// import { useEffect, useState } from 'react';
// import { onMessage, sendMessage } from './msg-bus';

import fileIcon from './nomo-dark/file.svg';
import filePhpIcon from './nomo-dark/file.php.svg';
import fileJsIcon from './nomo-dark/file.js.svg';
import fileTxtIcon from './nomo-dark/file.txt.svg';
import fileShIcon from './nomo-dark/file.sh.svg';

const icons = {
	php: filePhpIcon
	, inc: filePhpIcon
	, js: fileJsIcon
	, mjs: fileJsIcon
	, txt: fileTxtIcon
	, sh: fileShIcon
};

export default function EditorFile({path = '/', name = ''}) {
	const openFile = () => {
		window.dispatchEvent(new CustomEvent('editor-open-file', {detail: path}));
	};
	const extension = path.split('.').pop();
	return (
		<div className = "editor-entry editor-file">
			<p onClick = {openFile} tabIndex="0">
				<img className = "file icon" src = {icons[extension] ?? fileIcon} alt = "" />
				{name}
			</p>
		</div>
	);
}
