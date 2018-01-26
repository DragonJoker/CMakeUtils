# Find OpenGL ES 3
# ----------------
#
# Finds the SPIRV library.
#
# This module defines:
#
# ::
#
#   SPIRV_FOUND        - True if SPIRV library is found.
#   SPIRV_INCLUDE_DIR  - The SPIRV include directiories.
#   SPIRV_LIBRARIES    - The SPIRV libraries.
#

find_package( PackageHandleStandardArgs )

find_path( SPIRV_ROOT_DIR include/SPIRV/spirv.hpp
	HINTS
	PATHS
		/usr/local
		/usr
)


if ( SPIRV_ROOT_DIR )
	find_path( SPIRV_INCLUDE_DIR SPIRV/spirv.hpp
		HINTS
		PATH_SUFFIXES
			include
		PATHS
			${SPIRV_ROOT_DIR}
			/usr/local/include
			/usr/include
	)

	if (CMAKE_CL_64 OR CMAKE_GENERATOR MATCHES Win64)
		set( PLATFORM "x64" )
	else ()
		set( PLATFORM "x86" )
	endif ()
	if ( WIN32 )
		set( LIB_EXTENSION "lib" )
		set( LIB_PREFIX "" )
	else ()
		set( LIB_EXTENSION "so" )
		set( LIB_PREFIX "lib" )
	endif ()

	find_path( SPIRV_LIBRARY_RELEASE_DIR ${LIB_PREFIX}SPIRV.${LIB_EXTENSION}
		HINTS
		PATH_SUFFIXES
			lib/${PLATFORM}/Release
			lib/${PLATFORM}
			/usr/local/lib
			/usr/lib
		PATHS
			${SPIRV_ROOT_DIR}
	)

	find_path( SPIRV_LIBRARY_DEBUG_DIR ${LIB_PREFIX}SPIRV.${LIB_EXTENSION}
		HINTS
		PATH_SUFFIXES
			lib/${PLATFORM}/Debug
			/usr/local/lib
			/usr/lib
		PATHS
			${SPIRV_ROOT_DIR}
	)

	find_library( SPIRV_LIBRARY_RELEASE
		NAMES
			${LIB_PREFIX}SPIRV.${LIB_EXTENSION}
		HINTS
		PATHS
			${SPIRV_LIBRARY_RELEASE_DIR}
	)

	find_library( SPIRV_LIBRARY_DEBUG
		NAMES
			${LIB_PREFIX}SPIRV.${LIB_EXTENSION}
		HINTS
		PATHS
			${SPIRV_LIBRARY_DEBUG_DIR}
	)

	find_library( SPIRVTOOLS_LIBRARY_RELEASE
		NAMES
			${LIB_PREFIX}SPIRV-Tools.${LIB_EXTENSION}
		HINTS
		PATHS
			${SPIRV_LIBRARY_RELEASE_DIR}
	)

	find_library( SPIRVTOOLS_LIBRARY_DEBUG
		NAMES
			${LIB_PREFIX}SPIRV-Tools.${LIB_EXTENSION}
		HINTS
		PATHS
			${SPIRV_LIBRARY_DEBUG_DIR}
	)

	mark_as_advanced( SPIRV_LIBRARY_RELEASE_DIR )
	mark_as_advanced( SPIRV_LIBRARY_DEBUG_DIR )
	mark_as_advanced( SPIRV_LIBRARY_RELEASE )
	mark_as_advanced( SPIRV_LIBRARY_DEBUG )
	mark_as_advanced( SPIRVTOOLS_LIBRARY_RELEASE )
	mark_as_advanced( SPIRVTOOLS_LIBRARY_DEBUG )
	find_package_handle_standard_args( SPIRV DEFAULT_MSG SPIRV_LIBRARY_RELEASE SPIRV_INCLUDE_DIR )

	IF ( SPIRV_FOUND )
		if ( MSVC )
			if ( SPIRV_LIBRARY_DEBUG )
				set( SPIRV_LIBRARIES
					optimized ${SPIRV_LIBRARY_RELEASE}
					debug ${SPIRV_LIBRARY_DEBUG}
					optimized ${SPIRVTOOLS_LIBRARY_RELEASE}
					debug ${SPIRVTOOLS_LIBRARY_DEBUG}
					CACHE STRING "SPIRV libraries" )
				set( SPIRV_LIBRARY_DIRS ${SPIRV_LIBRARY_RELEASE_DIR} ${SPIRV_LIBRARY_DEBUG_DIR} )
			else()
				set( SPIRV_LIBRARIES
					${SPIRV_LIBRARY_RELEASE}
					${SPIRVTOOLS_LIBRARY_RELEASE}
					CACHE STRING "SPIRV libraries" )
				set( SPIRV_LIBRARY_DIRS ${SPIRV_LIBRARY_RELEASE_DIR} )
			endif()
		else ()
			set( SPIRV_LIBRARIES
				${SPIRV_LIBRARY_RELEASE}
				${SPIRVTOOLS_LIBRARY_RELEASE}
				CACHE STRING "SPIRV libraries" )
			set( SPIRV_LIBRARY_DIRS ${SPIRV_LIBRARY_RELEASE_DIR} )
		endif ()
	ENDIF ()
endif ()
