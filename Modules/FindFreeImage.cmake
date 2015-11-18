# FindFreeImage
# ------------
#
# Locate FreeIMage library
#
# This module defines:
#
#   FreeImage_LIBRARIES: The library to link against
#   FREEIMAGE_FOUND: If false, do not try to link to FreeImage
#   FreeImage_INCLUDE_DIR: Where to find headers.
#   FreeImage_VERSION_STRING: The version of FreeImage found.
#   FreeImage_FLAGS: The compilation flags to use FreeImage.
#
# To customise the FreeImage library version, you can use:
#
#   FreeImage_STATIC: Set it to TRUE to use the static library
#                     version of FreeImage.
#

set( FreeImage_PLATFORM "x86" )

if ( NOT FreeImage_STATIC )
	if ( WIN32 )
		set( FreeImage_LIB_SUBDIR "Dll" )
	endif ()
elseif ( "${FreeImage_STATIC}" STREQUAL "TRUE" )
	set( FreeImage_FLAGS "-DFREEIMAGE_LIB" CACHE STRING "The compilation flags to use FreeImage." )
	if ( WIN32 )
		set( FreeImage_LIB_SUBDIR "Lib" )
	endif ()
else ()
	if ( WIN32 )
		set( FreeImage_LIB_SUBDIR "Dll" )
	endif ()
endif ()

if ( MSVC )
	if ( (CMAKE_CL_64 OR CMAKE_GENERATOR MATCHES Win64) )
		set( FreeImage_PLATFORM "x64" )
	endif ()
else ()
	if ( (${CMAKE_SIZEOF_VOID_P} EQUAL 8) AND NOT MINGW )
		set( FreeImage_PLATFORM "x64" )
	endif ()
endif ()

if ( WIN32 )
	find_path( FreeImage_ROOT_DIR Dist/FreeImage.h
		HINTS
		PATH_SUFFIXES
			FreeImage
	)

	find_path( FreeImage_INCLUDE_DIR FreeImage.h 
		HINTS
		PATH_SUFFIXES
			Dist
		PATHS
			${FreeImage_ROOT_DIR}
	)

	if ( "${FreeImage_STATIC}" STREQUAL "TRUE" )
		find_path( FreeImage_LIBRARY_DEBUG_DIR FreeImaged.lib
			HINTS
			PATH_SUFFIXES
				Dist/${FreeImage_LIB_SUBDIR}/${FreeImage_PLATFORM}
				Dist/${FreeImage_PLATFORM}
			PATHS
				${FreeImage_ROOT_DIR}
		)

		find_path( FreeImage_LIBRARY_RELEASE_DIR FreeImage.lib
			HINTS
			PATH_SUFFIXES
				Dist/${FreeImage_LIB_SUBDIR}/${FreeImage_PLATFORM}
				Dist/${FreeImage_PLATFORM}
			PATHS
				${FreeImage_ROOT_DIR}
		)

		find_library( FreeImage_LIBRARY_DEBUG
			NAMES FreeImaged.lib
			HINTS
			PATHS
				${FreeImage_LIBRARY_DEBUG_DIR}
		)

		find_library( FreeImage_LIBRARY_RELEASE
			NAMES FreeImage.lib
			HINTS
			PATHS
				${FreeImage_LIBRARY_RELEASE_DIR}
		)

		if ( FreeImage_LIBRARY_RELEASE AND FreeImage_LIBRARY_DEBUG )
			set( FreeImage_LIBRARIES 
				optimized ${FreeImage_LIBRARY_RELEASE}
				debug ${FreeImage_LIBRARY_DEBUG}
			)
		elseif ( FreeImage_LIBRARY_RELEASE )
			set( FreeImage_LIBRARIES ${FreeImage_LIBRARY_RELEASE} )
		endif ()
	else ()
		find_path( FreeImage_LIBRARY_DIR FreeImage.lib
			HINTS
			PATH_SUFFIXES
				Dist/${FreeImage_LIB_SUBDIR}/${FreeImage_PLATFORM}
				Dist/${FreeImage_PLATFORM}
			PATHS
				${FreeImage_ROOT_DIR}
		)

		find_library( FreeImage_LIBRARY
			NAMES FreeImage.lib
			HINTS
			PATHS
				${FreeImage_LIBRARY_DIR}
		)

		set( FreeImage_LIBRARIES ${FreeImage_LIBRARY} )

		mark_as_advanced( FreeImage_LIBRARY_DEBUG )
		mark_as_advanced( FreeImage_LIBRARY_RELEASE )
	endif ()
else ()
	find_path( FreeImage_ROOT_DIR include/FreeImage.h Dist/FreeImage.h
		HINTS
		PATH_SUFFIXES
			FreeImage
		PATHS
			/usr/local/include
			/usr/include
	)

	find_path( FreeImage_INCLUDE_DIR FreeImage.h 
		HINTS
		PATH_SUFFIXES
            include
		PATHS
			${FreeImage_ROOT_DIR}
	)

	find_path( FreeImage_LIBRARY_DIR libfreeimage.so libFreeImage.so
		HINTS
		PATH_SUFFIXES
			lib64
			lib
		PATHS
			${FreeImage_ROOT_DIR}
	)

	find_library( FreeImage_LIBRARY
		NAMES libfreeimage.so libFreeImage.so
		HINTS
		PATH_SUFFIXES
			lib64
			lib
		PATHS
			${FreeImage_LIBRARY_DIR}
	)

	if ( FreeImage_LIBRARY )
		SET( FreeImage_LIBRARIES ${FreeImage_LIBRARY} )
	endif ()

	mark_as_advanced( FreeImage_LIBRARY )
endif ()

if ( EXISTS "${FreeImage_INCLUDE_DIR}/FreeImage.h" )
  set( FreeImage_H "${FreeImage_INCLUDE_DIR}/FreeImage.h" )
endif ()

if ( FreeImage_INCLUDE_DIR AND FreeImage_H )
    file( STRINGS "${FreeImage_H}" freeimage_version_str REGEX "^#[\t ]*define[\t ]+FREEIMAGE_(MAJOR_VERSION|MINOR_VERSION|RELEASE_SERIAL)[\t ]+[0-9]+$" )
    unset( FreeImage_VERSION_STRING )
    foreach ( VPART MAJOR_VERSION MINOR_VERSION RELEASE_SERIAL )
        foreach ( VLINE ${freeimage_version_str} )
            if ( VLINE MATCHES "^#[\t ]*define[\t ]+FREEIMAGE_${VPART}" )
                string( REGEX REPLACE "^#[\t ]*define[\t ]+FREEIMAGE_${VPART}[\t ]+([0-9]+)$" "\\1" FreeImage_VERSION_PART "${VLINE}" )
                if ( FreeImage_VERSION_STRING )
                    set( FreeImage_VERSION_STRING "${FreeImage_VERSION_STRING}.${FreeImage_VERSION_PART}" )
                else()
                    set( FreeImage_VERSION_STRING "${FreeImage_VERSION_PART}" )
                endif()
                unset( FreeImage_VERSION_PART )
            endif()
        endforeach()
    endforeach()
endif()

set( FreeImage_LIBRARY_DIRS ${FreeImage_LIBRARY_DIR} )

mark_as_advanced( FreeImage_LIBRARY_DIR )
mark_as_advanced( FreeImage_LIBRARIES )

find_package_handle_standard_args( FreeImage DEFAULT_MSG FreeImage_LIBRARIES FreeImage_INCLUDE_DIR )
