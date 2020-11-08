#include <stdio.h>
#include "parsers.h"

void print_word(const char *w)
{
	puts(w); /* puts alone has the wrong return type */
}

int main(void)
{
	word_callback(
		"The quick brown fox\njumped over the lazy dog.\n",
		&print_word
	);
	return 0;
}
