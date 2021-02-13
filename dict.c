#include "dict.h"

#include <stdlib.h>
#include <search.h>

/* XOPEN for strdup */
#define _XOPEN_SOURCE 600
#include <string.h>

struct dict_entry
{
	char *key;
	char *val;
};

static void _free_dict_entry(struct dict_entry *e)
{
	free(e->key);
	free(e->val);
	free(e);
}

static int
_key_cmp(const void *a, const void* b)
{
	const struct dict_entry *u = a, *v = b;
	return strcmp(u->key, v->key);
}

static int
_always_equal(const void *a, const void *b)
{
	(void) a;
	(void) b;
	return 0;
}

char *dict_get(void **d, const char *key)
{
	struct dict_entry  y   = { .key = (char *)key },
	                 **elt = tfind(&y, d, _key_cmp);
	return elt ? (*elt)->val : NULL;
}

bool dict_set(void **d, const char *key, const char *val)
{
	struct dict_entry *e, **found;

	if (!(e = malloc(sizeof *e)))
		return false;
	*e = (struct dict_entry){strdup(key), strdup(val)};
	if (!e->key || !e->val)
	{
		_free_dict_entry(e);
		return false;
	}
	if (!(found = tsearch(e, d, _key_cmp)))
	{
		_free_dict_entry(e);
		return false;
	}

	if (*found != e) /* already existed */
	{
		char *old = (*found)->val;
		(*found)->val = e->val;
		free(old);
		free(e->key);
		free(e);
	}
	return true;
}

void dict_free(void **d)
{
	while (*d)
	{
		struct dict_entry *item = *(struct dict_entry **)*d;
		tdelete(item, d, _always_equal);
		_free_dict_entry(item);
	}
}
