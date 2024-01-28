export default response => {
	const headers = {};
	const len = response.length;
	let pos = 0;

	while(true)
	{
		const crlf = response.indexOf('\r\n', pos);

		if(pos === crlf || pos > len || crlf < 0)
		{
			break;
		}

		const line = response.substring(pos, crlf);

		if(line === '\n')
		{
			break;
		}

		const colon = line.indexOf(':');

		if(colon < 0)
		{
			headers[ line ] = true;
		}
		else
		{
			headers[ line.substring(0, colon) ] = line.substring(colon + 2);
		}

		pos = crlf + 2;
	}

	const body = response.substring(pos + 2);

	return {headers, body};
};
