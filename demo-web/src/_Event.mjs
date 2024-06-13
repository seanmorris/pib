// eslint-disable-next-line no-undef
export const _Event = globalThis.CustomEvent ?? class extends globalThis.Event
{
	constructor(name, options = {})
	{
		super(name, options)
		this.detail = options.detail;
	}
};
