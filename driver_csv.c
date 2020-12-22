#include <stdio.h>
#include <stdlib.h>
#include "csv.h"


void print_n_fields(struct csv_row *r)
{
	printf("\t#fields = %zu\n", r->len);
	for (size_t i = 0; i < r->len; i++)
		printf("\t%s\n", r->fs[i]);
}

int main(void)
{
	int i;
	yyscan_t scanner;

	/* csvdebug = 1; */

	if ((i = csvlex_init(&scanner)) != 0)
		exit(i);

	i = csvparse(scanner, print_n_fields);

	csvlex_destroy(scanner);
	return i;
}
