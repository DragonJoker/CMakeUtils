#--------------------------------------------------------------------------------------------------
#	Macro : copy_languages
#	Used to copy language files for TARGET_NAME from SRC_FOLDER to DST_FOLDER
#--------------------------------------------------------------------------------------------------
macro( copy_languages TARGET_NAME SRC_FOLDER DST_FOLDER LANGUAGES )
	# Copy each language file into each destination folder
	foreach( LANGUAGE ${LANGUAGES} )
		set( _FILE ${CMAKE_CURRENT_SOURCE_DIR}/${SRC_FOLDER}/po/${LANGUAGE}/${TARGET_NAME}.mo )
		add_custom_command(
			TARGET ${TARGET_NAME}
			POST_BUILD
			COMMAND ${CMAKE_COMMAND} -E make_directory ${PROJECTS_BINARIES_OUTPUT_DIR}/$<CONFIGURATION>/share/${DST_FOLDER}/${LANGUAGE}
			COMMAND ${CMAKE_COMMAND} -E copy_if_different ${_FILE} ${PROJECTS_BINARIES_OUTPUT_DIR}/$<CONFIGURATION>/share/${DST_FOLDER}/${LANGUAGE}
			COMMENT "Copying ${LANGUAGE} translation file"
		)
		install(
			FILES ${_FILE}
			DESTINATION share/${DST_FOLDER}/${LANGUAGE}/
			COMPONENT ${TARGET_NAME}
		)
	endforeach()
endmacro()
