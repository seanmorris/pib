#include "sapi/embed/php_embed.h"
#include <emscripten.h>
#include <stdlib.h>

#include "zend_globals_macros.h"
#include "zend_exceptions.h"
#include "zend_closures.h"

int main() {
  return 0;
}

void phpw_flush()
{
  fprintf(stdout, "\n");
  fprintf(stderr, "\n");
}

char *EMSCRIPTEN_KEEPALIVE phpw_exec(char *code)
{
  // This sets USE_ZEND_ALLOC=0 to avoid nunmap errors
  setenv("USE_ZEND_ALLOC", "0", 1);
  php_embed_init(0, NULL);
  char *retVal = NULL;

  zend_try
  {
    zval retZv;

    zend_eval_string(code, &retZv, "php-wasm evaluate expression");

    convert_to_string(&retZv);

    retVal = Z_STRVAL(retZv);
  } zend_catch {
  } zend_end_try();

  phpw_flush();
  php_embed_shutdown();

  return retVal;
}

void EMSCRIPTEN_KEEPALIVE phpw_run(char *code)
{
  setenv("USE_ZEND_ALLOC", "0", 1);
  php_embed_init(0, NULL);
  zend_try
  {
    zend_eval_string(code, NULL, "php-wasm run script");
    if(EG(exception))
    {
      zend_exception_error(EG(exception), E_ERROR);
    }
  } zend_catch {
    /* int exit_status = EG(exit_status); */
  } zend_end_try();

  phpw_flush();
  php_embed_shutdown();
}

int EMBED_SHUTDOWN = 1;

void phpw(char *file)
{
  setenv("USE_ZEND_ALLOC", "0", 1);
  if (EMBED_SHUTDOWN == 0) {
	  php_embed_shutdown();
  }

  php_embed_init(0, NULL);
  EMBED_SHUTDOWN = 0;
  zend_first_try {
    zend_file_handle file_handle;
    zend_stream_init_filename(&file_handle, file);
    // file_handle.primary_script = 1;

    if (php_execute_script(&file_handle) == FAILURE) {
      php_printf("Failed to execute PHP script.\n");
    }

    zend_destroy_file_handle(&file_handle);
  } zend_catch {
    /* int exit_status = EG(exit_status); */
  } zend_end_try();

  phpw_flush();
  php_embed_shutdown();
  EMBED_SHUTDOWN = 1;
}
