%define api.pure true
%define api.prefix {irc}
%define parse.error verbose

%code top {
	/* XOPEN for strdup */
	#define _XOPEN_SOURCE 600
	#include <search.h>
	#include <stdarg.h>
	#include <stdio.h>
	#include <stdlib.h>
	#include <string.h>

	#include "parsers.h"
}

%code requires {
	#include <libcalg/slist.h>
	#include <libcalg/trie.h>

	struct prefix
	{
		char *host;
		char *nick;
		char *user;
	};

	struct irc_message
	{
		Trie *tags;
		struct prefix *prefix;
		char *command;
		SListEntry *params;
	};
}

%union
{
	char *str;
	Trie *map;
	char **pair;
	SListEntry *list;
	struct irc_message *msg;
	struct prefix *prefix;
}

%param {void *scanner}

%code {
	int ircerror(void *foo, char const *msg);
	int irclex(void *lval, const void *s);

	void slist_free_data(SListEntry *l);
}

%token <str> COMMAND CRLF SPACE ESCAPED_VALUE MIDDLE TRAILING
             HOST NICK USER KEY

%type <msg> message
%type <map> tags
%type <pair> tag
%type <list> params
%type <prefix> prefix

%%

message :
  '@' tags SPACE ':' prefix SPACE COMMAND params CRLF {
	struct irc_message *m = malloc(sizeof *m);
	if (!m) YYNOMEM;
	*m = (struct irc_message) {
		.tags=$2, .prefix=$5, .command=$7, .params=$8
	};
	$$ = m;
  }
| '@' tags SPACE                  COMMAND params CRLF {
	struct irc_message *m = malloc(sizeof *m);
	if (!m) YYNOMEM;
	*m = (struct irc_message) {
		.tags=$2, .command=$4, .params=$5
	};
	$$ = m;
  }
|                ':' prefix SPACE COMMAND params CRLF {
	struct irc_message *m = malloc(sizeof *m);
	if (!m) YYNOMEM;
	*m = (struct irc_message) {
		.prefix=$2, .command=$4, .params=$5
	};
	$$ = m;
  }
|                                 COMMAND params CRLF {
	struct irc_message *m = malloc(sizeof *m);
	if (!m) YYNOMEM;
	*m = (struct irc_message) {
		.command=$1, .params=$2
	};
	$$ = m;
  }
;

tags :
  tag {
	Trie *t = trie_new();
	if (!t) YYNOMEM;
	if (!trie_insert(t, $1[0], $1[1]))
	{
		free($1[0]);
		free($1[1]);
		free($1);
		trie_free(t);
		YYNOMEM;
	}
	free($1[0]);
	$$ = t;
  }
| tags ';' tag {
	if (!trie_insert($1, $3[0], $3[1]))
	{
		free($3[0]);
		free($3[1]);
		free($3);
		trie_free($1);
		YYNOMEM;
	}
	free($3[0]);
	$$ = $1;
  }
;

tag :
  KEY {
	char **p = malloc(2 * sizeof(*p));
	if (!p) YYNOMEM;
	p[0] = strdup($1);
	p[1] = calloc(1,1);
	if (!p[0] || !p[1])
	{
		free(p[0]);
		free(p[1]);
		YYNOMEM;
	}
	$$ = p;
  }
| KEY '=' ESCAPED_VALUE {
	char **p = malloc(2 * sizeof(*p));
	if (!p) YYNOMEM;
	p[0] = strdup($1);
	p[1] = strdup($3);
	if (!p[0] || !p[1])
	{
		free(p[0]);
		free(p[1]);
		YYNOMEM;
	}
	$$ = p;
  }
;

params :
  SPACE ':' TRAILING {
	char *p = strdup($3);
	SListEntry *l = NULL;
	slist_prepend(&l, p);
	if (!p || !l)
	{
		free(p);
		slist_free(l);
		YYNOMEM;
	}
	$$ = l;
  }
| SPACE MIDDLE params {
	char *p = strdup($1);
	SListEntry *l = $3, *before = slist_prepend(&l, p);
	if (!p || !before)
	{
		free(p);
		slist_free_data(l);
		slist_free(l);
		YYNOMEM;
	}
	$$ = before;
  }
;

prefix :
  HOST {
	struct prefix *p = malloc(sizeof *p);
	if (!p) YYNOMEM;
	*p = (struct prefix){.host=strdup($1)};
	$$ = p;
  }
| NICK '!' USER '@' HOST {
	struct prefix *p = malloc(sizeof *p);
	if (!p) YYNOMEM;
	*p = (struct prefix){.nick=strdup($1), .user=strdup($3), .host=strdup($5)};
	$$ = p;
  }
| NICK '!' USER {
	struct prefix *p = malloc(sizeof *p);
	if (!p) YYNOMEM;
	*p = (struct prefix){.nick=strdup($1), .user=strdup($3)};
	$$ = p;
  }
| NICK          '@' HOST {
	struct prefix *p = malloc(sizeof *p);
	if (!p) YYNOMEM;
	*p = (struct prefix){.nick=strdup($1), .host=strdup($3)};
	$$ = p;
  }
| NICK {
	struct prefix *p = malloc(sizeof *p);
	if (!p) YYNOMEM;
	*p = (struct prefix){.nick=strdup($1)};
	$$ = p;
  }
;

%%

int ircerror(void *yylval, char const *msg)
{
	(void)yylval;
	return fprintf(stderr, "%s\n", msg);
}

void slist_free_data(SListEntry *l)
{
	char *p;
	SListIterator i;
	slist_iterate(&l, &i);
	while ((p = slist_iter_next(&i)) != NULL)
		free(p);
}

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

https://tools.ietf.org/html/rfc1459#section-2.3.1

<message>  ::= [':' <prefix> <SPACE> ] <command> <params> <crlf>
<prefix>   ::= <servername> | <nick> [ '!' <user> ] [ '@' <host> ]
<command>  ::= <letter> { <letter> } | <number> <number> <number>
<SPACE>    ::= ' ' { ' ' }
<params>   ::= <SPACE> [ ':' <trailing> | <middle> <params> ]

<middle>   ::= <Any *non-empty* sequence of octets not including SPACE
               or NUL or CR or LF, the first of which may not be ':'>
<trailing> ::= <Any, possibly *empty*, sequence of octets not including
                 NUL or CR or LF>

<crlf>     ::= CR LF

<target>     ::= <to> [ "," <target> ]
<to>         ::= <channel> | <user> '@' <servername> | <nick> | <mask>
<channel>    ::= ('#' | '&') <chstring>
<servername> ::= <host>
<host>       ::= see RFC 952 [DNS:4] for details on allowed hostnames
<nick>       ::= <letter> { <letter> | <number> | <special> }
<mask>       ::= ('#' | '$') <chstring>
<chstring>   ::= <any 8bit code except SPACE, BELL, NUL, CR, LF and
                  comma (',')>

<user>       ::= <nonwhite> { <nonwhite> }
<letter>     ::= 'a' ... 'z' | 'A' ... 'Z'
<number>     ::= '0' ... '9'
<special>    ::= '-' | '[' | ']' | '\' | '`' | '^' | '{' | '}'

<nonwhite>   ::= <any 8bit code except SPACE (0x20), NUL (0x0), CR
                  (0xd), and LF (0xa)>
*/
