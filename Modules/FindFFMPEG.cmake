# - Try to find ffmpeg libraries (libavcodec, libavformat and libavutil)
# Once done this will define
#
# FFMPEG_FOUND - system has ffmpeg or libav
# FFMPEG_INCLUDE_DIR - the ffmpeg include directory
# FFMPEG_LIBRARIES - Link these to use ffmpeg
# FFMPEG_LIBAVCODEC
# FFMPEG_LIBAVFORMAT
# FFMPEG_LIBAVUTIL
#
# Copyright (c) 2008 Andreas Schneider <mail@cynapses.org>
# Modified for other libraries by Lasse Kärkkäinen <tronic>
# Modified for Hedgewars by Stepik777
#
# Redistribution and use is allowed according to the terms of the New
# BSD license.

if (FFMPEG_LIBRARIES AND FFMPEG_INCLUDE_DIR)
	# in cache already
	set(FFMPEG_FOUND TRUE)
else ()
	if ( NOT FFMPEG_FIND_COMPONENTS )
		set( FFMPEG_FIND_COMPONENTS avcodec avutil avformat swscale swresample )
	endif ()

	find_package( PkgConfig )

	if ( PKG_CONFIG_FOUND )
		pkg_check_modules( _FFMPEG_AVCODEC libavcodec )
	endif ( PKG_CONFIG_FOUND )

	find_path( FFMPEG_INCLUDE_DIR
		NAMES libavcodec/avcodec.h
		PATHS ${_FFMPEG_AVCODEC_INCLUDE_DIRS} /usr/include /usr/local/include /opt/local/include /sw/include
		PATH_SUFFIXES ffmpeg libav
	)

	foreach ( FIND_COMPONENT ${FFMPEG_FIND_COMPONENTS} )
		string( TOUPPER ${FIND_COMPONENT} FIND_COMPONENT_UPPER )
		# use pkg-config to get the directories and then use these values
		# in the FIND_PATH() and FIND_LIBRARY() calls
		if ( PKG_CONFIG_FOUND )
			pkg_check_modules(_FFMPEG_${FIND_COMPONENT_UPPER} lib${FIND_COMPONENT})
		endif ()

		find_library( FFMPEG_LIB${FIND_COMPONENT_UPPER}
			NAMES
				avcodec
			PATHS
				${_FFMPEG_${FIND_COMPONENT_UPPER}_LIBRARY_DIRS}
				/usr/lib
				/usr/local/lib
				/opt/local/lib
				/sw/lib
		)

		if ( FFMPEG_INCLUDE_DIR )
			file( STRINGS "${FFMPEG_INCLUDE_DIR}/lib${FIND_COMPONENT}/version.h" FFMPEG_VERSION_STR REGEX "^#[\t ]*define[\t ]+LIB${FIND_COMPONENT_UPPER}_VERSION_(MAJOR|MINOR|MICRO)[\t ]+[0-9]+$" )
			unset( FFMPEG_${FIND_COMPONENT_UPPER}_VERSION_STRING )
			foreach ( VPART MAJOR MINOR MICRO )
				foreach ( VLINE ${FFMPEG_VERSION_STR} )
					if ( VLINE MATCHES "^#[\t ]*define[\t ]+LIB${FIND_COMPONENT_UPPER}_VERSION_${VPART}" )
						string( REGEX REPLACE "^#[\t ]*define[\t ]+LIB${FIND_COMPONENT_UPPER}_VERSION_${VPART}[\t ]+([0-9]+)$" "\\1" FFMPEG_${FIND_COMPONENT_UPPER}_VERSION_${VPART} "${VLINE}" )
						if ( FFMPEG_${FIND_COMPONENT_UPPER}_VERSION_STRING )
							set( FFMPEG_${FIND_COMPONENT_UPPER}_VERSION_STRING "${FFMPEG_${FIND_COMPONENT_UPPER}_VERSION_STRING}.${FFMPEG_${FIND_COMPONENT_UPPER}_VERSION_${VPART}}" )
						else ()
							set( FFMPEG_${FIND_COMPONENT_UPPER}_VERSION_STRING "${FFMPEG_${FIND_COMPONENT_UPPER}_VERSION_${VPART}}" )
						endif ()
					endif ()
				endforeach ()
			endforeach ()
		endif ()
	endforeach ()

	if ( FFMPEG_LIBAVCODEC AND FFMPEG_LIBAVFORMAT )
		set( FFMPEG_FOUND TRUE )
	endif ()

	if (FFMPEG_FOUND)
		set(FFMPEG_LIBRARIES
			${FFMPEG_LIBAVCODEC}
			${FFMPEG_LIBAVFORMAT}
			${FFMPEG_LIBAVUTIL}
			${FFMPEG_LIBSWSCALE}
			${FFMPEG_LIBSWRESAMPLE}
		)
	endif (FFMPEG_FOUND)

	if (FFMPEG_FOUND)
		if (NOT FFMPEG_FIND_QUIETLY)
			message(STATUS "Found FFMPEG or Libav: ${FFMPEG_LIBRARIES}, ${FFMPEG_INCLUDE_DIR}")
		endif (NOT FFMPEG_FIND_QUIETLY)
	else (FFMPEG_FOUND)
		if (FFMPEG_FIND_REQUIRED)
			message(FATAL_ERROR "Could not find libavcodec or libavformat or libavutil or libswscale")
		endif (FFMPEG_FIND_REQUIRED)
	endif (FFMPEG_FOUND)
endif (FFMPEG_LIBRARIES AND FFMPEG_INCLUDE_DIR)
