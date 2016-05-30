function( copy_target_files _TARGET _DESTINATION )# ARGN: The files
	if ( NOT "${_DESTINATION}" STREQUAL "" )
		make_directory( ${PROJECTS_BINARIES_OUTPUT_DIR}/Debug/share/${_TARGET}/${_DESTINATION} )
		make_directory( ${PROJECTS_BINARIES_OUTPUT_DIR}/Release/share/${_TARGET}/${_DESTINATION} )
		set( _DESTINATION ${_DESTINATION}/ )
	endif ()
	foreach ( _FILE ${ARGN} )
		get_filename_component( _FILE ${_FILE} REALPATH )
		get_filename_component( _FILE_NAME ${_FILE} NAME )
		add_custom_command(
			TARGET ${_TARGET}
			POST_BUILD
			COMMAND ${CMAKE_COMMAND} -E copy_if_different ${_FILE} ${PROJECTS_BINARIES_OUTPUT_DIR}/$<CONFIGURATION>/share/${_TARGET}/${_DESTINATION}${_FILE_NAME}
		)
	endforeach ()
	install(
		FILES ${ARGN}
		DESTINATION share/${_TARGET}
		COMPONENT ${_TARGET}
	)
endfunction()

function( copy_target_directory _TARGET _SOURCE ) #ARGV2: _DESTINATION
	set( _DESTINATION "${ARGV2}" )
	if ( NOT _DESTINATION STREQUAL "" )
		make_directory( ${PROJECTS_BINARIES_OUTPUT_DIR}/$<CONFIGURATION>/share/${_TARGET}/${_DESTINATION} )
	endif ()
	add_custom_command(
		TARGET ${_TARGET}
		POST_BUILD
		COMMAND ${CMAKE_COMMAND} -E copy_directory ${_SOURCE} ${PROJECTS_BINARIES_OUTPUT_DIR}/$<CONFIGURATION>/share/${_TARGET}/${_DESTINATION}
	)
	install(
		DIRECTORY ${_SOURCE}
		DESTINATION share/${_TARGET}
		COMPONENT ${_TARGET}
	)
endfunction()
