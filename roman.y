%{
#include <stdio.h>

/* fir bison error, maybe don't include
   these in example posix yacc example */
int yyerror(const char *s);
int yywrap(void);
int yylex(void);
%}

%token I V X L C D M

%%

results :
  number { printf("%d\n", $1); }

number :
  I V { $$ = $2 - $1; }
| I X { $$ = $2 - $1; }
| X L { $$ = $2 - $1; }
| X C { $$ = $2 - $1; }
| C M { $$ = $2 - $1; }
| number number { $$ = $1 + $2; }
| numeral
;

numeral : I | V | X | L | C | D | M;
