%define api.prefix {lisp}
%define api.pure true

%{
extern void lisperror(char const *msg);
extern int  lisplex(void *lval);
%}

%token ID NUM

%%

sexpr  : atom
       | '(' sexpr '.' sexpr ')'
       | sexprs
       ;
sexprs : sexpr sexprs
	   | sexpr
       ;
atom   : ID
	   | NUM
       ;

%%
