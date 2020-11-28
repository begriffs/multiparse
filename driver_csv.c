#include <stdio.h>
#include <stdlib.h>
#include "csv.h"

int main(void)
{
	int i;
	yyscan_t scanner;

	if ((i = csvlex_init(&scanner)) != 0)
		exit(i);

	int e = csvparse(scanner);
	printf("Code = %d\n", e);

	csvlex_destroy(scanner);
	return 0;
}
