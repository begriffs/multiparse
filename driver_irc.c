#include <stdio.h>
#include <stdlib.h>
#include "irc.h"

int main(void)
{
	int i;
	yyscan_t scanner;

	if ((i = irclex_init(&scanner)) != 0)
		exit(i);

	int e = ircparse(scanner);
	printf("Code = %d\n", e);

	irclex_destroy(scanner);
	return 0;
}
