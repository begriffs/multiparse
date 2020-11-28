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

%token CRLF ESCAPED NONESCAPED

%%

file : record                 { puts("file1"); }
	 | file CRLF record       { puts("file2"); }
     ;

record : field             { puts("record1"); }
	   | record ',' field  { puts("record2"); }
       ;

field : ESCAPED         { puts("field1"); }
	  | NONESCAPED      { puts("field2"); }
      ;

%%

int csverror(const void *s, const char *msg)
{
	(void)s;
	return fprintf(stderr, "%s\n", msg);
}
