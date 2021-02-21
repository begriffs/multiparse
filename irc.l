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
nick [[:alpha:]][[:alnum:]\-\[\]\\`^{}_]*
user [~[:alpha:]][[:alnum:]]*
keyname [[:alnum:]\-]+
keyval [^[:space:];\r\n]*
command [[:alpha:]]+|[[:digit:]]{3}
middle [^:[:space:]\r\n][^[:space:]\r\n]*
trailing [^\r\n]*

%x PARAMS TAGS

%%

@ { BEGIN TAGS; return *yytext; }

<TAGS>\+?({host}\/)?{keyname}(={keyval})?  {
	yylval->str = strdup(yytext);
	return TAG;
}
<TAGS>{space} {
	BEGIN INITIAL;
	return SPACE;
}
<TAGS>; { return ';'; }



:({host}|{nick}(!{user})?(@{host})?) {
	yylval->str = strdup(yytext+1);
	return PREFIX;
}
{command} {
	yylval->str = strdup(yytext);
	BEGIN PARAMS;
	return COMMAND;
}
{space} { return SPACE; }



<PARAMS>{middle} {
	yylval->str = strdup(yytext);
	return MIDDLE;
}
<PARAMS>:{trailing} {
	BEGIN INITIAL;
	yylval->str = strdup(yytext+1); /* trim : */
	return TRAILING;
}
<PARAMS>{space} { return SPACE; }



<*>\n|\r\n { return CRLF; }
