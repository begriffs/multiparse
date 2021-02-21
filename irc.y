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
	#include <libcalg/compare-string.h>
	#include <libcalg/hash-string.h>
}

%code requires {
	#include <libcalg/slist.h>
	#include <libcalg/hash-table.h>

	struct prefix
	{
		char *host;
		char *nick;
		char *user;
	};

	struct irc_message
	{
		HashTable *tags;
		char *prefix;
		char *command;
		SListEntry *params;
	};
}

%union
{
	char *str;
	HashTable *map;
	HashTablePair *pair;
	SListEntry *list;
	struct irc_message *msg;
}

%parse-param {struct irc_message **result}
%param {void *scanner}

%code {
	int ircerror(void *foo, char const *msg, const void *arg);
	int irclex(void *lval, const void *s);

	void slist_free_data(SListEntry *l);
}

%token          SPACE CRLF LEXNOMEM
%token <str>    COMMAND MIDDLE TRAILING TAG
                PREFIX

%type <msg> message
%type <map> tags
%type <pair> tag
%type <list> params

%%

/*
Rules come from a combo of these pages:
https://ircv3.net/specs/extensions/message-tags
https://tools.ietf.org/html/rfc1459#section-2.3.1
*/

final : message { *result = $1; return 0; }
	  ;

message :
  '@' tags SPACE ':' PREFIX SPACE COMMAND SPACE params {
	struct irc_message *m = malloc(sizeof *m);
	if (!m || !$5 || !$7) YYNOMEM;
	*m = (struct irc_message) {
		.tags=$2, .prefix=$5, .command=$7, .params=$9
	};
	$$ = m;
  }
| '@' tags SPACE                  COMMAND SPACE params {
	struct irc_message *m = malloc(sizeof *m);
	if (!m || !$4) YYNOMEM;
	*m = (struct irc_message) {
		.tags=$2, .command=$4, .params=$6
	};
	$$ = m;
  }
|                ':' PREFIX SPACE COMMAND SPACE params {
	struct irc_message *m = malloc(sizeof *m);
	if (!m || !$2 || !$4) YYNOMEM;
	*m = (struct irc_message) {
		.prefix=$2, .command=$4, .params=$6
	};
	$$ = m;
  }
|                                 COMMAND SPACE params {
	struct irc_message *m = malloc(sizeof *m);
	if (!m || !$1) YYNOMEM;
	*m = (struct irc_message) {
		.command=$1, .params=$3
	};
	$$ = m;
  }
;

tags :
  tag {
	HashTable *t = hash_table_new(string_hash, string_equal);
	if (!t) YYNOMEM;
	if (!hash_table_insert(t, $1->key, $1->value))
	{
		free($1->key);
		free($1->value);
		free($1);
		hash_table_free(t);
		YYNOMEM;
	}
	free($1);
	$$ = t;
  }
| tags ';' tag {
	if (!hash_table_insert($1, $3->key, $3->value))
	{
		free($3->key);
		free($3->value);
		free($3);
		hash_table_free($1);
		YYNOMEM;
	}
	free($3);
	$$ = $1;
  }
;

tag :
  TAG {
	HashTablePair *p = malloc(sizeof *p);
	if (!p || !$1) YYNOMEM;
	char *split = strchr($1, '=');
	if (split)
		*split = '\0';
	p->key = $1;
	p->value = split ? strdup(split+1) : calloc(1,1);
	if (!p->key || !p->value)
	{
		free(p->key);
		free(p->value);
		free(p);
		YYNOMEM;
	}
	$$ = p;
  }
;

params :
  TRAILING {
	char *p = $1;
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
| MIDDLE SPACE params {
	char *p = $1;
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
| %empty {
	$$ = NULL;
}
;

%%

int ircerror(void *yylval, char const *msg, const void *arg)
{
	(void)yylval;
	(void)arg;
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
