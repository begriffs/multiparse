%define api.pure true
%define api.prefix {csv}
%define parse.error verbose

%code requires {
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

struct csv_row
{
	size_t alloced, len;
	char *fs[]; /* C99 flexible array */
};

typedef void (*csv_row_callback)(struct csv_row *);
}

%param {void *scanner}
%parse-param {csv_row_callback callback}

%code {
int csverror(const void *s, const csv_row_callback c, const char *msg);
int csvlex(void *lval, const void *s);

#define INITIAL_ROW_SZ 16
}

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
| fields          { callback($1); }
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

int csverror(const void *s, const csv_row_callback c, const char *msg)
{
	(void)s;
	(void)c;
	return fprintf(stderr, "%s\n", msg);
}
