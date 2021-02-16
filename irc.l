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

space [[:space:]]+
host [[:alnum:]][[:alnum:]\.\-]*
nick [[:alpha:]][[:alnum:]\-\[\]\\`^{}]*
user [[:alpha:]][[:alnum:]]*
keyname [[:alnum:]\-]+
keyval [^[:space:];\r\n]*
command [[:alpha:]]+|[[:digit:]]{3}
trailing [^[:space:]\r\n]*

%x PARAMS TAGS PREFIX

%%

@ { BEGIN TAGS; return *yytext; }

<TAGS>\+?({host}\/)?{keyname}  {
	yylval->str = yytext;
	return KEY;
}
<TAGS>{keyval} {
	yylval->str = yytext;
	return ESCAPED_VALUE;
}
<TAGS>{space} {
	BEGIN INITIAL;
	return SPACE;
}



: {
	BEGIN PREFIX;
	return *yytext;
}

<PREFIX>{host}|{nick}(!{user})?(@{host})? {
	yylval->str = yytext;
	return PREFIX;
}
<PREFIX>{space} { BEGIN INITIAL; return SPACE; }



{command} {
	yylval->str = yytext;
	BEGIN PARAMS;
	return COMMAND;
}



<PARAMS>[^:[:space:]\r\n]{trailing} {
	yylval->str = yytext;
	return MIDDLE;
}
<PARAMS>{trailing} {
	BEGIN INITIAL;
	yylval->str = yytext;
	return TRAILING;
}



<*>\n|\r\n { return CRLF; }
