# FindNGX
# ------------
#
# Locate NGX library
#
# This module defines
#
# ::
#
#   ngx target to link against
#
set( NGX_DIR NGX_DIR-ROOT-NOTFOUND CACHE STRING "NGX SDK Root Directory")

if ( "${NGX_DIR}" STREQUAL "NGX_DIR-ROOT-NOTFOUND" )
	message(FATAL_ERROR "NGX_DIR not set - please set it and rerun CMAKE Configure" )
endif()

if (WIN32)
	set( NGX_USE_STATIC_MSVCRT OFF CACHE BOOL "[Deprecated?]Use NGX libs with static VC runtime (/MT), otherwise dynamic (/MD)" )

	add_library( ngx IMPORTED SHARED GLOBAL )

	set_property( TARGET ngx APPEND PROPERTY IMPORTED_CONFIGURATIONS DEBUG)
	set_property( TARGET ngx APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)

	if(CMAKE_GENERATOR_PLATFORM STREQUAL "x64" OR CMAKE_SIZEOF_VOID_P EQUAL 8 )
		if(NGX_USE_STATIC_MSVCRT)
			set_target_properties( ngx PROPERTIES IMPORTED_IMPLIB_DEBUG ${NGX_DIR}/lib/Windows_x86_64/x64/nvsdk_ngx_s_dbg.lib )
			set_target_properties( ngx PROPERTIES IMPORTED_IMPLIB_RELEASE ${NGX_DIR}/lib/Windows_x86_64/x64/nvsdk_ngx_s.lib )
		else()
			set_target_properties( ngx PROPERTIES IMPORTED_IMPLIB_DEBUG ${NGX_DIR}/lib/Windows_x86_64/x64/nvsdk_ngx_d_dbg.lib )
			set_target_properties( ngx PROPERTIES IMPORTED_IMPLIB_RELEASE ${NGX_DIR}/lib/Windows_x86_64/x64/nvsdk_ngx_d.lib )
		endif()
	else()
		if(NGX_USE_STATIC_MSVCRT)
			set_target_properties( ngx PROPERTIES IMPORTED_IMPLIB_DEBUG ${NGX_DIR}/lib/${CMAKE_GENERATOR_PLATFORM}/nvsdk_ngx_s_dbg.lib )
			set_target_properties( ngx PROPERTIES IMPORTED_IMPLIB_RELEASE ${NGX_DIR}/lib/${CMAKE_GENERATOR_PLATFORM}/nvsdk_ngx_s.lib )
		else()
			set_target_properties( ngx PROPERTIES IMPORTED_IMPLIB_DEBUG ${NGX_DIR}/lib/${CMAKE_GENERATOR_PLATFORM}/nvsdk_ngx_d_dbg.lib )
			set_target_properties( ngx PROPERTIES IMPORTED_IMPLIB_RELEASE ${NGX_DIR}/lib/${CMAKE_GENERATOR_PLATFORM}/nvsdk_ngx_d.lib )
		endif()
	endif()
	set_target_properties(ngx PROPERTIES
		MAP_IMPORTED_CONFIG_MINSIZEREL Release
		MAP_IMPORTED_CONFIG_RELWITHDEBINFO Release
	)
	if(CMAKE_GENERATOR_PLATFORM STREQUAL "x64" OR CMAKE_SIZEOF_VOID_P EQUAL 8)
		set_target_properties( ngx PROPERTIES IMPORTED_LOCATION "${NGX_DIR}/lib/Windows_x86_64/$<IF:$<CONFIG:Debug>,dev,rel>/nvngx_dlss.dll" )
	else()
		set_target_properties( ngx PROPERTIES IMPORTED_LOCATION "${NGX_DIR}/lib/Windows_${CMAKE_GENERATOR_PLATFORM}/$<IF:$<CONFIG:Debug>,dev,rel>/default/nvngx_dlss.dll" )
	endif()
	if (CMAKE_BUILD_TYPE STREQUAL "Debug")
		file( GLOB __NGX_DLLS_LIST "${NGX_DIR}/lib/Windows_x86_64/dev/nvngx_dlss.dll" )
	else()
		file( GLOB __NGX_DLLS_LIST "${NGX_DIR}/lib/Windows_x86_64/rel/nvngx_dlss.dll" )
	endif()
else ()
	add_library( ngx IMPORTED STATIC GLOBAL )

	set_property( TARGET ngx APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE )
	set_property( TARGET ngx APPEND PROPERTY IMPORTED_CONFIGURATIONS DEBUG )
	set_target_properties( ngx PROPERTIES IMPORTED_LOCATION ${NGX_DIR}/lib/Linux_x86_64/libnvsdk_ngx.a )

	if (CMAKE_BUILD_TYPE STREQUAL "Debug")
		file( GLOB __NGX_DLLS_LIST "${NGX_DIR}/lib/Linux_x86_64/dev/libnvidia-ngx-*.so.*" )
	else()
		file( GLOB __NGX_DLLS_LIST "${NGX_DIR}/lib/Linux_x86_64/rel/libnvidia-ngx-*.so.*" )
	endif()
endif ()

set_property( TARGET ngx APPEND PROPERTY EXTRA_DLLS "${__NGX_DLLS_LIST}" )

target_include_directories( ngx INTERFACE ${NGX_DIR}/include )
