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
nick [[:alpha:]][[:alnum:]\-\[\]\\`^{}]*
user [[:alpha:]][[:alnum:]]*
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

<PREFIX>{nick} {
	struct prefix *p = malloc(sizeof *p);
	if (!p) return LEXNOMEM;
	*p = (struct prefix){.nick=strdup(yytext)};
	yylval->prefix = p;
	return PREFIX;
}
<PREFIX>{host} {
	struct prefix *p = malloc(sizeof *p);
	if (!p) return LEXNOMEM;
	*p = (struct prefix){.host=strdup(yytext)};
	yylval->prefix = p;
	return PREFIX;
}
<PREFIX>{nick}!{user} {
	struct prefix *p = malloc(sizeof *p);
	if (!p) return LEXNOMEM;
	char *split = strchr(yytext, '!');
	*split = '\0';
	*p = (struct prefix){
		.nick=strdup(yytext),
		.user=strdup(split+1)
	};
	yylval->prefix = p;
	return PREFIX;
}
<PREFIX>{nick}@{host} {
	struct prefix *p = malloc(sizeof *p);
	if (!p) return LEXNOMEM;
	char *split = strchr(yytext, '@');
	*split = '\0';
	*p = (struct prefix){
		.nick=strdup(yytext),
		.host=strdup(split+1)
	};
	yylval->prefix = p;
	return PREFIX;
}
<PREFIX>{nick}!{user}@{host} {
	struct prefix *p = malloc(sizeof *p);
	if (!p) return LEXNOMEM;
	char *split = strchr(yytext, '!'),
	     *split2 = strchr(split, '@');
	*split2 = *split = '\0';
	*p = (struct prefix){
		.nick=strdup(yytext),
		.user=strdup(split+1),
		.host=strdup(split2+1)
	};
	yylval->prefix = p;
	return PREFIX;
}

<TAGS>\+?({host}\/)?{keyname}  { yylval->str = yytext; return KEY; }

@ { BEGIN TAGS; return *yytext; }
: { BEGIN PREFIX; return *yytext; }

<*>. { return *yytext; }
