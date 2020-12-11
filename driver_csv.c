#include <stdio.h>
#include <stdlib.h>
#include "csv.h"


void print_n_fields(struct csv_row *r)
{
	printf("#fields = %zu\n", r->len);
}

int main(void)
{
	int i;
	yyscan_t scanner;

	if ((i = csvlex_init(&scanner)) != 0)
		exit(i);

	i = csvparse(scanner, print_n_fields);

	csvlex_destroy(scanner);
	return i;
}
