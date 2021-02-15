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

%x CMD

%%

\n|\r\n        { return CRLF; }

[[:space:]]+   { return SPACE; }
[[:alpha:]]+|[[:digit:]]{3} {
	BEGIN CMD;
	return COMMAND;
}
<CMD>[^:[:space:]\r\n]{trailing} { return MIDDLE; }
<CMD>{trailing}                  { BEGIN 0; return TRAILING; }

[[:alpha:]][[:alnum:]]*             { return USER; }
[[:alpha:]][[:alnum:]\-\[\]\\`^{}]* { return NICK; }
{host}                              { return HOST; }

\+?({host}\/)?{keyname}  { return KEY; }

. { return *yytext; }
