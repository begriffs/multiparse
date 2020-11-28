#ifndef MULTIPARSE_CSV_H
#define MULTIPARSE_CSV_H

/* seems like a bug that I have to do this */
#define YYSTYPE CSVSTYPE

#include "csv.tab.h"
#include "csv.lex.h"

int csv_parse(char *s);

#endif
