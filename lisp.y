%define api.pure true
%define api.prefix {lisp}
%define parse.error verbose

%parse-param {struct sexpr **result}
%param {void *scanner}

%{
/* XOPEN for strdup */
#define _XOPEN_SOURCE 600
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int lisperror(void *foo, char const *msg, const void *s);
int lisplex(void *lval, const void *s);
%}

%code provides {
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

%token <str> ID
%token <num> NUM

%type <node> start sexpr pair list members atom

%%

start : sexpr   { *result = $1; return 0; }
	  ;

sexpr: atom
     | list
	 | pair
     ;

list: '(' members ')' {
		$$ = $2;
	}
	| '('')' {
		struct sexpr *s = malloc(sizeof *s);
		if (!s) abort();
		/* empty pair */
		*s = (struct sexpr){.type = SEXPR_PAIR};
		$$ = s;
	}
	;

members: sexpr {
		struct sexpr *s = malloc(sizeof *s),
		             *nil = malloc(sizeof *nil);;
		if (!s || !nil) abort();
		*nil = (struct sexpr){.type = SEXPR_PAIR};
		*s = (struct sexpr){
			.type = SEXPR_PAIR,
			.left = $1,
			.right = nil
		};
		$$ = s;
	}
	| sexpr members {
		struct sexpr *s = malloc(sizeof *s);
		if (!s) abort();
		*s = (struct sexpr){
			.type = SEXPR_PAIR,
			.left = $1,
			.right = $2
		};
		$$ = s;
	}
	;

pair: '(' sexpr '.' sexpr ')' {
	struct sexpr *s = malloc(sizeof *s);
	if (!s) abort();
	*s = (struct sexpr){
		.type = SEXPR_PAIR,
		.left = $2,
		.right = $4
	};
	$$ = s;
}

atom: ID {
		struct sexpr *s = malloc(sizeof *s);
		if (!s) abort();
		*s = (struct sexpr){
			.type = SEXPR_ID,
			.value.id = strdup($1)
		};
		$$ = s;
	}
    | NUM {
		struct sexpr *s = malloc(sizeof *s);
		if (!s) abort();
		*s = (struct sexpr){
			.type = SEXPR_NUM,
			.value.num = $1
		};
		$$ = s;
	}
    ;

%%

int lisperror(void *yylval, char const *msg, const void *s)
{
	(void)yylval;
	(void)s;
	return fprintf(stderr, "%s\n", msg);
}
