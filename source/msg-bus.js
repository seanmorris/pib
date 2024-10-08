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
	incomplete.set(token, [accept, reject, action, params]);

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
		const [accept, reject, action, params] = incomplete.get(event.data.re);

		incomplete.delete(event.data.re);

		if(!event.data.error)
		{
			accept(event.data.result);
		}
		else
		{
			reject({error: event.data.error, action, params});
		}
	}
};
