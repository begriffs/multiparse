#include <stdlib.h>

/* My own implementation of the selected reentrant functions that marks
 * the final argument as unused, to compile cleanly with -Wall
 */

#define SCANNERS \
	X(words) \
	X(lisp)

/* Each scanner uses its own prefix, and we'll create the same functions
 * for each, but with different names.
 */

#define X(SCAN)                                                   \
	void *SCAN##alloc(size_t size, void *yyscanner)               \
	{                                                             \
		(void) yyscanner;                                         \
		return malloc(size);                                      \
	}                                                             \
	                                                              \
	void *SCAN##realloc(void * ptr, size_t size, void *yyscanner) \
	{                                                             \
		(void) yyscanner;                                         \
		return realloc(ptr, size);                                \
	}                                                             \
	                                                              \
	void SCAN##free(void *ptr, void *yyscanner)                   \
	{                                                             \
		(void) yyscanner;                                         \
		free(ptr);                                                \
	}
SCANNERS
#undef X

