find_package( AStyle QUIET )
option( PROJECTS_USE_PRETTY_PRINTING "Enable AStyle" TRUE )

function( add_target_astyle TARGET_NAME EXT_LIST )
    if ( AStyle_FOUND AND PROJECTS_USE_PRETTY_PRINTING )
        # Retrieve project source files
        get_property( SOURCE_FILES
            TARGET ${TARGET_NAME}
            PROPERTY SOURCES
        )
        set( PROJECT_FILES )
        foreach( SOURCE ${SOURCE_FILES} )
            get_source_file_property( SOURCE_LOC "${SOURCE}" LOCATION )
            get_filename_component( SOURCE_EXT ${SOURCE_LOC} EXT )
            # Add only files with wanted extension
            foreach( EXTENSION ${EXT_LIST} )
                if ( ${SOURCE_EXT} STREQUAL ${EXTENSION} )
                    LIST( APPEND PROJECT_FILES ${SOURCE_LOC} )
                    break()
                endif()
            endforeach()
        endforeach()
	    # Add test
        if ( WIN32 )
		    set( AStyle_ARGS
		        --formatted
		        --style=allman
		        --indent=force-tab
		        --indent-namespaces
		        --break-blocks
		        --pad-oper
		        --unpad-paren
		        --pad-paren-in
		        --pad-header
		        --align-pointer=middle
		        --add-brackets
		        --suffix=none
		        --lineend=linux
		        --ascii
		    )
	    else()
		    set( AStyle_ARGS
		        --formatted
		        --style=allman
		        --indent=force-tab
		        --indent-namespaces
		        --break-blocks
		        --pad-oper
		        --unpad-paren
		        --pad-paren-in
		        --pad-header
		        --align-pointer=middle
		        --add-brackets
		        --suffix=none
		        --lineend=linux
		    )
	    endif()
        add_test(
            NAME ${TARGET_NAME}_AStyle
            COMMAND ${AStyle_BINARY} ${AStyle_ARGS} ${PROJECT_FILES}
        )
    endif()
endfunction( add_target_astyle )
