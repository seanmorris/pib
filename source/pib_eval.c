#include "sapi/embed/php_embed.h"
#include "ext/session/php_session.h"
#include "main/php_output.h"
// #include "SAPI.h"
#include <emscripten.h>
#include <stdlib.h>

#include "zend_globals_macros.h"
#include "zend_exceptions.h"
#include "zend_closures.h"

#include "../json/php_json.h"
#include "../json/php_json_encoder.h"
#include "../json/php_json_parser.h"

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
			if(Module.persist)
			{
				const localPath = Module.persist.localPath || './persist';
				const mountPath = Module.persist.mountPath || '/persist';

				const wasmEnv = UTF8ToString($0);

				FS.mkdir(mountPath);

				switch(wasmEnv)
				{
					case 'web':
						FS.mount(IDBFS, {}, mountPath);
						break;

					case 'node':
						const fs = require('fs');
						if(!fs.existsSync(localPath))
						{
							fs.mkdirSync(localPath, {recursive: true});
						}
						FS.mount(NODEFS, { root: localPath }, mountPath);
						break;
				}
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
		zend_eval_string(code, &retZv, "php-wasm exec expression");
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

bool tokenize(zval *return_value, zend_string *source, zend_class_entry *token_class);

char *EMSCRIPTEN_KEEPALIVE pib_tokenize(char *code)
{
	zval parsed;
	zend_string *zCode = zend_string_init(code, strlen(code), 0);
	tokenize(&parsed, zCode, NULL);
	zend_string_release(zCode);

	php_json_encoder encoder;
	php_json_encode_init(&encoder);
	smart_str buf = {0};
	encoder.max_depth = PHP_JSON_PARSER_DEFAULT_DEPTH;
	php_json_encode_zval(&buf, &parsed, 0, &encoder);
	smart_str_0(&buf);

	zend_long len = ZSTR_LEN(buf.s);
	char *json = ZSTR_VAL(buf.s);
	char *ret = emalloc(len);
	memcpy(ret, json, len);
	smart_str_free(&buf);

	return ret;
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
