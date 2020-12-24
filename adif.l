%option noyywrap nounput
%option noyyalloc noyyrealloc noyyfree
%option prefix="adif"
%option reentrant bison-bridge

%{
#include "adif.tab.h"

#define YY_EXIT_FAILURE ((void)yyscanner, EXIT_FAILURE)

#include <stdbool.h>
#include <stdio.h>

#define YYSTYPE ADIFSTYPE
%}

/* <call:5>KG0KG<band:3>80M<mode:3>SSB<qso_date:8>20200311<time_on:4>1904<eor> */

%%

\<[[:alpha:]]+:[[:digit:]]{1,8}\> {
	long datalen, i, c;
	struct adif_tag *t = malloc(sizeof *t);
	if (!t) abort();
	*t = (struct adif_tag){0};

	/* a little overkill, but whatevs */
	t->name = malloc(yyleng);
	if (!t->name) abort();
	/* format is good, safe to scanf */
	sscanf(yytext, "<%[^:]:%ld>", t->name, &datalen);
	t->val = malloc(datalen);
	if (!t->val) abort();

	for (i = 0; i < datalen && (c = input(yyscanner)) != EOF; i++)
		t->val[i] = c;
	t->val[i] = '\0';
	/* yylval is pointer to value in pure scanner */
	*yylval = t;
	return TAG;
}
\<eor\> { return EOR; }
.|\n	;
