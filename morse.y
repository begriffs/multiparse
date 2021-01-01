%define api.pure true
%define api.prefix {morse}
%define parse.error verbose

%code top {
	#include "parsers.h"
}

%param {void *scanner}
%define api.value.type {char}

%code {
	int morseerror(const void *s, const char *msg);
	int morselex(void *lval, const void *s);
}

%token SPACE EOS LETTER

%printer {
	fprintf(yyo, "%c", $$);
} LETTER

%%

words :
  word
| words SPACE word
;

word :
  LETTER
| word LETTER
;

%%

int morseerror(const void *s, const char *msg)
{
	(void)s;
	return fprintf(stderr, "%s\n", msg);
}
