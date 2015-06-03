function( copy_dll _TARGET _LIB_FULL_PATH_NAME _CONFIGURATION )#ARGV3 _POSTFIX
	if (WIN32 )
		set( _POSTFIX "${ARGV3}")
		get_filename_component( _DllPath ${_LIB_FULL_PATH_NAME} PATH )
		get_filename_component( _DllName ${_LIB_FULL_PATH_NAME} NAME_WE )
		set( _HAS_CONFIG FALSE )
		if ( "${_DllPath}" MATCHES "${_CONFIGURATION}" )
			set( _HAS_CONFIG TRUE )
		endif ()
		if ( EXISTS ${_DllPath}/${_DllName}${_POSTFIX}.dll )
			add_custom_command(
				TARGET ${_TARGET}
				POST_BUILD
				COMMAND ${CMAKE_COMMAND} -E copy_if_different 
					${_DllPath}/${_DllName}${_POSTFIX}.dll
					${PROJECTS_BINARIES_OUTPUT_DIR}/$<CONFIG>/bin/${_DllName}${_POSTFIX}.dll
			)
			install(
				FILES ${_DllPath}/${_DllName}${_POSTFIX}.dll
				DESTINATION bin
				COMPONENT ${_TARGET}
				CONFIGURATIONS ${_CONFIGURATION}
			)
		else ()
			get_filename_component( _DllPath ${_DllPath} PATH )
			set( _CONFIG "" )
			if ( ${_HAS_CONFIG} )
				get_filename_component( _DllPath ${_DllPath} PATH )
				set( _CONFIG "${_CONFIGURATION}/" )
			endif ()
			if ( EXISTS ${_DllPath}/lib/${_CONFIG}${_DllName}${_POSTFIX}.dll )
				add_custom_command(
					TARGET ${_TARGET}
					POST_BUILD
					COMMAND ${CMAKE_COMMAND} -E copy_if_different 
						${_DllPath}/lib/${_CONFIG}${_DllName}${_POSTFIX}.dll
						${PROJECTS_BINARIES_OUTPUT_DIR}/$<CONFIG>/bin/${_DllName}${_POSTFIX}.dll
				)
				install(
					FILES ${_DllPath}/lib/${_CONFIG}${_DllName}${_POSTFIX}.dll
					DESTINATION bin
					COMPONENT ${_TARGET}
					CONFIGURATIONS ${_CONFIGURATION}
				)
			elseif ( EXISTS ${_DllPath}/bin/${_CONFIG}${_DllName}${_POSTFIX}.dll )
				add_custom_command(
					TARGET ${_TARGET}
					POST_BUILD
					COMMAND ${CMAKE_COMMAND} -E copy_if_different 
						${_DllPath}/bin/${_CONFIG}${_DllName}${_POSTFIX}.dll
						${PROJECTS_BINARIES_OUTPUT_DIR}/$<CONFIG>/bin/${_DllName}${_POSTFIX}.dll
				)
				install(
					FILES ${_DllPath}/bin/${_CONFIG}${_DllName}${_POSTFIX}.dll
					DESTINATION bin
					COMPONENT ${_TARGET}
					CONFIGURATIONS ${_CONFIGURATION}
				)
			elseif ( EXISTS ${_DllPath}/${_CONFIG}${_DllName}${_POSTFIX}.dll )
				add_custom_command(
					TARGET ${_TARGET}
					POST_BUILD
					COMMAND ${CMAKE_COMMAND} -E copy_if_different 
						${_DllPath}/${_CONFIG}${_DllName}${_POSTFIX}.dll
						${PROJECTS_BINARIES_OUTPUT_DIR}/$<CONFIG>/bin/${_DllName}${_POSTFIX}.dll
				)
				install(
					FILES ${_DllPath}/${_CONFIG}${_DllName}${_POSTFIX}.dll
					DESTINATION bin
					COMPONENT ${_TARGET}
					CONFIGURATIONS ${_CONFIGURATION}
				)
			endif ()
		endif ()
	endif ()
endfunction()
