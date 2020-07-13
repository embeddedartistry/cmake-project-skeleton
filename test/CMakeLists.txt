if(PROJECTVARNAME_TESTING_IS_ENABLED)
	add_executable(MYPROJECT_tests)
	target_include_directories(MYPROJECT_tests PRIVATE . ${CMOCKA_INCLUDE_DIR})
	target_link_libraries(MYPROJECT_tests PRIVATE ${CMOCKA_LIBRARIES})
	target_sources(MYPROJECT_tests PRIVATE
		main.c
		test_suite.c
	)
	target_linker_map(MYPROJECT_tests)

	list(APPEND desired_MYPROJECT_test_flags
		"-Wno-unused-parameter"
	)
	apply_supported_compiler_flags(C MYPROJECT_tests PRIVATE desired_MYPROJECT_test_flags)

	##################
	# Helper Targets #
	##################

	add_custom_target(test-clear-results
		COMMAND ${CMAKE_COMMAND} -E rm -f ${CMAKE_BINARY_DIR}/test/*.xml
		COMMENT "Removing XML files in the test/ directory"
	)

	add_custom_target(test-MYPROJECT
		COMMAND export CMOCKA_MESSAGE_OUTPUT=stdout
		COMMAND MYPROJECT_tests
	)

	#############################
	# Register Tests with CTest #
	#############################

	add_test(NAME MYPROJECT.ClearResults
		COMMAND ${CMAKE_COMMAND} --build ${CMAKE_BINARY_DIR} --target test-clear-results
	)

	add_test(NAME MYPROJECT.Test
		COMMAND MYPROJECT_tests
	)

	set_tests_properties(MYPROJECT.Test
		PROPERTIES
			ENVIRONMENT CMOCKA_XML_FILE=${CMAKE_CURRENT_BINARY_DIR}/%g.xml
			DEPENDS MYPROJECT.ClearResults
	)

endif(PROJECTVARNAME_TESTING_IS_ENABLED)
