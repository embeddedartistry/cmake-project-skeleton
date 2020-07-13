add_executable(APP)
target_sources(APP PRIVATE main.c)
target_link_libraries(APP PRIVATE example utilities)
target_linker_map(APP)

# Apply unconditional private flags here
list(APPEND APP_private_compile_flags
	"-Wno-unknown-pragmas"
)
apply_supported_compiler_flags(C APP PRIVATE APP_private_compile_flags)
