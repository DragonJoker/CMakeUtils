function( _copy_and_install _TARGET _PATH _FILE _CONFIGURATION )
	add_custom_command(
		TARGET ${_TARGET}
		POST_BUILD
		COMMAND if 1==$<CONFIG:${_CONFIGURATION}>
			${CMAKE_COMMAND} -E copy_if_different
			${_PATH}/${_FILE}
			${PROJECTS_BINARIES_OUTPUT_DIR}/$<CONFIG>/bin/${_FILE}.dll
	)
	install(
		FILES ${_PATH}/${_FILE}
		DESTINATION bin
		COMPONENT ${_TARGET}
		CONFIGURATIONS ${_CONFIGURATION}
	)
endfunction()

function( copy_dll _TARGET _LIB_FULL_PATH_NAME _CONFIGURATION )
	if (WIN32 )
		get_filename_component( _DllPath ${_LIB_FULL_PATH_NAME} PATH )
		get_filename_component( _DllName ${_LIB_FULL_PATH_NAME} NAME_WE )
		string( SUBSTRING ${_DllName} 0 3 _DllPrefix )
		
		if ( "${_DllPrefix}" STREQUAL "lib" )
			string( SUBSTRING ${_DllName} 3 -1 _DllName )
		else ()
			set( _DllPrefix "" )
		endif ()
		
		if ( EXISTS ${_DllPath}/${_DllPrefix}${_DllName}.dll )
			_copy_and_install( ${_TARGET} ${_DllPath} ${_DllPrefix}${_DllName}.dll ${_CONFIGURATION} )
		elseif ( EXISTS ${_DllPath}/${_DllName}.dll )
			_copy_and_install( ${_TARGET} ${_DllPath} ${_DllName}.dll ${_CONFIGURATION} )
		else ()
			get_filename_component( _DllPath ${_DllPath} PATH )
			
			if ( EXISTS ${_DllPath}/lib/${_DllPrefix}${_DllName}.dll )
				_copy_and_install( ${_TARGET} ${_DllPath}/lib ${_DllPrefix}${_DllName}.dll ${_CONFIGURATION} )
			elseif ( EXISTS ${_DllPath}/bin/${_DllPrefix}${_DllName}.dll )
				_copy_and_install( ${_TARGET} ${_DllPath}/bin ${_DllPrefix}${_DllName}.dll ${_CONFIGURATION} )
			elseif ( EXISTS ${_DllPath}/${_DllPrefix}${_DllName}.dll )
				_copy_and_install( ${_TARGET} ${_DllPath} ${_DllPrefix}${_DllName}.dll ${_CONFIGURATION} )
			elseif ( EXISTS ${_DllPath}/lib/${_CONFIGURATION}/${_DllPrefix}${_DllName}.dll )
				_copy_and_install( ${_TARGET} ${_DllPath}/lib/${_CONFIGURATION} ${_DllPrefix}${_DllName}.dll ${_CONFIGURATION} )
			elseif ( EXISTS ${_DllPath}/bin/${_CONFIGURATION}/${_DllPrefix}${_DllName}.dll )
				_copy_and_install( ${_TARGET} ${_DllPath}/bin/${_CONFIGURATION} ${_DllPrefix}${_DllName}.dll ${_CONFIGURATION} )
			elseif ( EXISTS ${_DllPath}/${_CONFIGURATION}/${_DllPrefix}${_DllName}.dll )
				_copy_and_install( ${_TARGET} ${_DllPath}/${_CONFIGURATION} ${_DllPrefix}${_DllName}.dll ${_CONFIGURATION} )
			elseif ( EXISTS ${_DllPath}/lib/${_DllName}.dll )
				_copy_and_install( ${_TARGET} ${_DllPath}/lib ${_DllName}.dll ${_CONFIGURATION} )
			elseif ( EXISTS ${_DllPath}/bin/${_DllName}.dll )
				_copy_and_install( ${_TARGET} ${_DllPath}/bin ${_DllName}.dll ${_CONFIGURATION} )
			elseif ( EXISTS ${_DllPath}/${_DllName}.dll )
				_copy_and_install( ${_TARGET} ${_DllPath} ${_DllName}.dll ${_CONFIGURATION} )
			elseif ( EXISTS ${_DllPath}/lib/${_CONFIGURATION}/${_DllName}.dll )
				_copy_and_install( ${_TARGET} ${_DllPath}/lib/${_CONFIGURATION} ${_DllName}.dll ${_CONFIGURATION} )
			elseif ( EXISTS ${_DllPath}/bin/${_CONFIGURATION}/${_DllName}.dll )
				_copy_and_install( ${_TARGET} ${_DllPath}/bin/${_CONFIGURATION} ${_DllName}.dll ${_CONFIGURATION} )
			elseif ( EXISTS ${_DllPath}/${_CONFIGURATION}/${_DllName}.dll )
				_copy_and_install( ${_TARGET} ${_DllPath}/${_CONFIGURATION} ${_DllName}.dll ${_CONFIGURATION} )
			endif ()
		endif ()
	endif ()
endfunction()
