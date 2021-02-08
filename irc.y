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
}

%param {void *scanner}

%code {
	int ircerror(void *foo, char const *msg);
	int irclex(void *lval, const void *s);
}

%token COMMAND CRLF SPACE KEY_NAME ESCAPED_VALUE MIDDLE TRAILING NICK USER HOST

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

message :
  '@' tags SPACE ':' prefix SPACE COMMAND params CRLF
| '@' tags SPACE                  COMMAND params CRLF
|                ':' prefix SPACE COMMAND params CRLF
|                                 COMMAND params CRLF
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
  '+' HOST '/' KEY_NAME
| '+'          KEY_NAME
|     HOST '/' KEY_NAME
|              KEY_NAME
;

params :
  SPACE ':' TRAILING
| MIDDLE params
;

prefix :
  HOST
| NICK '!' USER '@' HOST
| NICK '!' USER
| NICK          '@' HOST
| NICK
;

%%

int ircerror(void *yylval, char const *msg)
{
	(void)yylval;
	return fprintf(stderr, "%s\n", msg);
}
