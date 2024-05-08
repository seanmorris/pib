const incomplete = new Map;

export const sendMessage = async (action, params, accept, reject) => {
	const token = window.crypto.randomUUID();
	const ret = new Promise((_accept, _reject) => [accept, reject] = [_accept, _reject]);
	incomplete.set(token, [accept, reject]);

	navigator.serviceWorker
	.getRegistration(`${window.location.origin}/cgo-worker.mjs`)
	.then(registration => registration.active.postMessage({action, params, token}));

	return ret;
};

export const onMessage = event => {

	if(event.data.re && incomplete.has(event.data.re))
	{
		const callbacks = incomplete.get(event.data.re);

		if(!event.data.error)
		{
			callbacks[0](event.data.result);
		}
		else
		{
			callbacks[1](event.data.error);
		}

		return;
	}
};
