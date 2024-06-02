export class fsOps
{
	static async analyzePath(binary, path)
	{
		const result = (await binary).FS.analyzePath(path);

		if(!result.object)
		{
			return { exists: false };
		}

		const object = {
			exists: true
			, id: result.object.id
			, mode : result.object.mode
			, mount: {
				mountpoint: result.object.mount.mountpoint
				, mounts: result.object.mount.mounts.map(m => m.mountpoint)
			}
			, isDevice: result.object.isDevice
			, isFolder: result.object.isFolder
			, read: result.object.read
			, write: result.object.write
		};

		return {...result, object, parentObject: undefined};
	}

	static async readdir(binary, path)
	{
		return (await binary).FS.readdir(path);
	}

	static async readFile(binary, path, options)
	{
		return (await binary).FS.readFile(path, options);
	}

	static async stat(binary, path)
	{
		return (await binary).FS.stat(path);
	}

	static async mkdir(binary, path)
	{
		const php = (await binary);
		const _result = php.FS.mkdir(path);

		return {
			id: _result.id
			, mode : _result.mode
			, mount: {
				mountpoint: _result.mount.mountpoint
				, mounts: _result.mount.mounts.map(m => m.mountpoint)
			}
			, isDevice: _result.isDevice
			, isFolder: _result.isFolder
			, read: _result.read
			, write: _result.write
		};
	}

	static async rmdir(binary, path)
	{
		return (await binary).FS.rmdir(path);
	}

	static async rename(binary, path, newPath)
	{
		return (await binary).FS.rename(path, newPath);
	}

	static async writeFile(binary, path, data, options)
	{
		return (await binary).FS.writeFile(path, data, options);
	}

	static async unlink(binary, path)
	{
		return (await binary).FS.unlink(path);
	}
}
