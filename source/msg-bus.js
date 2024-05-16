const incomplete = new Map();

/**
 * Create a sendMessage function given a service worker URL.
 * @param {*} serviceWorkerUrl The URL to the service worker.
 * @returns sendMessage function for the service workrer.
 */
export const sendMessageFor = (serviceWorkerUrl) => async (action, params = []) => {
	const token = window.crypto.randomUUID();
	let accept, reject;
	const ret = new Promise((_accept, _reject) => [accept, reject] = [_accept, _reject]);
	incomplete.set(token, [accept, reject]);

	navigator.serviceWorker
	.getRegistration(serviceWorkerUrl)
	.then(registration => registration.active.postMessage({action, params, token}));

	return ret;
};

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
