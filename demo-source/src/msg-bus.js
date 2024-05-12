const incomplete = new Map();

/**
 * Create a sendMessage function given a service worker URL.
 * @param {*} serviceWorkerUrl The URL to the service worker.
 * @returns sendMessage function for the service workrer.
 */
export const sendMessageFor = (serviceWorkerUrl) => async (action, params, accept, reject) => {
	const token = window.crypto.randomUUID();
	const ret = new Promise((_accept, _reject) => [accept, reject] = [_accept, _reject]);
	incomplete.set(token, [accept, reject]);

	navigator.serviceWorker
	.getRegistration(serviceWorkerUrl)
	.then(registration => registration.active.postMessage({action, params, token}));

	return ret;
};

export const sendMessage = sendMessageFor((`${window.location.origin}${process.env.PUBLIC_URL}/cgi-worker.mjs`));

/**
 * Event handler for recieved messages.
 * @param {*} event
 */
export const onMessage = event => {
	if(event.data.re && incomplete.has(event.data.re))
	{
		const callbacks = incomplete.get(event.data.re);

		incomplete.delete(event.data.re);

		if(!event.data.error)
		{
			callbacks[0](event.data.result);
		}
		else
		{
			callbacks[1](event.data.error);
		}
	}
};
