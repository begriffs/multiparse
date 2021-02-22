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

%x IN_TAGS IN_PREFIX IN_PARAMS

%%

@ { BEGIN IN_TAGS; return *yytext; }
: { BEGIN IN_PREFIX; return *yytext; }

{space} { return SPACE; }
{command} {
	yylval->str = strdup(yytext);
	BEGIN IN_PARAMS;
	return COMMAND;
}


<IN_TAGS>\+?({host}\/)?{keyname}(={keyval})?  {
	yylval->str = strdup(yytext);
	return TAG;
}
<IN_TAGS>{space} {
	BEGIN INITIAL;
	return SPACE;
}
<IN_TAGS>; { return ';'; }


<IN_PREFIX>({host}|{nick}(!{user})?(@{host})?) {
	yylval->str = strdup(yytext);
	BEGIN INITIAL;
	return PREFIX;
}


<IN_PARAMS>{space} { return SPACE; }
<IN_PARAMS>{middle} {
	yylval->str = strdup(yytext);
	return MIDDLE;
}
<IN_PARAMS>:{trailing} {
	yylval->str = strdup(yytext+1); /* trim : */
	BEGIN INITIAL;
	return TRAILING;
}


<*>\n|\r\n { return CRLF; }
