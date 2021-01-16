%option noyywrap noinput nounput
%option noyyalloc noyyrealloc noyyfree
%option prefix="morse"
%option reentrant bison-bridge

%{
#include "morse.tab.h"

#define YY_EXIT_FAILURE ((void)yyscanner, EXIT_FAILURE)

#define YYSTYPE MORSESTYPE
%}

%%

"." { return DIT; }
"-" { return DAH; }

[[:space:]\n\r\x0c]+ { return SPACE; }

. { return *yytext; }

%%
