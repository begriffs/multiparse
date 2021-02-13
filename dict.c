#include "dict.h"

#include <stdlib.h>
#include <search.h>

/* XOPEN for strdup */
#define _XOPEN_SOURCE 600
#include <string.h>

struct dict_entry
{
	const char *key;
	char *val;
};

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
	struct dict_entry *probe, **found;

	if (!(probe = malloc(sizeof *probe)))
		return false;
	*probe = (struct dict_entry){.key=key};
	if (!(found = tsearch(probe, d, _key_cmp)))
		return false;

	if (*found == probe) /* new entry */
	{
		char *newkey = strdup(key), *newval = strdup(val);
		if (!newkey || !newval)
		{
			tdelete(probe, d, _always_equal);
			free(probe);
			return false;
		}
		/* probe used arg pointers; assign copies */
		**found = (struct dict_entry){.key=newkey, .val=newval};
	}
	else  /* already existed */
	{
		char *newval = strdup(val);
		if (!newval)
		{
			free(probe);
			return false;
		}
		free((*found)->val);
		(*found)->val = newval;
		free(probe);
	}
	return true;
}

void dict_free(void **d)
{
	while (*d)
	{
		struct dict_entry *item = *(struct dict_entry **)*d;
		tdelete(item, d, _always_equal);
		free((char*)item->key);
		free(item->val);
		free(item);
	}
}
