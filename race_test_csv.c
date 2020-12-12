#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>
#include "csv.h"

#define N_THREADS 4
#define N_REPS    100

void *repeatedly_parse(void *filename)
{
	int reps;
	FILE *fp = fopen(filename, "r");
	if (!fp)
	{
		fprintf(stderr, "Can't open \"%s\"\n", filename);
		abort();
	}

	for (reps = 0; reps < N_REPS; reps++)
	{
		int code;
		yyscan_t scanner;

		if ((code = csvlex_init(&scanner)) != 0)
		{
			fprintf(stderr, "Failed to initialize scanner, code: %d\n", code);
			abort();
		}
		csvset_in(fp, scanner);
		csvparse(scanner, NULL);
		csvlex_destroy(scanner);

		rewind(fp);
	}
	fclose(fp);

	return NULL;
}

int main(int argc, char **argv)
{
	int i;
	pthread_t ts[N_THREADS];

	if (argc != 2)
	{
		fprintf(stderr, "Usage: %s file.csv\n", *argv);
		return EXIT_FAILURE;
	}

	for (i = 0; i < N_THREADS; i++)
		pthread_create(&ts[i], NULL, repeatedly_parse, argv[1]);
	for (i = 0; i < N_THREADS; i++)
		pthread_join(ts[i], NULL);
	puts("Done.");
	return EXIT_SUCCESS;
}
