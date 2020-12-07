%define api.pure true
%define api.prefix {csv}
%define parse.error verbose

%param {void *scanner}

%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int csverror(const void *s, const char *msg);
int csvlex(void *lval, const void *s);
%}

%union
{
	char *str;
}

%token <str> CRLF ESCAPED NONESCAPED

/* adapted from https://tools.ietf.org/html/rfc4180 */

%%

file : row              { puts("."); }
	 | file CRLF row    { puts("."); }
     ;

row : field             { printf(" "); }
	| row ',' field     { printf(" "); }
    ;

field : /* blank? */    { printf("()"); }
	  | ESCAPED         { printf("'%s'", $1); }
	  | NONESCAPED      { printf("%s", $1); }
      ;

%%

int csverror(const void *s, const char *msg)
{
	(void)s;
	return fprintf(stderr, "%s\n", msg);
}
