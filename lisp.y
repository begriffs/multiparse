%define api.pure true
%define api.prefix {lisp}
%define parse.error verbose

%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "parsers.h"

int lisperror(char const *msg);
int lisplex(void *lval);
%}

%union
{
	int num;
	char *str;
	struct sexpr *node;
}

%token <str> ID
%token <num> NUM

%type <node> sexpr pair atom

%%

sexpr: atom
     | pair
     ;

pair: '(' atom '.' atom ')' {
		struct sexpr *s = malloc(sizeof *s);
		if (!s) abort();
		*s = (struct sexpr){
			.type = SEXPR_PAIR,
			.left = $2,
			.right = $4
		};
		$$ = s;
	}
    | '('')' {
		struct sexpr *s = malloc(sizeof *s);
		if (!s) abort();
		/* empty pair */
		*s = (struct sexpr){.type = SEXPR_PAIR};
		$$ = s;
	}
    ;
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

int lisperror(char const *msg)
{
	return fprintf(stderr, "%s\n", msg);
}

/*
struct sexpr *parse_sexpr(const char *s, char **errmsg)
{

}
*/
