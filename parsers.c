#include <stdio.h>
#include <stdlib.h>

/* My own implementation of the selected reentrant functions that marks
 * the final argument as unused, to compile cleanly with -Wall
 */

void *yyalloc(size_t size, void *yyscanner)
{
	(void) yyscanner;
	return malloc(size);
}

void *yyrealloc(void * ptr, size_t size, void *yyscanner)
{
	(void) yyscanner;
	return realloc(ptr, size);
}

void yyfree(void *ptr, void *yyscanner)
{
	(void) yyscanner;
	free(ptr);
}
