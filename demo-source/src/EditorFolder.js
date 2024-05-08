import './Common.css';
import './EditorEntry.css';
import { useEffect, useRef, useState } from 'react';
import { onMessage, sendMessage } from './msg-bus';
import EditorFile from './EditorFile';

import fileIcon from './nomo-dark/file.svg';
import folderOpen from './nomo-dark/folder.open.svg';
import folderClose from './nomo-dark/folder.close.svg';

export default function EditorFolder({path = '/', name = ''}) {
	const [dirs, setDirs]                   = useState([]);
	const [showContext, setShowContext]     = useState(false);
	const [showNewFile, setShowNewFile]     = useState(false);
	const [showNewFolder, setShowNewFolder] = useState(false);
	const [files, setFiles]                 = useState([]);
	const [expanded, setExpanded]           = useState(false);

	const onContext = event => {
		event.preventDefault();
		setExpanded(true);
		setShowNewFolder(false);
		setShowNewFile(false);
		setShowContext(true);
	}

	const onBlur = event => setTimeout(() => setShowContext(false), 160);

	const newFileKeyUp = async event => {
		if(event.key === 'Enter')
		{
			const newName = path + '/' + event.target.value;
			sendMessage('writeFile', [newName, new TextEncoder().encode('')]);
			setShowNewFile(false);
			loadFiles();
			event.target.value = '';
		}
		if(event.key === 'Escape')
		{
			setShowNewFile(false);
			event.target.value = '';
		}
	};

	const newFolderKeyUp = async event => {
		if(event.key === 'Enter')
		{
			const newName = path + '/' + event.target.value;
			sendMessage('mkdir', [newName]);
			setShowNewFolder(false);
			event.target.value = '';
			loadFiles();
		}
		if(event.key === 'Escape')
		{
			setShowNewFolder(false);
			event.target.value = '';
		}
	};

	const loadFiles = () => {
		sendMessage('readdir', [path]).then(async entries => {
			entries = entries.filter(f => f !== '.' && f !== '..');
			const types = await Promise.all(entries.map(async f => (await sendMessage('analyzePath', [path + (path[path.length - 1] !== '/' ? '/' : '') + f])).object.isFolder));
			const dirs = entries.filter((_,k) => types[k]);
			const files = entries.filter((_,k) => !types[k]);
			setDirs(dirs);
			setFiles(files);
		});
	};

	useEffect(() => {
		loadFiles();
		navigator.serviceWorker.addEventListener('message', onMessage);
		return () => navigator.serviceWorker.removeEventListener('message', onMessage);
	}, [expanded, path]);

	const toggleExpanded = event => {
		event.stopPropagation();
		setExpanded(!expanded);
	};

	return (
		<div className = "editor-entry editor-folder">
			<p onClick = { toggleExpanded } onContextMenu={onContext} onBlur = {onBlur} tabIndex="0">
				<img className = "file icon" src = {expanded  ? folderOpen : folderClose} alt = "" />
				{name}
			</p>
			{showContext && <span className = "contents only-focus">
				<p className = "context" onClick = {() => setShowNewFile(true)}>
					<img className = "file icon" src = {fileIcon} alt = "" />
					Create New File...
				</p>
				<p className = "context" onClick = {() => setShowNewFolder(true)}>
					<img className = "file icon" src = {folderClose} alt = "" />
					Create New Folder...
				</p>
			</span>}
			{showNewFile && <p className = "context">
				<img className = "file icon" src = {fileIcon} alt = "" />
				<input placeholder='filename' onKeyUp = {newFileKeyUp} autoFocus={true} />
			</p>}
			{showNewFolder && <p className = "context">
				<img className = "file icon" src = {folderClose} alt = "" />
				<input placeholder='filename' onKeyUp = {newFolderKeyUp} autoFocus={true} />
			</p>}
			{expanded && dirs.map(dir =>
				<div key = {dir}>
					<EditorFolder name = {dir} path = {path + (path[path.length - 1] !== '/' ? '/' : '') + dir} />
				</div>
			)}
			{expanded && files.map(file =>
				<div key = {file}>
					<EditorFile name = {file} path = {path + (path[path.length - 1] !== '/' ? '/' : '') + file} />
				</div>
			)}
		</div>
	);
}
