export async function startTransaction(wrapper)
{
	const php = await wrapper.binary;

	if(wrapper.transactionStarted || !php.persist)
	{
		return;
	}

	return await new Promise((accept, reject) => {
		php.FS.syncfs(true, error => {

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

export async function commitTransaction(wrapper)
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

	return await new Promise((accept, reject) => {
		php.FS.syncfs(false, error => {

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
