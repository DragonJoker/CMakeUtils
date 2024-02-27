#
# Coverage.cmake
# -----------
#
# Find a coverage tool (OpenCppCoverage or gcov) and defines functions for using it.
#
# Usage
# ^^^^^^^^^^^^^^^^
#
# 1. Call `coverage_add_target(myTarget)` for each target that should be run to generate coverage
# 2. At the end call `coverage_add_merge_target(target outputFile)` to create a target which will create the combined coverage report
#
# Functions defined
# ^^^^^^^^^^^^^^^^
# coverage_add_target(target WORKING_DIRECTORY dir SOURCES [src, ...] MODULES [module, ...] ARGS [arg, ...])
#   Register `target` to be run with coverage tool.
#   WORKING_DIRECTORY -- Working directory in which to execute, defaults to the current binary dir
#   SOURCES           -- RegExps to specify source files to include, defaults to PROJECT_SOURCE_DIR
#   MODULES           -- RegExps to specify modules (binaries) to include, defaults to PROJECT_BINARY_DIR
#   EXCLUDES          -- RegExps to specify files to exclude
#   ARGS              -- Arguments to pass to the executable
#
# coverage_add_merge_target(target outputFile [FORMAT <format>])
#  Create `target` which merges all output from the previous `OpenCppCoverage_add_target` calls into `outputFile`.
#  A relative `outputFile` will be treated relative to the current binary dir.
#  FORMAT -- Output format (e.g. "html"). Defaults to "cobertura"
include( CMakeParseArguments )

option( PROJECTS_COVERAGE "Activate code coverage or not" OFF )
option( PROJECTS_COVERAGE_HTML_RESULTS "Enable HTML output for coverage merge target" OFF )

if ( PROJECTS_COVERAGE )
	if( MSVC )
		find_program( COVERAGE_TOOL_BINARY OpenCppCoverage.exe )

		if ( COVERAGE_TOOL_BINARY )
			execute_process( COMMAND "${COVERAGE_TOOL_BINARY}" --help ERROR_VARIABLE _out OUTPUT_QUIET )
			if( _out MATCHES "OpenCppCoverage Version: ([.0-9]+)" )
				set(COVERAGE_TOOL_VERSION ${CMAKE_MATCH_1})
			endif ()
		endif ()

		include( FindPackageHandleStandardArgs )
		find_package_handle_standard_args( COVERAGE_TOOL
			REQUIRED_VARS COVERAGE_TOOL_BINARY
			VERSION_VAR COVERAGE_TOOL_VERSION
		)

		if ( COVERAGE_TOOL_FOUND )
			function( coverage_add_target target )
				cmake_parse_arguments( PARSE_ARGV 1 ARG "VERBOSE" "WORKING_DIRECTORY" "SOURCES;MODULES;EXCLUDES;ARGS" )
				if ( ARG_UNPARSED_ARGUMENTS )
					message(FATAL_ERROR "Invalid argument(s): ${ARG_UNPARSED_ARGUMENTS}")
				endif ()

				get_property( counter GLOBAL PROPERTY COVERAGE_COUNTER )
				if ( NOT counter )
					set( counter 1 )
				else ()
					math( EXPR counter "${counter} + 1" )
				endif ()
				set( outputFile ${CMAKE_CURRENT_BINARY_DIR}/Coverage/cov-${counter}-${target}.bin )
				set_property( GLOBAL PROPERTY COVERAGE_COUNTER "${counter}" )
				set_property( GLOBAL APPEND PROPERTY COVERAGE_SOURCES "${outputFile}" )

				if ( NOT ARG_WORKING_DIRECTORY )
					set( ARG_WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR} )
				endif ()
				if ( NOT ARG_SOURCES )
					file( TO_NATIVE_PATH ${PROJECT_SOURCE_DIR} ARG_SOURCES )
				endif ()
				if ( NOT ARG_MODULES )
					file( TO_NATIVE_PATH ${PROJECT_BINARY_DIR} ARG_MODULES )
				endif ()

				set( args "" )
				if ( ARG_VERBOSE )
					list( APPEND args --verbose )
				else ()
					list( APPEND args --quiet )
				endif ()
				foreach( el IN LISTS ARG_EXCLUDES )
					list( APPEND args --excluded_sources ${el} )
				endforeach ()
				foreach( el IN LISTS ARG_SOURCES )
					list( APPEND args --sources ${el} )
				endforeach ()
				foreach ( el IN LISTS ARG_MODULES )
					list( APPEND args --modules ${el} )
				endforeach ()
				file( TO_NATIVE_PATH "${args}" args )
				add_custom_command( OUTPUT ${outputFile}
					DEPENDS ${target}
					COMMENT "Creating coverage for ${target}"
					COMMAND ${COVERAGE_TOOL_BINARY}
						--working_dir $<TARGET_FILE_DIR:${target}>
						--export_type binary:${outputFile}
						--cover_children
						${args}
						-- $<TARGET_FILE:${target}> ${ARG_ARGS}
					VERBATIM
				)
			endfunction()

			function( coverage_add_merge_target target outputFile )
				cmake_parse_arguments( PARSE_ARGV 2 ARG "VERBOSE" "" "" )
				if ( PROJECTS_COVERAGE_HTML_RESULTS )
					set( ARG_FORMAT html )
				else ()
					set( ARG_FORMAT cobertura )
				endif ()

				get_property( sources GLOBAL PROPERTY COVERAGE_SOURCES )
				set_property( GLOBAL PROPERTY COVERAGE_SOURCES "" )
				get_filename_component( outputFile ${outputFile} ABSOLUTE BASE_DIR ${CMAKE_CURRENT_BINARY_DIR} )
				set( args "" )
				if ( ARG_VERBOSE )
					list( APPEND args --verbose )
				endif ()
				foreach( source IN LISTS sources )
					list( APPEND args --input_coverage=${source} )
				endforeach ()
				if ( PROJECTS_COVERAGE_HTML_RESULTS )
					add_custom_command( OUTPUT ${outputFile}
						DEPENDS ${sources}
						COMMENT "Merging coverage data"
						COMMAND ${COVERAGE_TOOL_BINARY}
							--export_type html:${outputFile}
							${args}
						VERBATIM
					)
					add_custom_target( ${target} DEPENDS ${outputFile} )
				else ()
					add_custom_command( OUTPUT ${outputFile}.xml
						DEPENDS ${sources}
						COMMENT "Merging coverage data"
						COMMAND ${COVERAGE_TOOL_BINARY}
							--export_type cobertura:${outputFile}.xml
							${args}
						VERBATIM
					)
					add_custom_target( ${target} DEPENDS ${outputFile}.xml )
				endif ()
			endfunction()
		endif ()
	else ()
		find_program( COVERAGE_TOOL_BINARY gcovr )

		include( FindPackageHandleStandardArgs )
		find_package_handle_standard_args( COVERAGE_TOOL
			REQUIRED_VARS COVERAGE_TOOL_BINARY
		)

		if ( COVERAGE_TOOL_FOUND )
			function( coverage_add_target target )
				cmake_parse_arguments( PARSE_ARGV 1 ARG "VERBOSE" "WORKING_DIRECTORY" "SOURCES;MODULES;EXCLUDES;ARGS" )
				if ( ARG_UNPARSED_ARGUMENTS )
					message(FATAL_ERROR "Invalid argument(s): ${ARG_UNPARSED_ARGUMENTS}")
				endif ()

				get_property( counter GLOBAL PROPERTY COVERAGE_COUNTER )
				if ( NOT counter )
					set( counter 1 )
				else ()
					math( EXPR counter "${counter} + 1" )
				endif ()
				set( outputFile ${CMAKE_CURRENT_BINARY_DIR}/Coverage/cov-${counter}-${target}.json )
				set_property( GLOBAL PROPERTY COVERAGE_COUNTER "${counter}" )
				set_property( GLOBAL APPEND PROPERTY COVERAGE_SOURCES "${outputFile}" )

				if ( NOT ARG_WORKING_DIRECTORY )
					set( ARG_WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR} )
				endif ()
				if ( NOT ARG_SOURCES )
					file( TO_NATIVE_PATH ${PROJECT_SOURCE_DIR} ARG_SOURCES )
				endif ()
				if ( NOT ARG_MODULES )
					file( TO_NATIVE_PATH ${PROJECT_BINARY_DIR} ARG_MODULES )
				endif ()

				set( GCOVR_EXCLUDES "" )
				foreach(EXCLUDE ${ARG_EXCLUDES} )
					get_filename_component( EXCLUDE ${EXCLUDE} ABSOLUTE BASE_DIR ${PROJECT_SOURCE_DIR} )
					list( APPEND GCOVR_EXCLUDES "${EXCLUDE}" )
				endforeach()
				list( REMOVE_DUPLICATES GCOVR_EXCLUDES )

				set( args "" )
				if ( ARG_VERBOSE )
					list( APPEND args --verbose )
				endif ()
				foreach( el IN LISTS GCOVR_EXCLUDES )
					list( APPEND args --exclude ${el} )
				endforeach ()
				foreach( el IN LISTS ARG_SOURCES )
					list( APPEND args --filter ${el} )
				endforeach ()
				file( TO_NATIVE_PATH "${args}" args )
				add_custom_command( OUTPUT ${outputFile}
					DEPENDS ${target}
					COMMENT "Creating coverage for ${target}"
					COMMAND $<TARGET_FILE:${target}> ${ARG_ARGS}
					COMMAND ${CMAKE_COMMAND} -E make_directory ${CMAKE_CURRENT_BINARY_DIR}/Coverage
					COMMAND ${COVERAGE_TOOL_BINARY}
						--root ${PROJECT_SOURCE_DIR}
						${PROJECT_BINARY_DIR}
						--json ${outputFile}
						${args}
					VERBATIM
				)
			endfunction()

			function( coverage_add_merge_target target outputFile )
				cmake_parse_arguments( PARSE_ARGV 2 ARG "VERBOSE" "" "" )
				get_property( sources GLOBAL PROPERTY COVERAGE_SOURCES )
				set_property( GLOBAL PROPERTY COVERAGE_SOURCES "" )
				get_filename_component( outputFile ${outputFile} ABSOLUTE BASE_DIR ${CMAKE_CURRENT_BINARY_DIR} )
				set( args "" )
				if ( ARG_VERBOSE )
					list( APPEND args --verbose )
				endif ()
				foreach( source IN LISTS sources )
					list( APPEND args --add-tracefile ${source} )
				endforeach ()
				if ( PROJECTS_COVERAGE_HTML_RESULTS )
					add_custom_command( OUTPUT ${outputFile}/index.html
						DEPENDS ${sources}
						COMMENT "Merging coverage data"
						COMMAND ${CMAKE_COMMAND} -E make_directory ${outputFile}
						COMMAND ${COVERAGE_TOOL_BINARY}
							--root ${PROJECT_SOURCE_DIR}
							--html-details ${outputFile}/index.html
							${args}
						VERBATIM
					)
					add_custom_target( ${target} DEPENDS ${outputFile}/index.html )
				else ()
					add_custom_command( OUTPUT ${outputFile}.xml
						DEPENDS ${sources}
						COMMENT "Merging coverage data"
						COMMAND ${COVERAGE_TOOL_BINARY}
							--root ${PROJECT_SOURCE_DIR}
							--xml ${outputFile}.xml
							${args}
						VERBATIM
					)
					add_custom_target( ${target} DEPENDS ${outputFile}.xml )
				endif ()
			endfunction()
		endif ()
	endif ()
endif ()

function( target_add_coverage_flags target )
	if ( PROJECTS_COVERAGE )
		if( NOT MSVC )
			set( COVERAGE_COMPILER_FLAGS "-g --coverage -fprofile-abs-path" CACHE INTERNAL "" )
			separate_arguments( _flag_list NATIVE_COMMAND "${COVERAGE_COMPILER_FLAGS}" )
			target_compile_options( ${target} PRIVATE ${_flag_list} )
			target_link_options( ${target} PRIVATE --coverage )
		endif ()
	endif ()
endfunction()
