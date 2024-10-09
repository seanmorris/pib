import { _Event } from "./_Event.mjs";

export class OutputBuffer
{
	constructor(target, eventType, maxLength)
	{
		Object.defineProperty(this, 'target',    {value: target});
		Object.defineProperty(this, 'buffer',    {value: []});
		Object.defineProperty(this, 'eventType', {value: eventType});
		Object.defineProperty(this, 'maxLength', {value: maxLength});
		Object.defineProperty(this, 'decoder',   {value: new TextDecoder()});
		Object.defineProperty(this, 'queue',     {value: new Set});
	}

	push(...items)
	{
		this.buffer.push(...items);

		const end = this.buffer.length - 1;

		if(this.maxLength === -1 && this.buffer[end] === 10)
		{
			this.flush();
		}

		if(this.maxLength >= 0 && this.buffer.length >= this.maxLength)
		{
			this.flush();
		}
	}

	flush()
	{
		if(!this.buffer.length)
		{
			return;
		}

		const detail = [this.decoder.decode(new Uint8Array(this.buffer))];
		const event = new _Event(this.eventType, {detail});

		if(this.target['on' + this.eventType])
		{
			if(this.target['on' + this.eventType](event) === false)
			{
				return;
			}
		}

		if(!this.target.dispatchEvent(event))
		{
			return;
		}

		this.buffer.splice(0);
	}
}
