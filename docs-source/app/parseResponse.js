export const parseResponse = response => {
	const headers = {};
	const len = response.length;
	let pos = 0;

	while(true)
	{
		const nl = response.indexOf('\n', pos);

		if(pos === nl || pos > len)
		{
			break;
		}

		const line = response.substring(pos, nl);
		const colon = line.indexOf(':');

		headers[ line.substring(0, colon) ] = line.substring(colon + 1);

		pos = nl + 1;
	}

	const body = response.substring(pos + 1);

	return {headers, body};
};
