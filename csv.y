%define api.pure true
%define api.prefix {csv}
%define parse.error verbose

%code requires {
#include <assert.h>
#include <stdbool.h>
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
void csv_row_free(struct csv_row *r);
bool csv_row_empty(struct csv_row *r);

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
%type <row> row

%destructor { free($$); } <str>
%destructor { csv_row_free($$); } <row>

%printer {
	size_t i;
	fputc('"', yyo);
	for (i = 0; i < 6 && $$[i]; i++)
	{
		if ($$[i] == '"')
			fprintf(yyo, "\"\"");
		else
			fputc($$[i], yyo);
	}
	if ($$[i])
		fprintf(yyo, "..."); /* was truncated */
	fputc('"', yyo);
} <str>

%printer {
	fprintf(yyo, "row: %zu fields", $$->len);
} <row>

/* adapted from https://tools.ietf.org/html/rfc4180 */

%%

file :
  row {
	if(callback && !csv_row_empty($1))
		callback($1);
	csv_row_free($1);
  }
| file CRLF row {
	if(callback && !csv_row_empty($3))
		callback($3);
	csv_row_free($3);
  }
;

row:
  field {
	struct csv_row *r = malloc(sizeof *r + INITIAL_ROW_SZ * sizeof r->fs[0]);
	if (!r) abort();
	r->alloced = INITIAL_ROW_SZ;
	r->len   = 1;
	r->fs[0] = $1;
	$$ = r;
  }
| row ',' field {
	struct csv_row *r = $1;
	if (r->len >= r->alloced)
	{
		r->alloced *= 2;
		r = realloc(r, sizeof *r + r->alloced * sizeof r->fs[0]);
		if (!r) abort();
	}
	r->fs[r->len++] = $3;
	$$ = r;
  }
;

field :
  %empty          { $$ = calloc(1, 1); }
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
