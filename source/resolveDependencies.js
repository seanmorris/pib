export const resolveDependencies = (sharedLibs, wrapper) => {
	const _files = [];
	const libs = [];

	 (sharedLibs || []).forEach(libDef => {
		if(typeof libDef === 'object')
		{
			if(typeof libDef.getLibs === 'function')
			{
				libs.push(...libDef.getLibs(wrapper.constructor));
			}

			if(typeof libDef.getFiles === 'function')
			{
				_files.push(...libDef.getFiles(wrapper.constructor));
			}
		}
		else
		{
			libs.push(libDef);
		}
	});

	const files = _files.map(fileDef => {
		const url = String(fileDef.url);
		const path = fileDef.path;
		const name = fileDef.name || path.split('/').pop();
		const parent = path.substr(0, path.length - name.length);
		return {parent, name, url};
	});

	const urlLibs = {};

	libs.forEach(libDef => {
		if(typeof libDef === 'string' || libDef instanceof URL) {
			if(libDef.substr(0, 1) == '/'
				|| libDef.substr(0, 2) == './'
				|| libDef.substr(0, 8) == 'https://'
				|| libDef.substr(0, 7) == 'http://'
			){
				urlLibs[ String(libDef.split('/')).pop() ] = libDef;
			}
		}
		else if(typeof libDef === 'object') {
			const name = libDef.name ?? String(libDef.url).split('/').pop();
			urlLibs[ name ] = libDef.url;
		}
	});

	return {files, libs, urlLibs};
};
