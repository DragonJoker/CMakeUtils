# FindOgre
# ------------
#
# Locate Ogre library and plugins
#
# This module defines
#
# ::
#
#   Ogre_LIBRARIES, the libraries to link against
#   Ogre_FOUND, if false, do not try to link to Ogre
#   Ogre_INCLUDE_DIR, where to find headers.
#   Ogre_VERSION, contains the found Ogre version number
#

if ( NOT Ogre_FIND_COMPONENTS )
	set( Ogre_FIND_COMPONENTS OgreMain RenderSystem_GL )
endif ()

FIND_PATH(Ogre_ROOT_DIR include/OGRE/Ogre.h include/Ogre.h
	HINTS
	PATH_SUFFIXES include Ogre/OgreMain
	PATHS
	/usr/local/include
	/usr/include
)

FIND_PATH(Ogre_INCLUDE_DIR Ogre.h
	HINTS
	PATH_SUFFIXES include/OGRE include
	PATHS
	${Ogre_ROOT_DIR}
)

if ( Ogre_INCLUDE_DIR )
	file( STRINGS ${Ogre_INCLUDE_DIR}/OgrePrerequisites.h _OGRE_VERSION_MAJOR REGEX "[^#]*define OGRE_VERSION_MAJOR ([0-9]*)" )
	file( STRINGS ${Ogre_INCLUDE_DIR}/OgrePrerequisites.h _OGRE_VERSION_MINOR REGEX "[^#]*define OGRE_VERSION_MINOR ([0-9]*)" )
	file( STRINGS ${Ogre_INCLUDE_DIR}/OgrePrerequisites.h _OGRE_VERSION_PATCH REGEX "[^#]*define OGRE_VERSION_PATCH ([0-9]*)" )
	string(REGEX REPLACE "[^0-9]" "" Ogre_VERSION_MAJOR ${_OGRE_VERSION_MAJOR} )
	string(REGEX REPLACE "[^0-9]" "" Ogre_VERSION_MINOR ${_OGRE_VERSION_MINOR} )
	string(REGEX REPLACE "[^0-9]" "" Ogre_VERSION_PATCH ${_OGRE_VERSION_PATCH} )
	set( Ogre_VERSION "${Ogre_VERSION_MAJOR}.${Ogre_VERSION_MINOR}.${Ogre_VERSION_PATCH}" )

	if ( Ogre_FIND_VERSION )
		if ( ${Ogre_FIND_VERSION} VERSION_GREATER ${Ogre_VERSION} )
			message( SEND_ERROR "Found version for Ogre (${Ogre_VERSION}) is less than required (${Ogre_FIND_VERSION})" )
		endif ()
	endif ()
endif ()

if(MSVC)
	FIND_PATH(Ogre_LIBRARY_DIR_DEBUG OgreMain_d.lib
		HINTS
		PATH_SUFFIXES lib/Debug lib
		PATHS
		${Ogre_ROOT_DIR}
	)
	FIND_PATH(Ogre_LIBRARY_DIR_RELEASE OgreMain.lib
		HINTS
		PATH_SUFFIXES lib lib/Release
		PATHS
		${Ogre_ROOT_DIR}
	)
	FIND_LIBRARY(Ogre_LIBRARY_DEBUG
		NAMES OgreMain_d.lib
		HINTS
		PATHS
		${Ogre_LIBRARY_DIR_DEBUG}
	)
	FIND_LIBRARY(Ogre_LIBRARY_RELEASE
		NAMES OgreMain.lib
		HINTS
		PATHS
		${Ogre_LIBRARY_DIR_RELEASE}
	)
	SET( Ogre_LIBRARIES debug ${Ogre_LIBRARY_DEBUG} optimized ${Ogre_LIBRARY_RELEASE})
	MARK_AS_ADVANCED(${Ogre_LIBRARY_DEBUG} ${Ogre_LIBRARY_RELEASE} ${Ogre_LIBRARY_DIR_DEBUG} ${Ogre_LIBRARY_DIR_RELEASE})
else()
	FIND_PATH(Ogre_LIBRARY_DIR libOgreMain.so OgreMain.lib
		HINTS
		PATH_SUFFIXES lib64 lib x86_64-linux-gnu lib/x86_64-linux-gnu
		PATHS
		${Ogre_ROOT_DIR}
	)
	FIND_PATH(Ogre_PLUGINS_DIR libRenderSystem_GL.so RenderSystem_GL.lib RenderSystem_GL.so
		HINTS
		PATH_SUFFIXES lib64 lib x86_64-linux-gnu lib/x86_64-linux-gnu
		PATHS
		${Ogre_LIBRARY_DIR}
		${Ogre_LIBRARY_DIR}/OGRE
		${Ogre_LIBRARY_DIR}/OGRE-${Ogre_VERSION}
	)
	
	foreach( _COMPONENT ${Ogre_FIND_COMPONENTS} )
		FIND_LIBRARY(Ogre_${_COMPONENT}_LIBRARY
			NAMES lib${_COMPONENT}.so ${_COMPONENT}.lib ${_COMPONENT}.so
			HINTS
			PATHS
				${Ogre_LIBRARY_DIR}
				${Ogre_PLUGINS_DIR}
		)
		if ( Ogre_${_COMPONENT}_LIBRARY )
			SET( Ogre_LIBRARIES
				${Ogre_LIBRARIES}
				${Ogre_${_COMPONENT}_LIBRARY}
			)
		endif ()
	endforeach ()
	MARK_AS_ADVANCED(${Ogre_LIBRARY_DIR})
endif()

find_package_handle_standard_args( OGRE DEFAULT_MSG Ogre_LIBRARIES Ogre_INCLUDE_DIR )
