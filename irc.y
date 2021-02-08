%define api.pure true
%define api.prefix {irc}
%define parse.error verbose

%code top {
	/* XOPEN for strdup */
	#define _XOPEN_SOURCE 600
	#include <stdio.h>
	#include <stdlib.h>
	#include <string.h>
	#include "parsers.h"
}

%code requires {
	enum sexpr_type {
		SEXPR_ID, SEXPR_NUM, SEXPR_PAIR
	};

	struct sexpr
	{
		enum sexpr_type type;
		union
		{
			int   num;
			char *id;
		} value;
		struct sexpr *left, *right;
	};
}

%union
{
	int num;
	char *str;
	struct sexpr *node;
}

%parse-param {struct sexpr **result}
%param {void *scanner}

%code {
	int ircerror(void *foo, char const *msg, const void *s);
	int irclex(void *lval, const void *s);
}

%token <str> ID
%token <num> NUM

%type <node> start sexpr pair list members atom

%%

/*
https://ircv3.net/specs/extensions/message-tags

<message>       ::= ['@' <tags> <SPACE>] [':' <prefix> <SPACE> ] <command> <params> <crlf>
<tags>          ::= <tag> [';' <tag>]*
<tag>           ::= <key> ['=' <escaped_value>]
<key>           ::= [ <client_prefix> ] [ <vendor> '/' ] <key_name>
<client_prefix> ::= '+'
<key_name>      ::= <non-empty sequence of ascii letters, digits, hyphens ('-')>
<escaped_value> ::= <sequence of zero or more utf8 characters except NUL, CR, LF, semicolon (`;`) and SPACE>
<vendor>        ::= <host>
*/

message :
  '@' tags SPACE ':' prefix SPACE command params CRLF
| '@' tags SPACE                  command params CRLF
|                ':' prefix SPACE command params CRLF
|                                 command params CRLF
;

tags :
  tag
| tags ';' tag
;

tag :
  key
| key '=' ESCAPED_VALUE
;

key :
  '+' vendor '/' KEY_NAME
| '+'            KEY_NAME
|     vendor '/' KEY_NAME
|                KEY_NAME
;

%%

int ircerror(void *yylval, char const *msg, const void *s)
{
	(void)yylval;
	(void)s;
	return fprintf(stderr, "%s\n", msg);
}
