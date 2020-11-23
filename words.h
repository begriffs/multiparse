#ifndef MULTIPARSE_WORDS_H
#define MULTIPARSE_WORDS_H

/*
#undef YY_EXIT_FAILURE
#define YY_EXIT_FAILURE ((void)yyscanner, EXIT_FAILURE)
*/

int word_callback(char *, void (*)(const char *));

#endif
