# Utilities live here
#	(standalone modules with singular functionality implemented in a standalone manner)
#
# Utility modules are expected to live in subdirectories of this folder, so they
# are included via `#include <linkedlist/linkedlist.h>
#
# The default build structure is for a header-only libraries.
#
# If you want to add source files, remove the `INTERFACE` option from `add_library`.
# And make the INTERFACE option in `target_include_directories` PUBLIC.
# Then, you can use `add_subdirectory` and call `target_sources(utilities PRIVATE ...)`
# to add files to the library.

add_library(utilities INTERFACE)
target_include_directories(utilities INTERFACE .)
