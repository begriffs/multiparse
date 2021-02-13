#ifndef MULTIPARSE_DICT_H
#define MULTIPARSE_DICT_H

#include <stdbool.h>

char *dict_get(void **, const char *);
bool dict_set(void **, const char *, const char *);
void dict_free(void **);

#endif
