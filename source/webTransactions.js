export async function startTransaction(wrapper)
{
	const php = await wrapper.binary;

	if(wrapper.transactionStarted || !php.persist)
	{
		return;
	}

	return await new Promise((accept, reject) => {
		return php.FS.syncfs(true, error => {
			if(error)
			{
				reject(error);
			}
			else
			{
				wrapper.transactionStarted = true;
				accept();
			}
		});
	});
}

export async function commitTransaction(wrapper, readOnly = false)
{
	const php = await wrapper.binary;

	if(!php.persist)
	{
		return;
	}

	if(!wrapper.transactionStarted)
	{
		throw new Error('No transaction initialized.');
	}

	if(readOnly)
	{
		wrapper.transactionStarted = false;
		return Promise.resolve();
	}

	return await new Promise((accept, reject) => {
		return php.FS.syncfs(false, error => {
			if(error)
			{
				reject(error);
			}
			else
			{
				wrapper.transactionStarted = false;
				accept();
			}
		}
	)});
}
