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
};
}

%define api.value.type {struct adif_tag*}
%param {void *scanner}

%code {
int adiferror(const void *s, const char *msg);
int adiflex(void *lval, const void *s);
}

%token EOR TAG

%destructor {
	free($$->name);
	free($$->val);
	free($$);
} TAG

%printer {
	fprintf(yyo, "<%s>%s", $$->name, $$->val);
} TAG

/* adapted from https://tools.ietf.org/html/rfc4180 */

%%

file :
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
