#include <stdio.h>
#include <stdlib.h>
#include "morse.h"

int main(void)
{
	int i;
	yyscan_t scanner;

	//morsedebug = 1;

	if ((i = morselex_init(&scanner)) != 0)
		exit(i);

	i = morseparse(scanner);

	morselex_destroy(scanner);
	return i;
}
