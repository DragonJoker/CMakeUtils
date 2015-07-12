
# *******************************<+>***************************************
#
# File        : FindMySQL.cmake
#
# Description : Find the native MySQL Client and MySQL Connector C++ includes and library.
#               This modules defines the following variables:
#                   MySQL_ROOT_DIR          : The MySQL root directory.
#                   MySQL_INCLUDE_DIR       : MySQL include directory.
#                   MySQL_LIBRARIES_DYNAMIC : Contains the libraries.
#                   MySQL_LIBRARIES_STATIC  : Contains the static libraries.
#
#
# *************************************************************************
# Contributors :
#    Version 1.0: 29/01/13, Author: sdoremus, Original hack
# *********************************<+>*************************************

if ( MYSQL_STATIC )
	set( _LIBTYPE STATIC )
else ()
	set( _LIBTYPE DYNAMIC )
endif ()

set( SUPPORTED_MySQL_SERVERS "5.2" "5.3" "5.4" "5.5" "5.6" )
set( CONFIGURATION x86 )
set( MySQL_SERVER_DIR "C:/Program Files (x86)/MySQL/MySQL Server" )

if ( CMAKE_CL_64 )
	set( CONFIGURATION x64 )
	set( MySQL_SERVER_DIR "C:/Program Files/MySQL/MySQL Server" )
elseif ( CMAKE_COMPILER_IS_GNUCXX AND CMAKE_SIZEOF_VOID_P EQUAL 8 )
	set( CONFIGURATION x64 )
	set( MySQL_SERVER_DIR "C:/Program Files/MySQL/MySQL Server" )
endif ()

if ( NOT MySQL_FIND_COMPONENTS )
	set( MySQL_FIND_COMPONENTS client cppconn )
endif ()

if ( WIN32 )
	foreach( SERVER ${SUPPORTED_MySQL_SERVERS} )
		if ( NOT ACTUAL_MySQL_SERVER )
			set( DIR "${MySQL_SERVER_DIR} ${SERVER}" )
			if( EXISTS "${DIR}" AND IS_DIRECTORY "${DIR}" )
				set( ACTUAL_MySQL_SERVER ${DIR} )
			endif()
		endif()
	endforeach()
endif ()

foreach( _COMPONENT ${MySQL_FIND_COMPONENTS} )
	if ( "cppconn" STREQUAL "${_COMPONENT}" )
		set( MySQL_${_COMPONENT}_ROOT_DIR
			"${MySQL_${_COMPONENT}_ROOT_DIR}"
			CACHE
			PATH
			"Path to search for MySQL Connector C++." )
		find_path( MySQL_${_COMPONENT}_ROOT_DIR 
			NAMES   include/mysql_connection.h
			DOC     "The MySQL Connector C++ include directory"
		)
		find_path( MySQL_${_COMPONENT}_INCLUDE_DIR 
			NAMES   mysql_connection.h
			HINTS   ${MySQL_${_COMPONENT}_ROOT_DIR}/include
			DOC     "The MySQL Connector C++ include directory"
		)
		
		if ( NOT MySQL_${_COMPONENT}_INCLUDE_DIR )
			message( STATUS "MySQL Connector C++ include directory not found!" )
		endif ()
	else ()
		if ( WIN32 )
			set( MySQL_LINK_FLAGS "/NODEFAULTLIB:libcmt.lib /NODEFAULTLIB:libcmtd.lib" )
			set( MySQL_${_COMPONENT}_ROOT_DIR
				"${ACTUAL_MySQL_SERVER}"
				CACHE
				PATH
				"Path to search for MySQL Client." )
		else ()
			find_path( MySQL_${_COMPONENT}_ROOT_DIR include/mysql/mysql.h
				HINTS
				PATHS
					/usr/local
					/usr
			)
		endif ()

		find_path( MySQL_${_COMPONENT}_INCLUDE_DIR mysql.h
			HINTS
				${MySQL_${_COMPONENT}_ROOT_DIR}/include
				${MySQL_${_COMPONENT}_ROOT_DIR}/include/mysql
			DOC
				"The MySQL Client include directory"
		)

		if ( NOT MySQL_${_COMPONENT}_INCLUDE_DIR )
			message( STATUS "MySQL Client include directory not found!" )
		endif ()
	endif ()
	if ( ${_LIBTYPE} STREQUAL "DYNAMIC" )
		find_library( MySQL_${_COMPONENT}_LIBRARY_RELEASE
			NAMES
				mysql${_COMPONENT}
			PATHS
				${MySQL_${_COMPONENT}_ROOT_DIR}/lib
				${MySQL_${_COMPONENT}_ROOT_DIR}/lib/opt
			DOC "The MySQL ${_COMPONENT} dynamic library release"
		)
		find_library( MySQL_${_COMPONENT}_LIBRARY_DEBUG
			NAME
				mysql${_COMPONENT}d
			PATHS
				${MySQL_${_COMPONENT}_ROOT_DIR}/lib
				${MySQL_${_COMPONENT}_ROOT_DIR}/lib/opt
			DOC "The MySQL ${_COMPONENT} dynamic library debug"
		)
	else ()
		find_library( MySQL_${_COMPONENT}_LIBRARY_RELEASE
			NAMES
				mysql${_COMPONENT}-static
			PATHS
				${MySQL_${_COMPONENT}_ROOT_DIR}/lib
				${MySQL_${_COMPONENT}_ROOT_DIR}/lib/opt
			DOC "The MySQL ${_COMPONENT} static library release"
		)
		find_library( MySQL_${_COMPONENT}_LIBRARY_DEBUG
			NAMES
				mysql${_COMPONENT}-staticd
				mysql${_COMPONENT}d-static
			PATHS
				${MySQL_${_COMPONENT}_ROOT_DIR}/lib
				${MySQL_${_COMPONENT}_ROOT_DIR}/lib/opt
			DOC "The MySQL ${_COMPONENT} static library debug"
		)
	endif ()
	mark_as_advanced(
		MySQL_${_COMPONENT}_LIBRARY_RELEASE
		MySQL_${_COMPONENT}_LIBRARY_DEBUG
	)
	if( MySQL_${_COMPONENT}_LIBRARY_RELEASE )
		if( MySQL_${_COMPONENT}_LIBRARY_DEBUG )
			set( MySQL_${_COMPONENT}_LIBRARIES optimized;${MySQL_${_COMPONENT}_LIBRARY_RELEASE};debug;${MySQL_${_COMPONENT}_LIBRARY_DEBUG} )
		else()
			set( MySQL_${_COMPONENT}_LIBRARIES ${MySQL_${_COMPONENT}_LIBRARY_RELEASE} )
		endif()
	endif()
	if ( MySQL_${_COMPONENT}_LIBRARIES )
		set( MySQL_LIBRARIES
			${MySQL_LIBRARIES}
			${MySQL_${_COMPONENT}_LIBRARIES}
		)
	endif ()
	set( MySQL_INCLUDE_DIRS
		${MySQL_INCLUDE_DIRS}
		${MySQL_${_COMPONENT}_INCLUDE_DIR}
	)
endforeach()

find_program( MySQL_COMMAND mysql
	PATHS
		/usr/bin
		/usr/local/bin
		${ACTUAL_MySQL_SERVER}/bin
)

# -----------------------------------------------------------------------
# handle the QUIETLY and REQUIRED arguments and set MySQL_FOUND to true
# if all listed variables are TRUE
# ---------------------------------------------------------------------
include( FindPackageHandleStandardArgs )
find_package_handle_standard_args( MYSQL DEFAULT_MSG MySQL_LIBRARIES MySQL_INCLUDE_DIRS )
