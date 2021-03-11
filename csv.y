%pure-parser

%code top {
	#include <assert.h>
	#include <stdio.h>
	#include <stdlib.h>
	#include <string.h>
	#include "parsers.h"

	typedef void (*csv_row_callback)(struct csv_row *);
}

%code requires {
	struct csv_row
	{
		size_t alloced, len;
		char *fs[]; /* C99 flexible array */
	};
}

%union
{
	char *str;
	struct csv_row *row;
}

%lex-param {void *scanner}
%parse-param {void *scanner}
%parse-param {csv_row_callback callback}

%code provides {
	#include <stdbool.h>

	void csv_row_free(struct csv_row *r);
	bool csv_row_empty(struct csv_row *r);
}

%code {
	#define INITIAL_ROW_SZ 16
}

%token CRLF
%token <str> ESCAPED NONESCAPED
%type <str> field
%type <row> row

/* adapted from https://tools.ietf.org/html/rfc4180 */

%%

file :
  consumed_row
| file CRLF consumed_row
;

consumed_row :
  row {
	if(callback && !csv_row_empty($1))
		callback($1);
	csv_row_free($1);
  }
;

row :
  field {
	if (!$1) YYNOMEM;
	struct csv_row *r = malloc(sizeof *r + INITIAL_ROW_SZ * sizeof r->fs[0]);
	if (!r) YYNOMEM;
	r->alloced = INITIAL_ROW_SZ;
	r->len   = 1;
	r->fs[0] = $1;
	$$ = r;
  }
| row ',' field {
	struct csv_row *r = $1;
	if (!$3) YYNOMEM;
	if (r->len >= r->alloced)
	{
		r->alloced *= 2;
		r = realloc(r, sizeof *r + r->alloced * sizeof r->fs[0]);
		if (!r) YYNOMEM;
	}
	r->fs[r->len++] = $3;
	$$ = r;
  }
;

field :
  /* empty */        { $$ = calloc(1, 1); }
| ESCAPED
| NONESCAPED
;

%%

void csv_row_free(struct csv_row *r)
{
	assert(r);
	for (size_t i = 0; i < r->len; i++)
		free(r->fs[i]);
	free(r);
}

bool csv_row_empty(struct csv_row *r)
{
	return r->len < 2 && r->fs[0][0] == '\0';
}

int csverror(const void *s, const csv_row_callback c, const char *msg)
{
	(void)s;
	(void)c;
	return fprintf(stderr, "%s\n", msg);
}
