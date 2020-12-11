%define api.pure true
%define api.prefix {csv}
%define parse.error verbose

%param {void *scanner}

%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int csverror(const void *s, const char *msg);
int csvlex(void *lval, const void *s);

#define INITIAL_ROW_SZ 16

struct csv_row
{
	size_t alloced, len;
	char *fs[]; /* C99 flexible array */
};
%}

%union
{
	char *str;
	struct csv_row *row;
}

%token CRLF
%token <str> ESCAPED NONESCAPED
%type <str> field
%type <row> fields

/* adapted from https://tools.ietf.org/html/rfc4180 */

%%

file :
  row             { puts("."); }
| file CRLF row   { puts("."); }
;

row :
  %empty
| fields
;

fields:
  field {
	struct csv_row *r = malloc(sizeof *r + INITIAL_ROW_SZ);
	if (!r) abort();
	r->alloced = INITIAL_ROW_SZ;
	r->len   = 1;
	r->fs[0] = $1;
	$$ = r;
  }
| fields ',' field {
	struct csv_row *r = $1;
	if (r->len >= r->alloced)
	{
		r->alloced *= 2;
		r = realloc(r, sizeof *r + r->alloced);
		if (!r) abort();
	}
	r->fs[r->len++] = $3;
	$$ = r;
  }
;

field :
  %empty          { printf("() "); }
| ESCAPED         { printf("'%s' ", $1); }
| NONESCAPED      { printf("%s ", $1); }
;

%%

int csverror(const void *s, const char *msg)
{
	(void)s;
	return fprintf(stderr, "%s\n", msg);
}
