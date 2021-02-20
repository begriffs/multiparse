#include <stdio.h>
#include <stdlib.h>
#include "irc.h"

void pretty(struct irc_message *m)
{
	if (m->tags)
	{
		puts("Tags:");
		HashTableIterator i;
		hash_table_iterate(m->tags, &i);
		while (hash_table_iter_has_more(&i))
		{
			HashTablePair t = hash_table_iter_next(&i);
			printf("\t'%s'='%s'\n", t.key, t.value);
		}
	}
	if (m->prefix)
		printf("Prefix: %s\n", m->prefix);
	if (m->command)
		printf("Command: %s\n", m->command);
	if (!m->params)
		return;
	puts("Params:");
	SListIterator i;
	char *p;
	slist_iterate(&m->params, &i);
	while ((p = (char *)slist_iter_next(&i)) != SLIST_NULL)
		printf("\t%s\n", p);
}

int main(void)
{
	int i;
	yyscan_t scanner;
	struct irc_message *msg;

	ircdebug = 1;


	if ((i = irclex_init(&scanner)) != 0)
		exit(i);

	int e = ircparse(&msg, scanner);
	printf("Code = %d\n", e);
	if (e == 0)
		pretty(msg);

	irclex_destroy(scanner);
	return 0;
}
