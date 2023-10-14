export class UniqueIndex
{
	constructor()
	{
		this.byInteger = new Map();
		this.byObject  = new Map();

		let id = 0;

		Object.defineProperty(this, 'add', {
			configurable: false
			, writable:   false
			, value: (callback) => {

				if(this.byObject.has(callback))
				{
					const id = this.byObject.get(callback);

					return id;
				}

				const newid = ++id;

				this.byObject.set(callback, newid);
				this.byInteger.set(newid, callback);

				return newid;
			}
		});

		Object.defineProperty(this, 'has', {
			configurable: false
			, writable:   false
			, value: (callback) => {
				if(this.byObject.has(callback))
				{
					return this.byObject.get(callback);
				}
			}
		});

		Object.defineProperty(this, 'get', {
			configurable: false
			, writable:   false
			, value: (id) => {
				if(this.byInteger.has(id))
				{
					return this.byInteger.get(id);
				}
			}
		});

		Object.defineProperty(this, 'getId', {
			configurable: false
			, writable:   false
			, value: (callback) => {
				if(this.byObject.has(callback))
				{
					return this.byObject.get(callback);
				}
			}
		});

		Object.defineProperty(this, 'remove', {
			configurable: false
			, writable:   false
			, value: (id) => {

				const callback = this.byInteger.get(id);

				if(callback)
				{
					this.byObject.delete(callback)
					this.byInteger.delete(id)
				}
			}
		});
	}
}
