%pure-parser

%code top {
	#include <assert.h>
	#include <stdbool.h>
	#include <stdio.h>
	#include <stdlib.h>
	#include <string.h>
}

%code requires {
	struct adif_tag
	{
		char *name;
		char *val;
		char type;
	};
}

%union {
	struct adif_tag *tag;
}

%lex-param {void *scanner}
%parse-param {void *scanner}

%token EOH EOR HEADER_COMMENT
%token <tag> TAG

%%

file :
  HEADER_COMMENT tags EOH records
| records
;

records :
  record
| records record
;

record :
  tags EOR
;

tags :
  TAG
| tags TAG
;

%%

int adiferror(const void *s, const char *msg)
{
	(void)s;
	return fprintf(stderr, "%s\n", msg);
}
