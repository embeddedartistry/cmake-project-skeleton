/*
 * Copyright © 2020 Embedded Artistry LLC.
 * See LICENSE file for licensing information.
 */

// Cmocka needs these
// clang-format off
#include <setjmp.h>
#include <stdarg.h>
#include <stddef.h>
#include <cmocka.h>
// clang-format on

#include <tests.h>

static void test_case(__attribute__((unused)) void** state)
{
	// Full Assert macro reference: https://api.cmocka.org/group__cmocka__asserts.html
	// assert_int_equal();
	// assert_ptr_equal();
	// assert_true();
	// assert_false();
	// assert_null();
	// assert_memory_equal();
	// assert_in_range();
}

#pragma mark - Public Functions -

int test_suite(void)
{
	const struct CMUnitTest test_suite_tests[] = {
		cmocka_unit_test(test_case),
	};

	return cmocka_run_group_tests(test_suite_tests, NULL, NULL);
}
