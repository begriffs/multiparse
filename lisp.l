%option noyywrap nounput noinput prefix="lisp" bison-bridge

%{
#include "lisp.tab.h"
#include "parsers.h"

#include <limits.h>
#include <stdlib.h>

int lisperror(const char *msg);

extern struct sexpr *yylval;
%}

%%

[a-zA-Z][a-zA-Z0-9]*    { return ID; }
[-+]?[0-9]+             {
	long n = strtol(yytext, NULL, 10);
	struct sexpr *ret = malloc(sizeof *ret);
	if (!ret) abort();

	if (n < INT_MIN || n > INT_MAX)
		lisperror("Number out of range");
	ret->type = SEXPR_NUM;
	ret->value.num = (int)n;
	yylval = ret;
	return NUM;
}

[ \t]                   ;
.                       { return *yytext; }
