#ifndef MULTIPARSE_PARSERS_H
#define MULTIPARSE_PARSERS_H

/*
#undef YY_EXIT_FAILURE
#define YY_EXIT_FAILURE ((void)yyscanner, EXIT_FAILURE)
*/

/* words.l */
int word_callback(char *, void (*)(const char *));

/* lisp.y */
int lispparse(void);

enum sexpr_type {
	SEXPR_ID, SEXPR_NUM, SEXPR_PAIR
};

struct sexpr
{
	enum sexpr_type type;
	union
	{
		int   num;
		char *id;
	} value;
	struct sexpr *left, *right;
};

#endif
