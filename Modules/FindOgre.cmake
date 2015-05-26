FIND_PATH(Ogre_ROOT_DIR include/OGRE/Ogre.h include/Ogre.h
	HINTS
	PATH_SUFFIXES include Ogre/OgreMain
	PATHS
	/usr/local/include
	/usr/include
)

FIND_PATH(Ogre_INCLUDE_DIR Ogre.h
	HINTS
	PATH_SUFFIXES OGRE
	PATHS
	${Ogre_ROOT_DIR}
)

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
		PATH_SUFFIXES lib64 lib x86_64-linux-gnu
		PATHS
		${Ogre_ROOT_DIR}
	)
	FIND_LIBRARY(Ogre_LIBRARY
		NAMES libOgreMain.so OgreMain.lib
		HINTS
		PATHS
		${Ogre_LIBRARY_DIR}
	)
	SET( Ogre_LIBRARIES ${Ogre_LIBRARY})
	MARK_AS_ADVANCED(${Ogre_LIBRARY_DIR})
endif()

find_package_handle_standard_args( OGRE DEFAULT_MSG Ogre_LIBRARIES Ogre_INCLUDE_DIR )
