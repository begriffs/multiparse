#include <stdio.h>
#include <stdlib.h>
#include "irc.h"

void pretty(struct sexpr* s, unsigned depth)
{
	for (unsigned i = 0; i < depth; i++)
		printf("  ");
	switch (s->type)
	{
		case SEXPR_ID:
			puts(s->value.id);
			break;
		case SEXPR_NUM:
			printf("%d\n", s->value.num);
			break;
		case SEXPR_PAIR:
			if (!s->left && !s->right)
			{
				puts("()");
				break;
			}
			puts(".");
			pretty(s->left, depth+1);
			pretty(s->right, depth+1);
			break;
		default:
			abort();
	}
}

int main(void)
{
	int i;
	struct sexpr *expr;
	yyscan_t scanner;

	if ((i = irclex_init(&scanner)) != 0)
		exit(i);

	int e = ircparse(&expr, scanner);
	printf("Code = %d\n", e);
	if (e == 0)
		pretty(expr, 0);

	irclex_destroy(scanner);
	return 0;
}
