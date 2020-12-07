%option nounput noinput noyywrap noyyalloc noyyfree noyyrealloc
%option reentrant bison-bridge
%option prefix="csv"

%{
#include <stdio.h>
#include <string.h>
#include "csv.tab.h"

#define YYSTYPE CSVSTYPE

#define YY_EXIT_FAILURE ((void)yyscanner, EXIT_FAILURE)
%}

%%

\"([^"]|[,\r\n]|\"\")*\" {
	/* TODO: use posix regex global replace for ""->" */
	size_t i, n = strlen(yytext);
	char *s, *ret;
	s = ret = calloc(n, 1);
	if (!s) abort();
	for (i = 1 /*skip 0="*/; i < n-1; i++)
	{
		*s++ = yytext[i];
		if (yytext[i] == '"')
			i++; /* skip second one */
	}

	yylval->str = ret;
	return ESCAPED;
}
[^",\r\n]* { yylval->str = strdup(yytext); return NONESCAPED; }
\n         { return CRLF; }
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
