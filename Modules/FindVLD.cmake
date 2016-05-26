###########################################################
#
# Find Visual Leak Detector on client machine
#
## 1: Setup:
# The following variables are searched for defaults
#  VLD_ROOT_DIR:            Base directory of VLD tree to use.
#
## 2: Variable
# The following are set after configuration is done: 
#  
#  VLD_INCLUDE_DIR
#  VLD_LIBRARY
#
###########################################################

FIND_PACKAGE( PackageHandleStandardArgs )

if( MSVC )
	FIND_PATH(VLD_ROOT_DIR include/vld.h 
		HINTS
		PATH_SUFFIXES include vld "Visual Leak Detector"
		PATHS
		/usr/local
		/usr
		C:/ Z:/
	)

	FIND_PATH(VLD_INCLUDE_DIR vld.h
	  HINTS
	  PATH_SUFFIXES include
	  PATHS
	  ${VLD_ROOT_DIR}
	)

	if (CMAKE_CL_64 OR CMAKE_GENERATOR MATCHES Win64)
		FIND_PATH(VLD_LIBRARY_DIR vld.lib
			HINTS
				PATH_SUFFIXES lib/Win64
				PATHS ${VLD_ROOT_DIR}
		)
	else ()
		FIND_PATH(VLD_LIBRARY_DIR vld.lib
			HINTS
				PATH_SUFFIXES lib/Win32
				PATHS ${VLD_ROOT_DIR}
		)
	endif ()

	FIND_LIBRARY(VLD_LIBRARY
		NAMES vld.lib
		PATHS
			${VLD_LIBRARY_DIR}
	)

	MARK_AS_ADVANCED( VLD_LIBRARY_DIR VLD_LIBRARY )
endif()

find_package_handle_standard_args( VLD DEFAULT_MSG VLD_LIBRARY VLD_INCLUDE_DIR )