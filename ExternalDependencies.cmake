function( _copy_and_install _TARGET _PATH _FILE _CONFIGURATION )
	msg_debug( "copy_and_install ${_PATH}/${_FILE}" )
	
	if ( WIN32 )
		set( _FOLDER bin )
	else ()
		set( _FOLDER lib )
	endif ()
	
	file( GLOB _LIBRARIES ${_PATH}/${_FILE}* )
  
  foreach ( _LIBRARY ${_LIBRARIES} )
		get_filename_component( _LIB_NAME ${_LIBRARY} NAME )
		add_custom_command(
			TARGET ${_TARGET}
			POST_BUILD
			COMMAND ${CMAKE_COMMAND} -E copy_if_different
				${_LIBRARY}
				${PROJECTS_BINARIES_OUTPUT_DIR}/${_CONFIGURATION}/${_FOLDER}/${_LIB_NAME}
			COMMENT "Copying ${_FILE} into ${_FOLDER} folder"
		)
		install(
			FILES ${_LIBRARY}
			DESTINATION ${_FOLDER}
			COMPONENT ${_TARGET}
			CONFIGURATIONS ${_CONFIGURATION}
		)
	endforeach ()
endfunction()

function( copy_dll _TARGET _LIB_FULL_PATH_NAME _CONFIGURATION )# ARG4 _WIN32_SUFFIX
	get_filename_component( _DllPath ${_LIB_FULL_PATH_NAME} PATH )
	get_filename_component( _DllName ${_LIB_FULL_PATH_NAME} NAME_WE )
	string( SUBSTRING ${_DllName} 0 3 _DllPrefix )
	
	if ( "${_DllPrefix}" STREQUAL "lib" )
		string( SUBSTRING ${_DllName} 3 -1 _DllName )
	else ()
		set( _DllPrefix "" )
	endif ()
	
	if ( WIN32 )
	  set( _DllSuffix "${ARGV3}.dll" )
	else ()
	  set( _DllSuffix ".so" )
	endif ()
	
	if ( EXISTS ${_DllPath}/${_DllPrefix}${_DllName}${_DllSuffix} )
		_copy_and_install( ${_TARGET} ${_DllPath} ${_DllPrefix}${_DllName}${_DllSuffix} ${_CONFIGURATION} )
	elseif ( EXISTS ${_DllPath}/${_DllName}${_DllSuffix} )
		_copy_and_install( ${_TARGET} ${_DllPath} ${_DllName}${_DllSuffix} ${_CONFIGURATION} )
	else ()
		get_filename_component( _DllPath ${_DllPath} PATH )
		
		if ( EXISTS ${_DllPath}/lib/${_DllPrefix}${_DllName}${_DllSuffix} )
			_copy_and_install( ${_TARGET} ${_DllPath}/lib ${_DllPrefix}${_DllName}${_DllSuffix} ${_CONFIGURATION} )
		elseif ( EXISTS ${_DllPath}/bin/${_DllPrefix}${_DllName}${_DllSuffix} )
			_copy_and_install( ${_TARGET} ${_DllPath}/bin ${_DllPrefix}${_DllName}${_DllSuffix} ${_CONFIGURATION} )
		elseif ( EXISTS ${_DllPath}/${_DllPrefix}${_DllName}${_DllSuffix} )
			_copy_and_install( ${_TARGET} ${_DllPath} ${_DllPrefix}${_DllName}${_DllSuffix} ${_CONFIGURATION} )
		elseif ( EXISTS ${_DllPath}/lib/${_DllName}${_DllSuffix} )
			_copy_and_install( ${_TARGET} ${_DllPath}/lib ${_DllName}${_DllSuffix} ${_CONFIGURATION} )
		elseif ( EXISTS ${_DllPath}/bin/${_DllName}${_DllSuffix} )
			_copy_and_install( ${_TARGET} ${_DllPath}/bin ${_DllName}${_DllSuffix} ${_CONFIGURATION} )
		elseif ( EXISTS ${_DllPath}/${_DllName}${_DllSuffix} )
			_copy_and_install( ${_TARGET} ${_DllPath} ${_DllName}${_DllSuffix} ${_CONFIGURATION} )
		endif ()
	endif ()
endfunction()
