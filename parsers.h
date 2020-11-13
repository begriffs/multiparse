#ifndef MULTIPARSE_PARSERS_H
#define MULTIPARSE_PARSERS_H

/*
#undef YY_EXIT_FAILURE
#define YY_EXIT_FAILURE ((void)yyscanner, EXIT_FAILURE)
*/

#include "vendor/queue.h"

/* words.l */
int word_callback(char *, void (*)(const char *));

/* lisp.y */
int lispparse(void);

enum sexpr_type {
	SEXPR_ID, SEXPR_NUM, SEXPR_LIST
};

struct sexpr_list_item
{
	struct sexpr *e;
	SLIST_ENTRY(sexpr_list) link;
};
SLIST_HEAD(sexpr_list, sexpr_list_item);

struct sexpr
{
	enum sexpr_type type;
	union
	{
		int    num;
		char  *id;
		struct sexpr_list *items;
	} value;
};

#endif
