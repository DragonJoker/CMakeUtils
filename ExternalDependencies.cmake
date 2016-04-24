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
	if ( WIN32 )
		get_filename_component( _DllPath ${_LIB_FULL_PATH_NAME} PATH )
		get_filename_component( _DllName ${_LIB_FULL_PATH_NAME} NAME_WE )
		set( _DllPathSave ${_DllPath} )
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
			get_filename_component( _PathLeaf ${_DllPath} NAME )

			if ( NOT "${PROJECTS_PLATFORM}" STREQUAL "${_PathLeaf}" )
				set( _PathLeaf "" )
			else ()
				set( _PathLeaf "/${_PathLeaf}" )
				get_filename_component( _DllPath ${_DllPath} PATH )
			endif ()

			get_filename_component( _DllPath ${_DllPath} PATH )

			if ( EXISTS ${_DllPath}/lib${_PathLeaf}/${_DllPrefix}${_DllName}${_DllSuffix} )
				_copy_and_install( ${_TARGET} ${_DllPath}/lib${_PathLeaf} ${_DllPrefix}${_DllName}${_DllSuffix} ${_CONFIGURATION} )
			elseif ( EXISTS ${_DllPath}/bin${_PathLeaf}/${_DllPrefix}${_DllName}${_DllSuffix} )
				_copy_and_install( ${_TARGET} ${_DllPath}/bin${_PathLeaf} ${_DllPrefix}${_DllName}${_DllSuffix} ${_CONFIGURATION} )
			elseif ( EXISTS ${_DllPath}${_PathLeaf}/${_DllPrefix}${_DllName}${_DllSuffix} )
				_copy_and_install( ${_TARGET} ${_DllPath}${_PathLeaf} ${_DllPrefix}${_DllName}${_DllSuffix} ${_CONFIGURATION} )
			elseif ( EXISTS ${_DllPath}/lib${_PathLeaf}/${_DllName}${_DllSuffix} )
				_copy_and_install( ${_TARGET} ${_DllPath}/lib${_PathLeaf} ${_DllName}${_DllSuffix} ${_CONFIGURATION} )
			elseif ( EXISTS ${_DllPath}/bin${_PathLeaf}/${_DllName}${_DllSuffix} )
				_copy_and_install( ${_TARGET} ${_DllPath}/bin${_PathLeaf} ${_DllName}${_DllSuffix} ${_CONFIGURATION} )
			elseif ( EXISTS ${_DllPath}${_PathLeaf}/${_DllName}${_DllSuffix} )
				_copy_and_install( ${_TARGET} ${_DllPath}${_PathLeaf} ${_DllName}${_DllSuffix} ${_CONFIGURATION} )
			else ()
				set( _DllPath ${_DllPathSave} )
				get_filename_component( _PathLeaf1 ${_DllPath} NAME )
				get_filename_component( _DllPath ${_DllPath} PATH )
				get_filename_component( _PathLeaf2 ${_DllPath} NAME )
				get_filename_component( _DllPath ${_DllPath} PATH )
				get_filename_component( _PathLeaf3 ${_DllPath} NAME )
				get_filename_component( _DllPath ${_DllPath} PATH )
				set( _PathLeafs
					${_PathLeaf3}
					${_PathLeaf2}
					${_PathLeaf1}
				)

				foreach( _Leaf ${_PathLeafs} )
					if ( ( ${_Leaf} STREQUAL "lib" ) OR ( ${_Leaf} STREQUAL "bin" ) )
						set( _LibDir /lib )
						set( _BinDir /bin )
						if ( ${_PathLeaf3} STREQUAL ${_Leaf} )
							set( _Leaf3Used ON )
						elseif ( ${_PathLeaf2} STREQUAL ${_Leaf} )
							set( _Leaf2Used ON )
						elseif ( ${_PathLeaf1} STREQUAL ${_Leaf} )
							set( _Leaf1Used ON )
						endif ()
					endif ()
					if ( ( ${_Leaf} STREQUAL "Debug" ) OR ( ${_Leaf} STREQUAL "Release" ) )
						if ( ${_PathLeaf3} STREQUAL ${_Leaf} )
							set( _Leaf3Used ON )
						elseif ( ${_PathLeaf2} STREQUAL ${_Leaf} )
							set( _Leaf2Used ON )
						elseif ( ${_PathLeaf1} STREQUAL ${_Leaf} )
							set( _Leaf1Used ON )
						endif ()
					endif ()
				endforeach ()

				if ( NOT _Leaf3Used )
					set( _DllPath ${_DllPath}/${_PathLeaf3} )
				endif ()

				if ( NOT _Leaf2Used )
					set( _DllPath ${_DllPath}/${_PathLeaf2} )
				endif ()

				if ( NOT _Leaf1Used )
					set( _DllPath ${_DllPath}/${_PathLeaf1} )
				endif ()

				set( _ConfigDir /${_CONFIGURATION} )

				macro( _check_exists _DLL_NAME )
					unset( _INSTALLED )
					if ( EXISTS ${_DllPath}${_BinDir}/${_DLL_NAME} )
						_copy_and_install( ${_TARGET} ${_DllPath}${_BinDir} ${_DLL_NAME} ${_CONFIGURATION} )
						set( _INSTALLED ${_DllPath}${_BinDir}/${_DLL_NAME} )
					elseif ( EXISTS ${_DllPath}${_LibDir}/${_DLL_NAME} )
						_copy_and_install( ${_TARGET} ${_DllPath}${_LibDir} ${_DLL_NAME} ${_CONFIGURATION} )
						set( _INSTALLED ${_DllPath}${_LibDir}/${_DLL_NAME} )
					elseif ( EXISTS ${_DllPath}${_BinDir}${_ConfigDir}/${_DLL_NAME} )
						_copy_and_install( ${_TARGET} ${_DllPath}${_BinDir}${_ConfigDir} ${_DLL_NAME} ${_CONFIGURATION} )
						set( _INSTALLED ${_DllPath}${_BinDir}${_ConfigDir}/${_DLL_NAME} )
					elseif ( EXISTS ${_DllPath}${_LibDir}${_ConfigDir}/${_DLL_NAME} )
						_copy_and_install( ${_TARGET} ${_DllPath}${_LibDir}${_ConfigDir} ${_DLL_NAME} ${_CONFIGURATION} )
						set( _INSTALLED ${_DllPath}${_LibDir}${_ConfigDir}/${_DLL_NAME} )
					elseif ( EXISTS ${_DllPath}${_ConfigDir}${_BinDir}/${_DLL_NAME} )
						_copy_and_install( ${_TARGET} ${_DllPath}${_ConfigDir}${_BinDir} ${_DLL_NAME} ${_CONFIGURATION} )
						set( _INSTALLED ${_DllPath}${_ConfigDir}${_BinDir}/${_DLL_NAME} )
					elseif ( EXISTS ${_DllPath}${_ConfigDir}${_LibDir}/${_DLL_NAME} )
						_copy_and_install( ${_TARGET} ${_DllPath}${_ConfigDir}${_LibDir} ${_DLL_NAME} ${_CONFIGURATION} )
						set( _INSTALLED ${_DllPath}${_ConfigDir}${_LibDir}/${_DLL_NAME} )
					endif ()
				endmacro ()

				_check_exists( ${_DllName}${_DllSuffix} )

				if ( NOT _INSTALLED )
					_check_exists( lib${_DllName}${_DllSuffix} )
				endif ()

				if ( NOT _INSTALLED )
					msg_debug( "NOK ${_DllName}  ${_CONFIGURATION}  ${_DllPath}" )
					msg_debug( "NOK ${_DllPathSave}" )
					msg_debug( "NOK ${_DllPath}${_BinDir}/${_DllName}${_DllSuffix}" )
					msg_debug( "NOK ${_DllPath}${_LibDir}/${_DllName}${_DllSuffix}" )
					msg_debug( "NOK ${_DllPath}${_BinDir}${_ConfigDir}/${_DllName}${_DllSuffix}" )
					msg_debug( "NOK ${_DllPath}${_LibDir}${_ConfigDir}/${_DllName}${_DllSuffix}" )
					msg_debug( "NOK ${_DllPath}${_ConfigDir}${_BinDir}/${_DllName}${_DllSuffix}" )
					msg_debug( "NOK ${_DllPath}${_ConfigDir}${_LibDir}/${_DllName}${_DllSuffix}" )
				endif ()
			endif ()
		endif ()
	endif ()
endfunction()
