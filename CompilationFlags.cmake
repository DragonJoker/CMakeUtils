function( add_target_compilation_flags TARGET_NAME ) #ARGS
    get_target_property( TEMP ${TARGET_NAME} COMPILE_FLAGS )
    
    if ( TEMP STREQUAL "TEMP-NOTFOUND" )
        SET( TEMP "" )
    else ()
      SET( TEMP "${TEMP} " )
    endif ()
    
    foreach ( ARG ${ARGN} )
        SET( TEMP "${TEMP}${ARG} " )
    endforeach ()
    
    set_target_properties( ${TARGET_NAME} PROPERTIES COMPILE_FLAGS ${TEMP} )
endfunction( add_target_compilation_flags )

function( compute_compilation_flags TARGET_NAME TARGET_TYPE OPT_C_FLAGS OPT_CXX_FLAGS OPT_LINK_FLAGS TARGET_C_FLAGS TARGET_CXX_FLAGS TARGET_LINK_FLAGS )
	string( COMPARE EQUAL ${TARGET_TYPE} "dll" IS_DLL )
	string( COMPARE EQUAL ${TARGET_TYPE} "api_dll" IS_API_DLL )
	set( _OPT_C_FLAGS "${OPT_C_FLAGS}" )
	set( _OPT_CXX_FLAGS "${OPT_CXX_FLAGS}" )
	set( _OPT_LINK_FLAGS "${OPT_LINK_FLAGS}" )
	if ( IS_DLL OR IS_API_DLL )
    	if ( NOT ${_OPT_C_FLAGS} STREQUAL "" )
			set( _OPT_C_FLAGS " " )
		endif ()
    	if ( NOT ${_OPT_CXX_FLAGS} STREQUAL "" )
			set( _OPT_CXX_FLAGS " " )
		endif ()
		set( _OPT_C_FLAGS "-D${TARGET_NAME}_EXPORTS -D${TARGET_NAME}_SHARED" )
		set( _OPT_CXX_FLAGS "-D${TARGET_NAME}_EXPORTS -D${TARGET_NAME}_SHARED" )
	endif ()
	#We complete C/C++ compilation flags with configuration dependant ones and optional ones
	set( _C_FLAGS 		"${CMAKE_C_FLAGS} ${CMAKE_C_FLAGS_${CMAKE_BUILD_TYPE}} ${_OPT_C_FLAGS}" )
	set( _CXX_FLAGS		"${CMAKE_CXX_FLAGS} ${CMAKE_CXX_FLAGS_${CMAKE_BUILD_TYPE}} ${_OPT_CXX_FLAGS}" )
	set( _LINK_FLAGS	"${PROJECTS_PLATFORM_FLAGS} ${_OPT_LINK_FLAGS}" )
	#On GNU compiler, we use c++0x and c++1x support, and also PIC
	if ( CMAKE_COMPILER_IS_GNUCXX )
		DumpCompilerVersion( COMPILER_VERSION )
		if ( MINGW )
			if ( ${COMPILER_VERSION} LESS "46" )
				set( _C_FLAGS "${_C_FLAGS} -fPIC" )
				set( _CXX_FLAGS "${_CXX_FLAGS} -fPIC" )
			elseif ( ${COMPILER_VERSION} LESS "47" )
				set( _C_FLAGS "${_C_FLAGS} -fPIC" )
				set( _CXX_FLAGS "${_CXX_FLAGS} -fPIC -std=gnu++0x" )
			elseif ( ${COMPILER_VERSION} LESS "49" )
				set( _C_FLAGS "${_C_FLAGS} -fPIC" )
				set( _CXX_FLAGS "${_CXX_FLAGS} -fPIC -std=gnu++11 -msse2" )
			else ()
				set( _C_FLAGS "${_C_FLAGS} -fPIC" )
				set( _CXX_FLAGS "${_CXX_FLAGS} -fPIC -std=gnu++1y -msse2 -fdiagnostics-color=auto" )
			endif()
		else ()
			if ( ${COMPILER_VERSION} LESS "47" )
				set( _C_FLAGS "${_C_FLAGS} -fPIC" )
				set( _CXX_FLAGS "${_CXX_FLAGS} -fPIC -std=gnu++0x" )
			elseif ( ${COMPILER_VERSION} LESS "49" )
				set( _C_FLAGS "${_C_FLAGS} -fPIC" )
				set( _CXX_FLAGS "${_CXX_FLAGS} -fPIC -std=c++11" )
			else ()
				set( _C_FLAGS "${_C_FLAGS} -fPIC" )
				set( _CXX_FLAGS "${_CXX_FLAGS} -fPIC -std=c++1y -fdiagnostics-color=auto" )
			endif ()
		endif ()
	elseif ( ${CMAKE_CXX_COMPILER_ID} MATCHES "Clang" )
		DumpCompilerVersion( COMPILER_VERSION )
		set( _C_FLAGS "${_C_FLAGS} -fPIC" )
		set( _CXX_FLAGS "${_CXX_FLAGS} -fPIC -std=c++11" )
	endif ()
	set( ${TARGET_C_FLAGS} "${_C_FLAGS}" PARENT_SCOPE )
	set( ${TARGET_CXX_FLAGS} "${_CXX_FLAGS}" PARENT_SCOPE )
	set( ${TARGET_LINK_FLAGS} "${_LINK_FLAGS}" PARENT_SCOPE )
endfunction( compute_compilation_flags )
