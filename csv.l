%option nounput noinput noyywrap noyyalloc noyyfree noyyrealloc
%option reentrant bison-bridge
%option prefix="csv"

%{
#include <stdio.h>
#include "csv.tab.h"

#define YYSTYPE CSVSTYPE

#define YY_EXIT_FAILURE ((void)yyscanner, EXIT_FAILURE)
%}

%%

\"([^"]|[,\r\n]|\"\")*\" { return ESCAPED; }
[^",\r\n]* { return NONESCAPED; }
\r\n       { return CRLF; }
.          { return *yytext; }

%%

/*
int row_callback(char *s, void (*f)(const char *))
{
	int i;
	yyscan_t scanner;
	YY_BUFFER_STATE buf;

	if ((i = yylex_init(&scanner)) != 0)
		return i;

	buf = yy_scan_string(s, scanner);
	while ((i = yylex(scanner)) > 0)
		f(yyget_text(scanner));

	yy_delete_buffer(buf, scanner);
	yylex_destroy(scanner);
	return 0;
}
*/
