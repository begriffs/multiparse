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

%%

file : record                 { puts("."); }
	 | file CRLF record       { puts("!"); }
     ;

record : field             { printf(" , "); }
	   | record ',' field  { printf(" > "); }
       ;

field : ESCAPED         { printf("'%s'", $1); }
	  | NONESCAPED      { printf("%s", $1); }
      ;

%%

int csverror(const void *s, const char *msg)
{
	(void)s;
	return fprintf(stderr, "%s\n", msg);
}
