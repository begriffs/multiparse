%{
/*
extern void lisperror(YYLTYPE *locp, char const *msg);
extern int lisplex(YYSTYPE *lvalp, YYLTYPE *llocp);
*/
%}

%define api.pure full
%define api.prefix {lisp}

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
