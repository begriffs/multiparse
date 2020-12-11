%option noyywrap nounput noinput
%option noyyalloc noyyrealloc noyyfree
%option prefix="lisp"
%option reentrant bison-bridge

%{
#include "lisp.tab.h"

#define YY_EXIT_FAILURE ((void)yyscanner, EXIT_FAILURE)

/* XOPEN for strdup */
#define _XOPEN_SOURCE 600
#include <limits.h>
#include <stdlib.h>
#include <string.h>

/* seems like a bug that I have to do this */
#define YYSTYPE LISPSTYPE

int lisperror(const char *msg);
%}

%%

[[:alpha:]][[:alnum:]]*    {
	yylval->str = strdup(yytext);
	return ID;
}
[-+]?[[:digit:]]+          {
	long n = strtol(yytext, NULL, 10);

	if (n < INT_MIN || n > INT_MAX)
		lisperror("Number out of range");
	yylval->num = (int)n;
	return NUM;
}

[[:space:]]                ;
.                          { return *yytext; }
