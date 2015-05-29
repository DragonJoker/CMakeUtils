function( copy_target_files _TARGET _DESTINATION )# ARGN: The files
	if ( NOT "${_DESTINATION}" STREQUAL "" )
		set( _DESTINATION ${_DESTINATION}/ )
		add_custom_command(
			TARGET ${_TARGET}
			POST_BUILD
			COMMAND ${CMAKE_COMMAND} -E make_directory ${PROJECTS_BINARIES_OUTPUT_DIR}/$<CONFIG>/bin/${_DESTINATION}
		)
	endif ()
	foreach ( _FILE ${ARGN} )
		get_filename_component( _FILE_NAME ${_FILE} NAME )
		add_custom_command(
			TARGET ${_TARGET}
			POST_BUILD
			COMMAND ${CMAKE_COMMAND} -E copy_if_different ${_FILE} ${PROJECTS_BINARIES_OUTPUT_DIR}/$<CONFIG>/bin/${_DESTINATION}${_FILE_NAME}
		)
	endforeach ()
endfunction()

function( copy_target_directory _TARGET _SOURCE ) #ARGV2: _DESTINATION
	set( _DESTINATION "${ARGV2}" )
	message( STATUS "_DESTINATION ${_DESTINATION}" )
	if ( NOT _DESTINATION STREQUAL "" )
		set( _DESTINATION ${_DESTINATION}/ )
		add_custom_command(
			TARGET ${_TARGET}
			POST_BUILD
			COMMAND ${CMAKE_COMMAND} -E make_directory ${PROJECTS_BINARIES_OUTPUT_DIR}/$<CONFIG>/bin/${_DESTINATION}
		)
	endif ()
	add_custom_command(
		TARGET ${_TARGET}
		POST_BUILD
		COMMAND ${CMAKE_COMMAND} -E copy_directory ${_SOURCE} ${PROJECTS_BINARIES_OUTPUT_DIR}/$<CONFIG>/bin/${_DESTINATION}${_FILE_NAME}
	)
endfunction()
