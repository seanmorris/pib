export function startTransaction(wrapper)
{
	return wrapper.binary.then(php => {
		if(wrapper.transactionStarted || !php.persist)
		{
			return Promise.resolve();
		}

		return new Promise((accept, reject) => {
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
	});
}

export function commitTransaction(wrapper)
{
	return wrapper.binary.then(php => {
		if(!php.persist)
		{
			return Promise.resolve();
		}

		if(!wrapper.transactionStarted)
		{
			throw new Error('No transaction initialized.');
		}

		return new Promise((accept, reject) => {
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
	});
}
