%define api.pure true
%define api.prefix {csv}
%define parse.error verbose

%param {void *scanner}

%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int csverror(char const *msg, const void *s);
int csvlex(void *lval, const void *s);
%}

%token TEXTDATA CRLF ESCAPED NONESCAPED

%%

file : record
	 | file CRLF record
     ;

record : field
	   | record ',' field
       ;

field : ESCAPED
	  | NONESCAPED
      ;

%%

int csverror(char const *msg, const void *s)
{
	(void)s;
	return fprintf(stderr, "%s\n", msg);
}
