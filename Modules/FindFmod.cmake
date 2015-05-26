FIND_PATH( Fmod_ROOT_DIR inc/fmod.hpp include/fmod.hpp
	HINTS
	PATH_SUFFIXES
		fmod/api
	PATHS
		/usr/local
		/usr
)

FIND_PATH( Fmod_INCLUDE_DIR fmod.hpp
	HINTS
	PATH_SUFFIXES
		include
		inc
	PATHS
		${Fmod_ROOT_DIR}
)

FIND_PATH( Fmod_LIBRARY_DIR fmodex_vc.lib libfmodex.so
	HINTS
	PATH_SUFFIXES
		lib64
		lib
	PATHS
		${Fmod_ROOT_DIR}
)

FIND_LIBRARY(Fmod_LIBRARY
	NAMES
		fmodex_vc.lib
		libfmodex.so
	HINTS
	PATH_SUFFIXES
		lib64
		lib
	PATHS
		${Fmod_LIBRARY_DIR}
)

MARK_AS_ADVANCED( Fmod_LIBRARY_DIR )
MARK_AS_ADVANCED( Fmod_LIBRARY )

SET( Fmod_LIBRARY_DIRS ${Fmod_LIBRARY_DIR} )
SET( Fmod_LIBRARIES ${Fmod_LIBRARY} )

find_package_handle_standard_args( Fmod DEFAULT_MSG Fmod_LIBRARIES Fmod_INCLUDE_DIR )
