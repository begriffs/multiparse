#include "vendor/greatest.h"
#include "csv.h"

int csv_parse(char *s)
{
	int i;
	yyscan_t scanner;
	YY_BUFFER_STATE buf;

	if ((i = csvlex_init(&scanner)) != 0)
		abort();

	buf = csv_scan_string(s, scanner);
	i = csvparse(scanner);
	csv_delete_buffer(buf, scanner);
	csvlex_destroy(scanner);

	return i;
}

TEST parses_single_field_csv(void) {
	/* Compare, with an automatic "1 != x" failure message */
	ASSERT_EQ(0, csv_parse("hi"));

	PASS();
}

TEST parses_double_field_csv(void) {
	/* Compare, with an automatic "1 != x" failure message */
	ASSERT_EQ(0, csv_parse("hi,bye"));

	PASS();
}

TEST parses_2row_csv(void) {
	/* Compare, with an automatic "1 != x" failure message */
	ASSERT_EQ(0, csv_parse("hi,bye\n1,2"));

	PASS();
}

/* Suites can group multiple tests with common setup. */
SUITE(csv) {
	RUN_TEST(parses_single_field_csv);
	RUN_TEST(parses_double_field_csv);
	RUN_TEST(parses_2row_csv);
}

/* Add definitions that need to be in the test runner's main file. */
GREATEST_MAIN_DEFS();

int main(int argc, char **argv) {
	GREATEST_MAIN_BEGIN();      /* command-line options, initialization. */

	/* Individual tests can be run directly in main, outside of suites. */
	/* RUN_TEST(x_should_equal_1); */

	/* Tests can also be gathered into test suites. */
	RUN_SUITE(csv);

	GREATEST_MAIN_END();        /* display results */
}
