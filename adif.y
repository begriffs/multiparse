%define api.pure true
%define api.prefix {adif}
%define parse.error verbose

%code requires {
#include <assert.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

struct adif_tag
{
	char *name;
	char *val;
	char type;
};
}

%define api.value.type {struct adif_tag*}
%param {void *scanner}

%code {
int adiferror(const void *s, const char *msg);
int adiflex(void *lval, const void *s);
}

%token EOH EOR TAG HEADER_COMMENT

%destructor {
	free($$->name);
	free($$->val);
	free($$);
} TAG

%printer {
	fprintf(yyo, "<%s>%s (%c)", $$->name, $$->val, $$->type);
} TAG

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
