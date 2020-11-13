%define api.prefix {lisp}
%define api.pure true
%define api.value.type {struct sexpr*}
%define parse.error verbose

%{
#include <stdio.h>

int lisperror(char const *msg);
int lisplex(void *lval);
%}

%token ID NUM

%%

sexpr: atom                 {printf("matched sexpr\n");}
    | list
    ;
list: '(' members ')'       {printf("matched list\n");}
    | '('')'                {printf("matched empty list\n");}
    ;
members: sexpr              {printf("members 1\n");}
    | sexpr members         {printf("members 2\n");}
    ;
atom: ID {
		
	}
    | NUM                   {printf("NUM\n");}
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
