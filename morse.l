%option noyywrap noinput nounput
%option noyyalloc noyyrealloc noyyfree
%option prefix="morse"
%option reentrant bison-bridge

%{
#include "morse.tab.h"

#define YY_EXIT_FAILURE ((void)yyscanner, EXIT_FAILURE)

#define YYSTYPE MORSESTYPE
%}

LF_RE   (\r\n)|(\r)|(\n)|(\x0c) 

%%

"." { return DIT; }
"-" { return DAH; }

[ \t]+|{LF_RE} { return SPACE; }

%%
