# FindFbxSDK
# ------------
#
# Locate FBX SDK library
#
# This module defines
#
# ::
#
#   FbxSDK_LIBRARIES, the libraries to link against
#   FbxSDK_FOUND, if false, do not try to link to FBX SDK
#   FbxSDK_INCLUDE_DIR, where to find headers.
# 

if ( NOT FbxSDK_ROOT_DIR )
	set( LOOKUP_PATHS
		C:/Program\ Files/Autodesk/FBX/FBX\ SDK/2020.3.7
		C:/Program\ Files/Autodesk/FBX/FBX\ SDK/2020.3.4
		C:/Program\ Files/Autodesk/FBX/FBX\ SDK/2020.3.2
		C:/Program\ Files/Autodesk/FBX/FBX\ SDK/2020.3.1
		C:/Program\ Files/Autodesk/FBX/FBX\ SDK/2020.2
		C:/Program\ Files/Autodesk/FBX/FBX\ SDK/2020.0
		C:/Program\ Files/Autodesk/FBX/FBX\ SDK/2019.5
		C:/Program\ Files/Autodesk/FBX/FBX\ SDK/2019.2
		C:/Program\ Files/Autodesk/FBX/FBX\ SDK/2019.0
		C:/Program\ Files/Autodesk/FBX/FBX\ SDK/2018.1.1
		C:/Program\ Files/Autodesk/FBX/FBX\ SDK/2018.0
		C:/Program\ Files/Autodesk/FBX/FBX\ SDK/2017.1
		C:/Program\ Files/Autodesk/FBX/FBX\ SDK/2017.0.1
		C:/Program\ Files/Autodesk/FBX/FBX\ SDK/2016.1.2
		C:/Program\ Files/Autodesk/FBX/FBX\ SDK/2016.1
		C:/Program\ Files/Autodesk/FBX/FBX\ SDK/2015.1
		C:/Program\ Files/Autodesk/FBX/FBX\ SDK/2014.2.1
		C:/Program\ Files/Autodesk/FBX/FBX\ SDK/2013.3
	)
	find_path(FbxSDK_ROOT_DIR include/fbxsdk.h 
		HINTS
		PATHS
			${LOOKUP_PATHS}
			/usr/local
			/usr
	)
endif ()

find_path(FbxSDK_INCLUDE_DIR fbxsdk.h 
	HINTS
	PATH_SUFFIXES
		include
	PATHS
		${FbxSDK_ROOT_DIR}
		/usr/local/include
		/usr/include
)

if ( MSVC )
	if ( CMAKE_CL_64 OR CMAKE_GENERATOR MATCHES Win64 )
		find_path(FbxSDK_SDK_LIBRARY_RELEASE_DIR libfbxsdk.lib
			HINTS
			PATH_SUFFIXES
				lib/vs2015/x64/release
				lib/x64/release
			PATHS
				${FbxSDK_ROOT_DIR}
		)
		find_path(FbxSDK_SDK_LIBRARY_DEBUG_DIR libfbxsdk.lib
			HINTS
			PATH_SUFFIXES
				lib/vs2015/x64/debug
				lib/x64/debug
				lib
			PATHS
				${FbxSDK_ROOT_DIR}
		)
	else ()
		find_path(FbxSDK_SDK_LIBRARY_RELEASE_DIR libfbxsdk.lib
			HINTS
			PATH_SUFFIXES
				lib/vs2015/x86/release
				lib/x86/release
			PATHS
				${FbxSDK_ROOT_DIR}
		)
		find_path(FbxSDK_SDK_LIBRARY_DEBUG_DIR libfbxsdk.lib
			HINTS
			PATH_SUFFIXES
				lib/vs2015/x86/debug
				lib/x86/debug
				lib
			PATHS
				${FbxSDK_ROOT_DIR}
		)
	endif ()
elseif ( CMAKE_COMPILER_IS_GNUCXX AND (${CMAKE_SIZEOF_VOID_P} EQUAL 8) )
	find_path(FbxSDK_SDK_LIBRARY_RELEASE_DIR libfbxsdk.so libfbxsdk.lib
		HINTS
		PATH_SUFFIXES
			lib/gcc4/x64/debug
			lib/x64/debug
			lib64
			lib/x64/Release
			lib/Release/x64
			lib/x64
			lib
		PATHS
			${FbxSDK_ROOT_DIR}
	)
	find_path(FbxSDK_SDK_LIBRARY_DEBUG_DIR libfbxsdk.so libfbxsdk.lib
		HINTS
		PATH_SUFFIXES
			lib/gcc4/x64/release
			lib/x64/release
			lib64
			lib/x64/Debug
			lib/Debug/x64
			lib/x64
			lib
		PATHS
			${FbxSDK_ROOT_DIR}
	)
else()
	find_path(FbxSDK_SDK_LIBRARY_RELEASE_DIR libfbxsdk.so libfbxsdk.lib
		HINTS
		PATH_SUFFIXES
			lib/x86
			lib/x86/Release
			lib/Release/x86
			lib
		PATHS
			${FbxSDK_ROOT_DIR}
	)
	find_path(FbxSDK_SDK_LIBRARY_DEBUG_DIR libfbxsdk.so libfbxsdk.lib
		HINTS
		PATH_SUFFIXES
			lib/x86
			lib/x86/Debug
			lib/Debug/x86
			lib
		PATHS
			${FbxSDK_ROOT_DIR}
	)
endif ()

if( MSVC )
	find_library(FbxSDK_SDK_LIBRARY_RELEASE
		NAMES
			libfbxsdk.lib
		HINTS
		PATHS
			${FbxSDK_SDK_LIBRARY_RELEASE_DIR}
	)
	find_library(FbxSDK_SDK_LIBRARY_DEBUG
		NAMES
			libfbxsdk.lib
		HINTS
		PATHS
			${FbxSDK_SDK_LIBRARY_DEBUG_DIR}
	)
else()
	find_library(FbxSDK_SDK_LIBRARY_RELEASE
		NAMES
			libfbxsdk.so
			libfbxsdk.lib
		HINTS
		PATHS
			${FbxSDK_SDK_LIBRARY_RELEASE_DIR}
	)
	find_library(FbxSDK_SDK_LIBRARY_DEBUG
		NAMES
			libfbxsdk.so
			libfbxsdk.lib
		HINTS
		PATHS
			${FbxSDK_SDK_LIBRARY_DEBUG_DIR}
	)
endif()

mark_as_advanced( FbxSDK_SDK_LIBRARY_RELEASE_DIR )
mark_as_advanced( FbxSDK_SDK_LIBRARY_DEBUG_DIR )
mark_as_advanced( FbxSDK_SDK_LIBRARY_RELEASE )
mark_as_advanced( FbxSDK_SDK_LIBRARY_DEBUG )
find_package_handle_standard_args( FbxSDK DEFAULT_MSG FbxSDK_SDK_LIBRARY_RELEASE FbxSDK_INCLUDE_DIR )

if ( FbxSDK_FOUND )
	if ( NOT TARGET FbxSDK::FbxSDK )
		add_library( FbxSDK::FbxSDK UNKNOWN IMPORTED )
		if ( MSVC )
			target_compile_definitions( FbxSDK::FbxSDK INTERFACE "FBXSDK_SHARED" )
		endif ()
		set_target_properties( FbxSDK::FbxSDK PROPERTIES
			INTERFACE_INCLUDE_DIRECTORIES "${FbxSDK_INCLUDE_DIR}"
			IMPORTED_LINK_INTERFACE_LANGUAGES "C" )
		if ( FbxSDK_SDK_LIBRARY_DEBUG )
			set_target_properties( FbxSDK::FbxSDK PROPERTIES
				IMPORTED_LOCATION_DEBUG ${FbxSDK_SDK_LIBRARY_DEBUG} )
		endif()
		if ( FbxSDK_SDK_LIBRARY_RELEASE )
			set_target_properties( FbxSDK::FbxSDK PROPERTIES
				IMPORTED_LOCATION_RELEASE ${FbxSDK_SDK_LIBRARY_RELEASE}
				IMPORTED_LOCATION_MINSIZEREL ${FbxSDK_SDK_LIBRARY_RELEASE}
				IMPORTED_LOCATION_RELWITHDEBINFO ${FbxSDK_SDK_LIBRARY_RELEASE} )
		endif()
	endif()
endif ()
