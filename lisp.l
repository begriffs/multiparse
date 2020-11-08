%option noyywrap nounput noinput prefix="lisp"

%{
#include "lisp.tab.h"
%}

%%

[a-zA-Z][a-zA-Z0-9]*    { return ID; }
[-+]?[0-9]+             { return NUM; }
.                       { return *yytext; }
