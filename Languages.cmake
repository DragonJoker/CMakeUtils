#--------------------------------------------------------------------------------------------------
#	Macro :	copy_languages
#	Used to copy language files for TARGET_NAME from SRC_FOLDER to DST_FOLDER
#--------------------------------------------------------------------------------------------------
macro( copy_languages TARGET_NAME SRC_FOLDER DST_FOLDER LANGUAGES )
	# First compute the destination folders
	if ( MSVC )
		set( FOLDERS
			"${PROJECTS_BINARIES_OUTPUT_DIR}/Debug/share/${DST_FOLDER}"
			"${PROJECTS_BINARIES_OUTPUT_DIR}/Release/share/${DST_FOLDER}"
			"${PROJECTS_BINARIES_OUTPUT_DIR}/RelWithDebInfo/share/${DST_FOLDER}"
		)
	else ()
		set( FOLDERS
			"${PROJECTS_BINARIES_OUTPUT_DIR}/${CMAKE_BUILD_TYPE}/share/${DST_FOLDER}"
		)
	endif ()
	# Then copy each language file into each destination folder
	FOREACH( FOLDER ${FOLDERS} )
		file( MAKE_DIRECTORY "${FOLDER}" )
		FOREACH( LANGUAGE ${LANGUAGES} )
			file( MAKE_DIRECTORY "${FOLDER}/${LANGUAGE}/" )
		ENDFOREACH ()
	ENDFOREACH()
	FOREACH( LANGUAGE ${LANGUAGES} )
		set( _FILE ${CMAKE_CURRENT_SOURCE_DIR}/${SRC_FOLDER}/po/${LANGUAGE}/${TARGET_NAME}.mo )
		add_custom_command(
			TARGET ${TARGET_NAME}
			POST_BUILD
			COMMAND ${CMAKE_COMMAND} -E copy_if_different ${_FILE} ${PROJECTS_BINARIES_OUTPUT_DIR}/$<CONFIGURATION>/share/${DST_FOLDER}/${LANGUAGE}/
			COMMENT "Copying ${LANGUAGE} translation file"
		)
		install(
			FILES ${_FILE}
			DESTINATION share/${DST_FOLDER}/${LANGUAGE}/
			COMPONENT ${TARGET_NAME}
		)
	ENDFOREACH()
endmacro()
