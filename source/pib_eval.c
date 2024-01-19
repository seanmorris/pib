#include "sapi/embed/php_embed.h"
#include "ext/session/php_session.h"
#include "main/php_output.h"
// #include "SAPI.h"
#include <emscripten.h>
#include <stdlib.h>

#include "zend_globals_macros.h"
#include "zend_exceptions.h"
#include "zend_closures.h"

#ifdef WITH_VRZNO
#include "../vrzno/php_vrzno.h"
#endif

#define MACRO_STRING_INTERNAL(name) #name
#define MACRO_STRING(name) MACRO_STRING_INTERNAL(name)

int main() { return 0; }
bool started = false;

int EMSCRIPTEN_KEEPALIVE pib_init()
{
	putenv("USE_ZEND_ALLOC=0");

	if(!started)
	{
		started = true;
		char *wasmEnv = MACRO_STRING(ENVIRONMENT);

		EM_ASM({
			const wasmEnv = UTF8ToString($0);
			const persistPath = '/persist';

			FS.mkdir(persistPath);

			switch(wasmEnv)
			{
				case 'web':
					FS.mount(IDBFS, {}, '/persist');
					break;

				case 'node':
					const fs = require('fs');
					if(!fs.existsSync('./persist'))
					{
						fs.mkdirSync('./persist');
					}
					FS.mount(NODEFS, { root: './persist' }, '/persist');
					break;
			}

		}, wasmEnv);
	}

	int res = php_embed_init(0, NULL);

	return res;
}

void pib_finally()
{
	php_output_flush_all();
}

char *EMSCRIPTEN_KEEPALIVE pib_exec(char *code)
{
	char *retVal = NULL;

	zend_try
	{
		zval retZv;

		zend_eval_string(code, &retZv, "php-wasm evaluate expression");

		convert_to_string(&retZv);

		retVal = Z_STRVAL(retZv);
	}
	zend_catch
	{
	}

	zend_end_try();

	pib_finally();

	return retVal;
}

int EMSCRIPTEN_KEEPALIVE pib_run(char *code)
{
	int retVal = 255; // Unknown error.

	zend_try
	{
		SG(headers_sent) = 0;
		SG(request_info).no_headers = 0;
		PS(session_status) = php_session_none;

		retVal = zend_eval_string(code, NULL, "php-wasm run script");

		if (!SG(headers_sent)) {
			sapi_send_headers();
			SG(headers_sent) = 1;
		}

		if(EG(exception))
		{
			zend_exception_error(EG(exception), E_ERROR);
			retVal = 2;
		}
	}
	zend_catch
	{
		retVal = 1; // Code died.
	}

	zend_end_try();

	pib_finally();

	return retVal;
}

char *pib_tokenize(char *code)
{
	// tokenize_parse(zval zend_string)

	return "";
}

void EMSCRIPTEN_KEEPALIVE pib_destroy()
{
	return php_embed_shutdown();
}

int EMSCRIPTEN_KEEPALIVE pib_refresh()
{
	pib_destroy();

	return pib_init();
}

#ifdef WITH_VRZNO
int EMSCRIPTEN_KEEPALIVE exec_callback(zend_function *fptr, zval *argv, int argc)
{
	// int retVal = vrzno_exec_callback(fptr, argv, argc);

	// fflush(stdout);

	// return retVal;

	return NULL;
}

int EMSCRIPTEN_KEEPALIVE del_callback(zend_function *fptr)
{
	// return vrzno_del_callback(fptr);
	return NULL;
}
#endif
