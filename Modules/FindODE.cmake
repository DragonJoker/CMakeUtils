FIND_PATH(ODE_ROOT_DIR include/ode/ode.h ode/ode.h
	HINTS
	PATH_SUFFIXES include ode
	PATHS
	/usr/local
	/usr
)

FIND_PATH(ODE_INCLUDE_DIR ode/ode.h
	HINTS
	PATH_SUFFIXES include ode
	PATHS
	${ODE_ROOT_DIR}
)

if(MSVC)
	FIND_PATH(ODE_LIBRARY_DIR_DEBUG ode_singled.lib
		HINTS
		PATH_SUFFIXES lib lib/DebugSingleLib
		PATHS
		${ODE_ROOT_DIR}
	)
	FIND_PATH(ODE_LIBRARY_DIR_RELEASE ode_single.lib
		HINTS
		PATH_SUFFIXES lib lib/ReleaseSingleLib
		PATHS
		${ODE_ROOT_DIR}
	)
	FIND_LIBRARY(ODE_LIBRARY_DEBUG
		NAMES ode_singled.lib
		HINTS
		PATHS
		${ODE_LIBRARY_DIR_DEBUG}
	)
	FIND_LIBRARY(ODE_LIBRARY_RELEASE
		NAMES ode_single.lib
		HINTS
		PATHS
		${ODE_LIBRARY_DIR_RELEASE}
	)
	MARK_AS_ADVANCED(${ODE_LIBRARY_DEBUG} ${ODE_LIBRARY_RELEASE} ${ODE_LIBRARY_DIR_DEBUG} ${ODE_LIBRARY_DIR_RELEASE})
	find_package_handle_standard_args( ODE DEFAULT_MSG ODE_LIBRARY_DIR_RELEASE ODE_LIBRARY_DIR_DEBUG ODE_INCLUDE_DIR )
else()
	FIND_PATH(ODE_LIBRARY_DIR_RELEASE libode.so ode.lib
		HINTS
		PATH_SUFFIXES lib64 lib
		PATHS
		${ODE_ROOT_DIR}
	)
	FIND_LIBRARY(ODE_LIBRARY_RELEASE
		NAMES libode.so ode.lib
		HINTS
		PATHS
		${ODE_LIBRARY_DIR_RELEASE}
	)
	MARK_AS_ADVANCED(${ODE_LIBRARY_DIR_RELEASE})
	find_package_handle_standard_args( ODE DEFAULT_MSG ODE_LIBRARY_RELEASE ODE_INCLUDE_DIR )
endif()


if ( ODE_FOUND )
	add_library( ODE::ODE UNKNOWN IMPORTED )
	if ( ODE_LIBRARY_DEBUG )
		set( ODE_LIBRARIES
			optimized ${ODE_LIBRARY_RELEASE}
			debug ${ODE_LIBRARY_DEBUG}
			CACHE STRING "ODE library" FORCE
		)
		set_property( TARGET ODE::ODE APPEND PROPERTY
			IMPORTED_CONFIGURATIONS DEBUG )
		set_target_properties( ODE::ODE PROPERTIES
			IMPORTED_LOCATION_DEBUG "${ODE_LIBRARY_DEBUG}" )
		set_property( TARGET ODE::ODE APPEND PROPERTY
			IMPORTED_CONFIGURATIONS RELEASE)
		set_target_properties( ODE::ODE PROPERTIES
			IMPORTED_LOCATION_RELEASE "${ODE_LIBRARY_RELEASE}" )
	else ()
		set( ODE_LIBRARIES
			${ODE_LIBRARY_RELEASE}
			CACHE STRING "ODE library" FORCE
		)
		set_target_properties( ODE::ODE PROPERTIES
			IMPORTED_LOCATION "${ODE_LIBRARY_RELEASE}" )
	endif ()
	set_target_properties( ODE::ODE PROPERTIES
		INTERFACE_INCLUDE_DIRECTORIES "${ODE_INCLUDE_DIR}" )
	set( ODE_LIBRARIES
		${ODE_LIBRARIES}
		CACHE STRING "ODE libraries" FORCE
	)
	mark_as_advanced( ODE_LIBRARIES )
endif ()
