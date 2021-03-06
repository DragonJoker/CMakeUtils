# Enable CTest
enable_testing()

macro( add_target_test TARGET_NAME ) # inputArgs
	if( NOT TARGET ${TARGET_NAME} )
		message( FATAL_ERROR "AddUnitTest was given a target name that does not exist: '${TARGET_NAME}'!" )
	endif()

	set( InputArgs ${ARGN} )

	# Adding debug test
	add_test( NAME ${TARGET_NAME}_TestDebug
		CONFIGURATIONS Debug
		COMMAND "${TARGET_NAME}" ${inputArgs}
		WORKING_DIRECTORY "${CMAKE_RUNTIME_OUTPUT_DIRECTORY_DEBUG}"
	)

	# Adding release test
	add_test( NAME ${TARGET_NAME}_TestRelease
		CONFIGURATIONS Release
		COMMAND "${TARGET_NAME}" ${inputArgs}
		WORKING_DIRECTORY "${CMAKE_RUNTIME_OUTPUT_DIRECTORY_RELEASE}"
	)
endmacro( add_target_test )
