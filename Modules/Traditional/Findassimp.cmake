# FindASSIMP
# ------------
#
# Locate assimp library
#
# This module defines
#
# ::
#
#   assimp_LIBRARIES, the libraries to link against
#   assimp_FOUND, if false, do not try to link to assimp
#   assimp_INCLUDE_DIR, where to find headers.
#

FIND_PATH( assimp_DIR include/assimp/ai_assert.h 
	HINTS
	PATH_SUFFIXES
		assimp
	PATHS
		/usr/local
		/usr
)

FIND_PATH(assimp_INCLUDE_DIR assimp/ai_assert.h 
	HINTS
	PATH_SUFFIXES
		include
	PATHS
		${assimp_DIR}
		/usr/local/include
		/usr/include
)

if (CMAKE_CL_64 OR CMAKE_GENERATOR MATCHES Win64)
	if( MSVC )
		if ( CMAKE_GENERATOR STREQUAL "Visual Studio 16 2019" )
			set( VC_NUM 142 )
		elseif ( CMAKE_GENERATOR STREQUAL "Visual Studio 15 2017" )
			set( VC_NUM 141 )
		elseif ( MSVC14 )
			set( VC_NUM 140 )
		elseif ( MSVC12 )
			set( VC_NUM 120 )
		elseif ( MSVC11 )
			set( VC_NUM 110 )
		elseif ( MSVC10 )
			set( VC_NUM 100 )
		else ()
			message( SEND_ERROR "Unsupported MSVC version" )
		endif ()
		FIND_PATH( assimp_LIBRARY_RELEASE_DIR assimp.lib assimp-vc${VC_NUM}-mt.lib
			HINTS
			PATH_SUFFIXES
				lib/x64
				lib/assimp_release-dll_x64
				lib/x64/Release
				lib/Release/x64
				lib
			PATHS
				${assimp_DIR}
		)

		FIND_PATH(assimp_LIBRARY_DEBUG_DIR assimpD.lib assimpd.lib assimp-vc${VC_NUM}-mtd.lib
			HINTS
			PATH_SUFFIXES
				lib/x64
				lib/assimp_debug-dll_x64
				lib/x64/Debug
				lib/Debug/x64
				lib
			PATHS
				${assimp_DIR}
				${assimp_DIR}/debug
				${assimp_LIBRARY_RELEASE_DIR}
		)

		FIND_LIBRARY(assimp_LIBRARY_RELEASE
			NAMES
				assimp-vc${VC_NUM}-mt.lib
				assimp.lib
			HINTS
			PATHS
				${assimp_LIBRARY_RELEASE_DIR}
		)

		FIND_LIBRARY(assimp_LIBRARY_DEBUG
			NAMES
				assimp-vc${VC_NUM}-mtd.lib
				assimpD.lib
				assimpd.lib
			HINTS
			PATHS
				${assimp_LIBRARY_DEBUG_DIR}
				${assimp_LIBRARY_RELEASE_DIR}
		)
	else()
		FIND_PATH(assimp_LIBRARY_RELEASE_DIR libassimp.so libassimp.lib libassimp.dylib
			HINTS
			PATH_SUFFIXES
				lib64
				lib/assimp_release-dll_win64
				lib/x64/Release
				lib/Release/x64
				lib
			PATHS
				${assimp_DIR}
		)

		FIND_PATH(assimp_LIBRARY_DEBUG_DIR libassimp.so libassimp.lib libassimp.dylib
			HINTS
			PATH_SUFFIXES
				lib64
				lib/assimp_debug-dll_win64
				lib/x64/Debug
				lib/Debug/x64
				lib
			PATHS
				${assimp_DIR}
				${assimp_DIR}/debug
		)

		FIND_LIBRARY(assimp_LIBRARY_RELEASE
			NAMES
				libassimp.so
				libassimp.dll.a
				libassimp.dylib
			HINTS
			PATHS
				${assimp_LIBRARY_RELEASE_DIR}
		)

		FIND_LIBRARY(assimp_LIBRARY_DEBUG
			NAMES
				libassimp.so
				libassimp.dll.a
				libassimp.dylib
			HINTS
			PATHS
				${assimp_LIBRARY_DEBUG_DIR}
		)
	endif()
else()
	if( MSVC )
		if ( CMAKE_GENERATOR STREQUAL "Visual Studio 16 2019" )
			set( VC_NUM 142 )
		elseif ( CMAKE_GENERATOR STREQUAL "Visual Studio 15 2017" )
			set( VC_NUM 141 )
		elseif( MSVC14 )
			set( VC_NUM 140 )
		elseif ( MSVC12 )
			set( VC_NUM 120 )
		elseif ( MSVC11 )
			set( VC_NUM 110 )
		elseif ( MSVC10 )
			set( VC_NUM 100 )
		else ()
			message( SEND_ERROR "Unsupported MSVC version" )
		endif ()
		FIND_PATH(assimp_LIBRARY_RELEASE_DIR assimp.lib assimp-vc${VC_NUM}-mt.lib
		HINTS
		PATH_SUFFIXES
			lib/x86
			lib/assimp_release-dll_win32
			lib/x86/Release
			lib/Release/x86
			lib
		PATHS
			${assimp_DIR}
		)

		FIND_PATH(assimp_LIBRARY_DEBUG_DIR assimpD.lib assimpd.lib assimp-vc${VC_NUM}-mtd.lib
		HINTS
		PATH_SUFFIXES
			lib/x86
			lib/assimp_debug-dll_win32
			lib/x86/Debug
			lib/Debug/x86
			lib
		PATHS
			${assimp_DIR}
			${assimp_DIR}/debug
		)

		FIND_LIBRARY(assimp_LIBRARY_RELEASE
			NAMES
				assimp.lib
				assimp-vc${VC_NUM}-mt.lib
			HINTS
			PATHS
				${assimp_LIBRARY_RELEASE_DIR}
		)

		FIND_LIBRARY(assimp_LIBRARY_DEBUG
			NAMES
				assimpD.lib
				assimpd.lib
				assimp-vc${VC_NUM}-mtd.lib
			HINTS
			PATHS
				${assimp_LIBRARY_DEBUG_DIR}
		)
	elseif( MINGW )
		FIND_PATH(assimp_LIBRARY_RELEASE_DIR libassimp.dll.a
			HINTS
			PATH_SUFFIXES
				lib/mingw
				lib/x86/Debug
				lib/Debug/x86
				lib/x86
				lib
			PATHS
				${assimp_DIR}
		)

		FIND_PATH(assimp_LIBRARY_DEBUG_DIR libassimp.dll.a
			HINTS
			PATH_SUFFIXES
				lib/mingw
				lib/x86/Debug
				lib/Debug/x86
				lib/x86
				lib
			PATHS
				${assimp_DIR}
				${assimp_DIR}/debug
		)

		FIND_LIBRARY(assimp_LIBRARY_RELEASE
			NAMES
				libassimp.dll.a
			HINTS
			PATHS
				${assimp_LIBRARY_RELEASE_DIR}
		)

		FIND_LIBRARY(assimp_LIBRARY_DEBUG
			NAMES
				libassimpd.dll.a
			HINTS
			PATHS
				${assimp_LIBRARY_DEBUG_DIR}
		)
	else()
		FIND_PATH(assimp_LIBRARY_RELEASE_DIR libassimp.so libassimp.dylib
			HINTS
			PATH_SUFFIXES
				lib/assimp_release-dll_win32
				lib/x86/Release
				lib/Release/x86
				lib
			PATHS
				${assimp_DIR}
		)

		FIND_PATH(assimp_LIBRARY_DEBUG_DIR libassimp.so libassimp.dylib
			HINTS
			PATH_SUFFIXES
				lib/assimp_debug-dll_win32
				lib/x86/Debug
				lib/Debug/x86
				lib
			PATHS
				${assimp_DIR}
				${assimp_DIR}/debug
		)

		FIND_LIBRARY(assimp_LIBRARY_RELEASE
			NAMES
				libassimp.so
				libassimp.dylib
			HINTS
			PATHS
				${assimp_LIBRARY_RELEASE_DIR}
		)

		FIND_LIBRARY(assimp_LIBRARY_DEBUG
			NAMES
				libassimp.so
				libassimp.dylib
			HINTS
			PATHS
				${assimp_LIBRARY_DEBUG_DIR}
		)
	endif()
endif()

MARK_AS_ADVANCED( assimp_LIBRARY_RELEASE_DIR )
MARK_AS_ADVANCED( assimp_LIBRARY_DEBUG_DIR )
MARK_AS_ADVANCED( assimp_LIBRARY_RELEASE )
MARK_AS_ADVANCED( assimp_LIBRARY_DEBUG_DIR )
find_package_handle_standard_args( ASSIMP DEFAULT_MSG assimp_LIBRARY_RELEASE assimp_INCLUDE_DIR )

IF ( assimp_FOUND )
	IF (MSVC)
		if ( assimp_LIBRARY_DEBUG )
			SET(assimp_LIBRARIES optimized ${assimp_LIBRARY_RELEASE} debug ${assimp_LIBRARY_DEBUG} CACHE STRING "Assimp libraries")
			SET(assimp_LIBRARY_DIRS ${assimp_LIBRARY_RELEASE_DIR} ${assimp_LIBRARY_DEBUG_DIR})
		else()
			SET(assimp_LIBRARIES ${assimp_LIBRARY_RELEASE} CACHE STRING "Assimp libraries")
			SET(assimp_LIBRARY_DIRS ${assimp_LIBRARY_RELEASE_DIR})
		endif()
	ELSE ()
		if ( assimp_LIBRARY_DEBUG )
			SET(assimp_LIBRARIES optimized ${assimp_LIBRARY_RELEASE} debug ${assimp_LIBRARY_DEBUG} CACHE STRING "Assimp libraries")
			SET(assimp_LIBRARY_DIRS ${assimp_LIBRARY_RELEASE_DIR} ${assimp_LIBRARY_DEBUG_DIR})
		else()
			SET(assimp_LIBRARIES ${assimp_LIBRARY_RELEASE} CACHE STRING "Assimp libraries")
			SET(assimp_LIBRARY_DIRS ${assimp_LIBRARY_RELEASE_DIR})
		endif()
	ENDIF ()
ENDIF ()