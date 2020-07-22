# Libraries live here
#
# This are larger modules with a cohesive set of features used to accomplish some
# purpose, e.g. WolfSSL or liblz4. Smaller, single-purpose modules should live in utilities.

# Save the library directory path for use with our `add_library` call below
set(LIBRARY_ROOT_DIR ${CMAKE_CURRENT_LIST_DIR})

# All targets in the lib tree should be included with a directory prefix:
#	#include <lib/header.h>
# To accomplish this, we automatically set `target_include_directories` for library
# targets so this scheme can be used.
#
# Library targets themselves should NOT set public/interface includes within the library tree
function(add_library target)
	# Forward all arguments to the orginal add_library
	_add_library(${target} ${ARGN})
	# Ensure this directory is included as an interface include
	target_include_directories(${target} INTERFACE ${LIBRARY_ROOT_DIR})
endfunction()

#############
# Libraries #
#############

add_subdirectory(example)
