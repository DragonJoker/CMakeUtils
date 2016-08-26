include( Logging )

function( _copy_and_install _TARGET _DLL_PATH_DEBUG _DLL_PATH_RELEASE _DLL_PATH_RELWITHDEBINFO )
	message( STATUS "copy_and_install ${_TARGET} ${_DLL_PATH_DEBUG} ${_DLL_PATH_RELEASE} ${_DLL_PATH_RELWITHDEBINFO}" )
	get_filename_component( _FILE ${_DLL_PATH_RELEASE} NAME_WE )
	get_filename_component( _LIB_NAME_DEBUG ${_DLL_PATH_DEBUG} NAME )
	get_filename_component( _LIB_NAME_RELEASE ${_DLL_PATH_RELEASE} NAME )
	get_filename_component( _LIB_NAME_RELWITHDEBINFO ${_DLL_PATH_RELWITHDEBINFO} NAME )
	add_custom_command(
		TARGET ${_TARGET}
		POST_BUILD
		COMMAND ${CMAKE_COMMAND} -E copy_if_different
			$<$<CONFIG:Debug>:${_DLL_PATH_DEBUG}>
			$<$<CONFIG:Debug>:${CMAKE_RUNTIME_OUTPUT_DIRECTORY_DEBUG}${_LIB_NAME_DEBUG}>
			$<$<CONFIG:Release>:${_DLL_PATH_RELEASE}>
			$<$<CONFIG:Release>:${CMAKE_RUNTIME_OUTPUT_DIRECTORY_RELEASE}${_LIB_NAME_RELEASE}>
			$<$<CONFIG:RelWithDebInfo>:${_DLL_PATH_RELWITHDEBINFO}>
			$<$<CONFIG:RelWithDebInfo>:${CMAKE_RUNTIME_OUTPUT_DIRECTORY_RELWITHDEBINFO}${_DLL_PATH_RELWITHDEBINFO}>
		COMMENT "Copying ${_FILE} into binary folder"
	)
	install(
		FILES ${_DLL_PATH_RELEASE}
		DESTINATION bin
		COMPONENT ${_TARGET}
		CONFIGURATIONS Release RelWithDebInfo
	)
	install(
		FILES ${_DLL_PATH_DEBUG}
		DESTINATION bin/Debug
		COMPONENT ${_TARGET}
		CONFIGURATIONS Debug
	)
endfunction()

function( _find_dll_config _OUTPUT _LIB_FULL_PATH_NAME _SUFFIX )
	get_filename_component( _DllName ${_LIB_FULL_PATH_NAME} NAME_WE )
	get_filename_component( _DllPath ${_LIB_FULL_PATH_NAME} PATH )

	if ( NOT "" STREQUAL "${_DllPath}" )
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
		set( _DllLibDir ${_DllPath} )
		set( _DllBinDir ${_DllPath} )

		foreach( _Leaf ${_PathLeafs} )
			if ( ( ${_Leaf} STREQUAL "lib" ) OR ( ${_Leaf} STREQUAL "bin" ) )
				set( _DllLibDir ${_DllLibDir}/lib )
				set( _DllBinDir ${_DllBinDir}/bin )
				if ( ${_PathLeaf3} STREQUAL ${_Leaf} )
					set( _Leaf3Used ON )
				elseif ( ${_PathLeaf2} STREQUAL ${_Leaf} )
					set( _Leaf2Used ON )
				elseif ( ${_PathLeaf1} STREQUAL ${_Leaf} )
					set( _Leaf1Used ON )
				endif ()
			else ()
				set( _DllLibDir ${_DllLibDir}/${_Leaf} )
				set( _DllBinDir ${_DllBinDir}/${_Leaf} )
			endif ()
		endforeach ()

		string( SUBSTRING ${_DllName} 0 3 _DllPrefix )

		if ( "${_DllPrefix}" STREQUAL lib )
			string( SUBSTRING ${_DllName} 3 -1 _DllName )
		else ()
			set( _DllPrefix "" )
		endif ()

		unset( _DllFile CACHE )
		find_file(
			_DllFile
			${_DllName}${_DllSuffix}
			PATHS
				${_DllLibDir}
				${_DllBinDir}
		)
		if ( _DllFile )
			msg_debug( "    Found      ${_DllFile}" )
			set( ${_OUTPUT} ${_DllFile} PARENT_SCOPE )
		else ()
			msg_debug( "${_DllName}" )
			msg_debug( "    _PathLeaf3 ${_PathLeaf3}" )
			msg_debug( "    _PathLeaf2 ${_PathLeaf2}" )
			msg_debug( "    _PathLeaf1 ${_PathLeaf1}" )
			msg_debug( "    _LibDir    ${_LibDir}" )
			msg_debug( "    _BinDir    ${_BinDir}" )
			msg_debug( "    DLL        ${_DllName}${_DllSuffix}" )
			msg_debug( "    DllPath    ${_DllPath}" )
			msg_debug( "    LibDir     ${_DllLibDir}" )
			msg_debug( "    BinDir     ${_DllBinDir}" )
			msg_debug( "    Found      ${_DllFile}" )
		endif ()
		unset( _DllFile CACHE )
	endif ()
endfunction()

function( copy_dll _TARGET _LIB_FULL_PATH_NAME_DEBUG _LIB_FULL_PATH_NAME_RELEASE )# ARG3 _SUFFIX
	if ( WIN32 )
		set( _DllSuffix "${ARGV3}.dll" )
		_find_dll_config( _DLL_FILE_DEBUG ${_LIB_FULL_PATH_NAME_DEBUG} ${_DllSuffix} )
		_find_dll_config( _DLL_FILE_RELEASE ${_LIB_FULL_PATH_NAME_RELEASE} ${_DllSuffix} )
		_find_dll_config( _DLL_FILE_RELWITHDEBINFO ${_LIB_FULL_PATH_NAME_RELEASE} ${_DllSuffix} )
		if ( _DLL_FILE_DEBUG AND _DLL_FILE_RELEASE AND _DLL_FILE_RELWITHDEBINFO )
			_copy_and_install( ${_TARGET} ${_DLL_FILE_DEBUG} ${_DLL_FILE_RELEASE} ${_DLL_FILE_RELWITHDEBINFO} )
		else ()
			msg_debug( "${_LIB_FULL_PATH_NAME_DEBUG} ${_DLL_FILE_DEBUG}" )
			msg_debug( "${_LIB_FULL_PATH_NAME_RELEASE} ${_DLL_FILE_RELEASE}" )
			msg_debug( "${_LIB_FULL_PATH_NAME_RELEASE} ${_DLL_FILE_RELWITHDEBINFO}" )
		endif ()
	endif ()
endfunction()
