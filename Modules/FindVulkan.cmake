# FindVulkan
# ------------
#
# Locate vulkan library
#
# This module defines
#
# ::
#
#   VULKAN_LIBRARY, the library to link against
#   VULKAN_FOUND, if false, do not try to link to vulkan
#   VULKAN_INCLUDE_DIR, where to find headers.
#

FIND_PACKAGE( PackageHandleStandardArgs )

FIND_PATH(VULKAN_ROOT_DIR include/vulkan/vulkan.h 
	HINTS
	PATH_SUFFIXES
		vulkan
	PATHS
		/usr/local
		/usr
)

FIND_PATH(VULKAN_INCLUDE_DIR vulkan/vulkan.h 
	HINTS
	PATH_SUFFIXES
		include
	PATHS
		${VULKAN_ROOT_DIR}
		/usr/local/include
		/usr/include
)

if (CMAKE_CL_64 OR CMAKE_GENERATOR MATCHES Win64)
	if( WIN32 )
		FIND_PATH(VULKAN_LIBRARY_DIR vulkan-1.lib
			HINTS
			PATH_SUFFIXES
				lib/x64
				bin/x64
			PATHS
				${VULKAN_ROOT_DIR}
		)

		FIND_LIBRARY(VULKAN_LIBRARY
			NAMES
				vulkan-1.lib
			HINTS
			PATHS
				${VULKAN_LIBRARY_DIR}
		)
	else()
		FIND_PATH(VULKAN_LIBRARY_DIR libvulkan-1.so
			HINTS
			PATH_SUFFIXES
				lib64
				lib
			PATHS
				${VULKAN_ROOT_DIR}
		)

		FIND_LIBRARY(VULKAN_LIBRARY_RELEASE
			NAMES
				libvulkan-1.so
			HINTS
			PATHS
				${VULKAN_LIBRARY_DIR}
		)
	endif()
else()
	if( WIN32 )
		FIND_PATH(VULKAN_LIBRARY_DIR vulkan-1.lib
		HINTS
		PATH_SUFFIXES
			lib/x86
			bin/x86
			bin
		PATHS
			${VULKAN_ROOT_DIR}
		)

		FIND_LIBRARY(VULKAN_LIBRARY
			NAMES
				vulkan-1.lib
			HINTS
			PATHS
				${VULKAN_LIBRARY_DIR}
		)
	else()
		FIND_PATH(VULKAN_LIBRARY_DIR libvulkan-1.so
			HINTS
			PATH_SUFFIXES
				lib
			PATHS
				${VULKAN_ROOT_DIR}
		)

		FIND_LIBRARY(VULKAN_LIBRARY
			NAMES
				libvulkan-1.so
			HINTS
			PATHS
				${VULKAN_LIBRARY_DIR}
		)
	endif()
endif()

MARK_AS_ADVANCED( VULKAN_LIBRARY_DIR )
MARK_AS_ADVANCED( VULKAN_LIBRARY )
find_package_handle_standard_args( VULKAN DEFAULT_MSG VULKAN_LIBRARY VULKAN_INCLUDE_DIR )
