%{
#include "roman.tab.h"
%}

%%

I { yylval = 1;    return I; }
V { yylval = 5;    return V; }
X { yylval = 10;   return X; }
L { yylval = 50;   return L; }
C { yylval = 100;  return C; }
D { yylval = 500;  return D; }
M { yylval = 1000; return M; }

. { return *yytext; }
