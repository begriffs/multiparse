#include <stdio.h>
#include <stdlib.h>
#include "adif.h"

int main(void)
{
	int i;
	yyscan_t scanner;

	adifdebug = 1;

	if ((i = adiflex_init(&scanner)) != 0)
		exit(i);

	i = adifparse(scanner);

	adiflex_destroy(scanner);
	return i;
}
