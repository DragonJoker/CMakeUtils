macro( install_dll _TARGET _LIB_FULL_PATH _CONFIGURATION )#ARGV3 _POSTFIX
	set( _POSTFIX "${ARGV3}")
	get_filename_component( _DllPath ${_LIB_FULL_PATH} PATH )
	get_filename_component( _DllName ${_LIB_FULL_PATH} NAME_WE )
	if ( EXISTS ${_DllPath}/${_DllName}${_POSTFIX}.dll )
		install(
			FILES ${_DllPath}/${_DllName}${_POSTFIX}.dll
			DESTINATION bin
			COMPONENT ${_TARGET}
			CONFIGURATIONS ${_CONFIGURATION}
		)
	else ()
		message( STATUS "_DllPath ${_DllPath}    ${_DllName}${_POSTFIX}.dll" )
		get_filename_component( _DllPath ${_DllPath} PATH )
		message( STATUS "_DllPath ${_DllPath}" )
		if ( EXISTS ${_DllPath}/lib/${_DllName}${_POSTFIX}.dll )
			install(
				FILES ${_DllPath}/lib/${_DllName}${_POSTFIX}.dll
				DESTINATION bin
				COMPONENT ${_TARGET}
				CONFIGURATIONS ${_CONFIGURATION}
			)
		elseif ( EXISTS ${_DllPath}/bin/${_DllName}${_POSTFIX}.dll )
			install(
				FILES ${_DllPath}/bin/${_DllName}${_POSTFIX}.dll
				DESTINATION bin
				COMPONENT ${_TARGET}
				CONFIGURATIONS ${_CONFIGURATION}
			)
		endif ()
	endif ()
endmacro()

function( copy_dll _TARGET _LIB_FULL_PATH_NAME )#ARGV2 _POSTFIX
	set( _POSTFIX "${ARGV2}")
	get_filename_component( _DllPathDebug ${${_LIB_FULL_PATH_NAME}_DEBUG} PATH )
	get_filename_component( _DllNameDebug ${${_LIB_FULL_PATH_NAME}_DEBUG} NAME_WE )
	get_filename_component( _DllPathRelease ${${_LIB_FULL_PATH_NAME}_RELEASE} PATH )
	get_filename_component( _DllNameRelease ${${_LIB_FULL_PATH_NAME}_RELEASE} NAME_WE )
	if ( EXISTS ${_DllPathDebug}/${_DllNameDebug}${_POSTFIX}.dll )
		add_custom_command(
			TARGET ${_TARGET}
			POST_BUILD
			COMMAND ${CMAKE_COMMAND} -E copy_if_different 
				$<$<CONFIG:Debug>:"${_DllPathDebug}/${_DllNameDebug}${_POSTFIX}.dll">
				$<$<CONFIG:Release>:"${_DllPathRelease}/${_DllNameRelease}${_POSTFIX}.dll">
				$<$<CONFIG:Debug>:"${CMAKE_RUNTIME_OUTPUT_DIRECTORY_DEBUG}${_DllNameDebug}${_POSTFIX}.dll">
				$<$<CONFIG:Release>:"${CMAKE_RUNTIME_OUTPUT_DIRECTORY_RELEASE}${_DllNameRelease}${_POSTFIX}.dll">
		)
	else ()
		get_filename_component( _DllPathDebug ${_DllPathDebug} PATH )
		get_filename_component( _DllPathRelease ${_DllPathRelease} PATH )
		if ( EXISTS ${_DllPathDebug}/lib/${_DllNameDebug}${_POSTFIX}.dll )
			add_custom_command(
				TARGET ${_TARGET}
				POST_BUILD
				COMMAND ${CMAKE_COMMAND} -E copy_if_different 
					$<$<CONFIG:Debug>:"${_DllPathDebug}/lib/${_DllNameDebug}${_POSTFIX}.dll">
					$<$<CONFIG:Release>:"${_DllPathRelease}/lib/${_DllNameRelease}${_POSTFIX}.dll">
					$<$<CONFIG:Debug>:"${CMAKE_RUNTIME_OUTPUT_DIRECTORY_DEBUG}${_DllNameDebug}${_POSTFIX}.dll">
					$<$<CONFIG:Release>:"${CMAKE_RUNTIME_OUTPUT_DIRECTORY_RELEASE}${_DllNameRelease}${_POSTFIX}.dll">
			)
		elseif ( EXISTS ${_DllPathDebug}/bin/${_DllNameDebug}${_POSTFIX}.dll )
			add_custom_command(
				TARGET ${_TARGET}
				POST_BUILD
				COMMAND ${CMAKE_COMMAND} -E copy_if_different 
					$<$<CONFIG:Debug>:"${_DllPathDebug}/bin/${_DllNameDebug}${_POSTFIX}.dll">
					$<$<CONFIG:Release>:"${_DllPathRelease}/bin/${_DllNameRelease}${_POSTFIX}.dll">
					$<$<CONFIG:Debug>:"${CMAKE_RUNTIME_OUTPUT_DIRECTORY_DEBUG}${_DllNameDebug}${_POSTFIX}.dll">
					$<$<CONFIG:Release>:"${CMAKE_RUNTIME_OUTPUT_DIRECTORY_RELEASE}${_DllNameRelease}${_POSTFIX}.dll">
			)
		endif ()
	endif ()
endfunction()