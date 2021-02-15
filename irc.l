%option noyywrap nounput noinput
%option noyyalloc noyyrealloc noyyfree
%option prefix="irc"
%option reentrant bison-bridge

%{
#include "irc.tab.h"

#define YY_EXIT_FAILURE ((void)yyscanner, EXIT_FAILURE)

/* XOPEN for strdup */
#define _XOPEN_SOURCE 600
#include <limits.h>
#include <stdlib.h>
#include <string.h>

/* seems like a bug that I have to do this */
#define YYSTYPE IRCSTYPE

int ircerror(const char *msg);
%}

trailing [^[:space:]\r\n]*
host [[:alnum:]][[:alnum:]\.\-]*
keyname [[:alnum:]\-]+

%x CMD TAGS PREFIX

%%

\n|\r\n        { return CRLF; }

[[:space:]]+            { return SPACE; }
<PREFIX>[[:space:]]+   { BEGIN CMD; return SPACE; }

[[:alpha:]]+|[[:digit:]]{3} {
	yylval->str = yytext;
	return COMMAND;
}
<CMD>[^:[:space:]\r\n]{trailing} { yylval->str = yytext; return MIDDLE; }
<CMD>{trailing}                  { BEGIN 0; yylval->str = yytext; return TRAILING; }

<PREFIX>[[:alpha:]][[:alnum:]]*             { yylval->str = yytext; return USER; }
<PREFIX>[[:alpha:]][[:alnum:]\-\[\]\\`^{}]* { yylval->str = yytext; return NICK; }
<PREFIX>{host}                              { yylval->str = yytext; return HOST; }

<TAGS>\+?({host}\/)?{keyname}  { yylval->str = yytext; return KEY; }

@ { BEGIN TAGS; return *yytext; }
: { BEGIN PREFIX; return *yytext; }

. { return *yytext; }
