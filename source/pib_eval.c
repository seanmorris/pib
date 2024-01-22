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

int EMSCRIPTEN_KEEPALIVE  __attribute__((noinline)) pib_init()
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

static void pib_register_known_var_char(zval *track_vars_array, const char *var_name, size_t var_name_len, const char *value, size_t value_len)
{
	zval new_entry;

	if (!value) {
		return;
	}

	ZVAL_STRINGL_FAST(&new_entry, value, value_len);

	php_register_known_variable(var_name, var_name_len, &new_entry, track_vars_array);
}

static void pib_register_variables(zval *track_vars_array)
{
	pib_register_known_var_char(
		track_vars_array
		, "REQUEST_METHOD"
		, strlen("REQUEST_METHOD")
		, SG(request_info).request_method
		, strlen(SG(request_info).request_method)
	);

	printf("|%s|!!!\n", SG(request_info).request_method);

	php_import_environment_variables(track_vars_array);
}

static size_t pib_read_post(char *buf, size_t count_bytes)
{
	if (SG(request_info).argv0)
	{
		size_t len = SG(request_info).content_length;
		size_t copied = MIN(SG(read_post_bytes) + count_bytes, len) - SG(read_post_bytes);

		memmove(buf, SG(request_info).argv0 + SG(read_post_bytes), copied);

		SG(read_post_bytes) += copied;

		return copied;
	}

	return 0;
}

int EMSCRIPTEN_KEEPALIVE pib_request(
	char *filepath,
	char *method,
	char *request_uri,
	char *query_string,
	char *cookie_data,
	char *content_type,
	char *post_data
){
	int retVal = 255; // Unknown error.

	zend_try
	{
		php_embed_module.read_post = pib_read_post;
		php_embed_module.register_server_variables = pib_register_variables;

		SG(server_context) = (void*) 0x29A; // 😉
		SG(headers_sent) = 0;
		SG(request_info).no_headers = 0;
		SG(request_info).request_method = method;
		SG(request_info).content_type = content_type;
		SG(sapi_headers).http_response_code = 200;
		SG(request_info).request_uri = request_uri;
		SG(request_info).query_string = query_string;
		SG(request_info).cookie_data = cookie_data;
		SG(request_info).path_translated = NULL;
		SG(request_info).content_length = 0;
		SG(request_info).proto_num = 1000;
		SG(request_info).argv0 = post_data;
		SG(request_info).content_length = strlen(post_data);

		php_request_startup();
		php_startup_auto_globals();

		printf("|%s|\n", SG(request_info).request_method);

		zend_file_handle zfd;
		zend_stream_init_filename(&zfd, filepath);
		zfd.primary_script = 1;

		if(!php_execute_script(&zfd))
		{
			retVal = 1;
		}
		else
		{
			retVal = 0;
		}

		zend_destroy_file_handle(&zfd);

		// php_request_shutdown((void*)0);

		php_embed_module.read_post = NULL;
		php_embed_module.register_server_variables = NULL;
		SG(server_context) = NULL;

		pib_finally();
		pib_refresh();
	}
	zend_catch
	{
		retVal = 1; // Code died.
	}

	zend_end_try();

	return retVal;
}

