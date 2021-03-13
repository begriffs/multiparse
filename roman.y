%token I V X L C D M

%%

number :
  I number { $$ = $1 - 1; }
| number numeral { $$ = $1 + $2; }
| numeral
;

numeral : I|V|X|L|C|D|M;
