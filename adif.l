%option noyywrap nounput
%option noyyalloc noyyrealloc noyyfree
%option prefix="adif"
%option reentrant bison-bridge

%{
#include "adif.tab.h"

#define YY_EXIT_FAILURE ((void)yyscanner, EXIT_FAILURE)

#include <stdbool.h>
#include <ctype.h>
#include <stdio.h>

#define YYSTYPE ADIFSTYPE

static char *read_n(yyscan_t scanner, size_t n);
static struct adif_tag *adif_tag_create(int namelen);
%}

TAGNAME_RE [[:alnum:]_]+
TAGLEN_RE  [[:digit:]]{1,8}
TAGTYPE_RE [BNDTSIMGEL]

/* <call:5>KG0KG<band:3>80M<mode:3>SSB<qso_date:8>20200311<time_on:4>1904<eor> */
%%

[^<\n].*$ {
	return HEADER_COMMENT;
}

\<{TAGNAME_RE}:{TAGLEN_RE}:{TAGTYPE_RE}\> {
	size_t datalen;
	struct adif_tag *t = adif_tag_create(yyleng);
	*yylval = t;
	if (!t)
		return TAG;

	/* format is good, safe to scanf */
	sscanf(yytext, "<%[^:]:%zu:%c>", t->name, &datalen, &t->type);
	t->type = toupper(t->type);
	t->val = read_n(yyscanner, datalen);
	return TAG;
}

\<{TAGNAME_RE}:{TAGLEN_RE}\> {
	size_t datalen;
	struct adif_tag *t = adif_tag_create(yyleng);
	*yylval = t;
	if (!t)
		return TAG;

	/* format is good, safe to scanf */
	sscanf(yytext, "<%[^:]:%zu>", t->name, &datalen);
	t->val = read_n(yyscanner, datalen);
	return TAG;
}

(?i:\<eor\>) { return EOR; }
(?i:\<eoh\>) { return EOH; }

[\n[:space:]] ;
. {
	fprintf(stderr, "Weird one: '%c'\n", yytext[0]);
	return yytext[0];
}

%%

char *read_n(yyscan_t scanner, size_t n)
{
	int c;
	size_t i;
	char *s = malloc(n + 1);
	if (!s) return s;

	for (i = 0; i < n && (c = input(scanner)) != EOF; i++)
		s[i] = c;
	s[i] = '\0';
	return s;
}

struct adif_tag *adif_tag_create(int namelen)
{
	struct adif_tag *t = malloc(sizeof *t);
	if (!t) return t;
	*t = (struct adif_tag){.type = 'S'};

	t->name = calloc(1, namelen);
	if (!t->name) {
		free(t);
		return NULL;
	}
	return t;
}
