%option noyywrap nounput noinput
%option prefix="lisp" bison-bridge

%{
#include "lisp.tab.h"
#include "parsers.h"

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
