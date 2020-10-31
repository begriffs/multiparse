#include <stdio.h>
#include "parsers.h"

int main(void)
{
	return word_callback(
		"The quick brown fox\njumped over the lazy dog.\n",
		&puts
	);
}
