/* pib extension for PHP */

#ifndef PHP_PIB_H
# define PHP_PIB_H

extern zend_module_entry pib_module_entry;
# define phpext_pib_ptr &pib_module_entry

# define PHP_PIB_VERSION "0.1.0"

# if defined(ZTS) && defined(COMPILE_DL_PIB)
ZEND_TSRMLS_CACHE_EXTERN()
# endif

#endif
