
# *******************************<+>***************************************
#
# File        : FindMySQL.cmake
#
# Description : Find the native MySQL Client and MySQL Connector C++ includes and library.
#               This modules defines the following variables:
#                   MYSQL_ROOT_DIR          : The MySQL root directory.
#                   MYSQL_INCLUDE_DIR       : MySQL include directory.
#                   MYSQL_LIBRARIES_DYNAMIC : Contains the libraries.
#                   MYSQL_LIBRARIES_STATIC  : Contains the static libraries.
#
#
# *************************************************************************
# Contributors :
#    Version 1.0: 29/01/13, Author: sdoremus, Original hack
# *********************************<+>**************************************

set( SUPPORTED_MYSQL_SERVERS "5.2" "5.3" "5.4" "5.5" "5.6" )

set( CONFIGURATION x86 )
set( MYSQL_SERVER_DIR "C:/Program Files (x86)/MySQL/MySQL Server" )
if( CMAKE_CL_64 )
    set( CONFIGURATION x64 )
    set( MYSQL_SERVER_DIR "C:/Program Files/MySQL/MySQL Server" )
elseif( CMAKE_COMPILER_IS_GNUCXX AND CMAKE_SIZEOF_VOID_P EQUAL 8 )
    set( CONFIGURATION x64 )
    set( MYSQL_SERVER_DIR "C:/Program Files/MySQL/MySQL Server" )
endif()

# -----------------------------------------------------------------------
# Look for MySQL Client include DIR
# -----------------------------------------------------------------------
if( WIN32 )
    foreach( SERVER ${SUPPORTED_MYSQL_SERVERS} )
        if ( NOT ACTUAL_MYSQL_SERVER )
            set( DIR "${MYSQL_SERVER_DIR} ${SERVER}" )
            if( EXISTS "${DIR}" AND IS_DIRECTORY "${DIR}" )
                set( ACTUAL_MYSQL_SERVER ${DIR} )
            endif()
        endif()
    endforeach()
    set( MYSQL_CLIENT_ROOT_DIR
        "${ACTUAL_MYSQL_SERVER}"
        CACHE
        PATH
        "Path to search for MySQL Client." )
else()
    set( MYSQL_CLIENT_ROOT_DIR
        "${MYSQLCLIENT_ROOT_DIR}"
        CACHE
        PATH
        "Path to search for MySQL Client." )
    find_path( MYSQL_CLIENT_ROOT_DIR
        NAMES   include/mysql.h
        DOC     "The MySQL Client include directory"
    )
endif()

find_path( MYSQL_CLIENT_INCLUDE_DIR 
    NAMES   mysql.h
    HINTS   ${MYSQL_CLIENT_ROOT_DIR}/include
    DOC     "The MySQL Client include directory"
)

if( NOT MYSQL_CLIENT_INCLUDE_DIR )
    message( STATUS "MySQL Client include directory not found!" )
endif( NOT MYSQL_CLIENT_INCLUDE_DIR )

# -----------------------------------------------------------------------
# Find MySQL Client libraries
# -----------------------------------------------------------------------
find_library( MYSQL_CLIENT_LIBRARY
    NAMES mysqlclient 
    HINTS ${MYSQL_CLIENT_ROOT_DIR}/lib
    DOC "The MySQL Client library"
)

# -----------------------------------------------------------------------
# Look for MySQL Connector C++ include DIR
# -----------------------------------------------------------------------
set( MYSQL_CPP_ROOT_DIR
    "${MYSQL_CPP_ROOT_DIR}"
    CACHE
    PATH
    "Path to search for MySQL Connector C++." )
find_path( MYSQL_CPP_ROOT_DIR 
    NAMES   include/mysql_connection.h
    DOC     "The MySQL Connector C++ include directory"
)

find_path( MYSQL_CPP_INCLUDE_DIR 
    NAMES   mysql_connection.h
    HINTS   ${MYSQL_CPP_ROOT_DIR}/include
    DOC     "The MySQL Connector C++ include directory"
)

if( NOT MYSQL_CPP_INCLUDE_DIR )
    message( STATUS "MySQL Connector C++ include directory not found!" )
endif( NOT MYSQL_CPP_INCLUDE_DIR )

# -----------------------------------------------------------------------
# Find libraries
# -----------------------------------------------------------------------
if ( WIN32 )
    find_library( MYSQL_CPP_LIBRARY_DYNAMIC_RELEASE
        NAMES mysqlcppconn
        PATHS
            ${MYSQL_CPP_ROOT_DIR}/lib
            ${MYSQL_CPP_ROOT_DIR}/lib/opt
        DOC "The MySQL library"
    )

    find_library( MYSQL_CPP_LIBRARY_STATIC_RELEASE
        NAMES mysqlcppconn-static
        PATHS
            ${MYSQL_CPP_ROOT_DIR}/lib
            ${MYSQL_CPP_ROOT_DIR}/lib/opt
        DOC "The MySQL static library"
    )
    
    find_library( MYSQL_CPP_LIBRARY_DYNAMIC_DEBUG
        NAMES
            mysqlcppconn
            mysqlcppconnd
        PATHS
            ${MYSQL_CPP_ROOT_DIR}/lib/debug
        DOC "The MySQL library"
    )

    find_library( MYSQL_CPP_LIBRARY_STATIC_DEBUG
        NAMES
            mysqlcppconn-static
            mysqlcppconn-staticd
        PATHS
            ${MYSQL_CPP_ROOT_DIR}/lib/debug
        DOC "The MySQL static library"
    )
    if( MYSQL_CPP_LIBRARY_DYNAMIC_RELEASE )
        if( MYSQL_CPP_LIBRARY_DYNAMIC_DEBUG )
            set( MYSQL_LIBRARIES_DYNAMIC optimized;${MYSQL_CPP_LIBRARY_DYNAMIC_RELEASE};debug;${MYSQL_CPP_LIBRARY_DYNAMIC_DEBUG} )
        else()
            set( MYSQL_LIBRARIES_DYNAMIC ${MYSQL_CPP_LIBRARY_DYNAMIC_RELEASE} )
        endif()
    endif()
    if( MYSQL_CPP_LIBRARY_STATIC_RELEASE )
        if( MYSQL_CPP_LIBRARY_STATIC_DEBUG )
            set( MYSQL_LIBRARIES_STATIC
                ${MYSQL_CLIENT_LIBRARY}
                optimized;${MYSQL_CPP_LIBRARY_STATIC_RELEASE};debug;${MYSQL_CPP_LIBRARY_STATIC_DEBUG} )
        else()
            set( MYSQL_LIBRARIES_STATIC
                ${MYSQL_CLIENT_LIBRARY}
                ${MYSQL_CPP_LIBRARY_STATIC_RELEASE} )
        endif()
    endif()
    
    mark_as_advanced(
        MYSQL_CPP_LIBRARY_DYNAMIC_RELEASE
        MYSQL_CPP_LIBRARY_STATIC_RELEASE
        MYSQL_CPP_LIBRARY_DYNAMIC_DEBUG
        MYSQL_CPP_LIBRARY_STATIC_DEBUG
    )
else()
    find_library( MYSQL_CPP_LIBRARY_DYNAMIC
        NAMES mysqlcppconn 
        HINTS ${MYSQL_CPP_ROOT_DIR}/lib/${CONFIGURATION}
        DOC "The MySQL library"
    )

    find_library( MYSQL_CPP_LIBRARY_STATIC
        NAMES mysqlcppconn-static
        HINTS ${MYSQL_CPP_ROOT_DIR}/lib/${CONFIGURATION}
        DOC "The MySQL static library"
    )
    if( MYSQL_CPP_LIBRARY_DYNAMIC )
        set( MYSQL_LIBRARIES_DYNAMIC
            ${MYSQL_CLIENT_LIBRARY}
            ${MYSQL_CPP_LIBRARY_DYNAMIC} )
    endif()
    if( MYSQL_CPP_LIBRARY_STATIC )
        set( MYSQL_LIBRARIES_STATIC
            ${MYSQL_CLIENT_LIBRARY}
            ${MYSQL_CPP_LIBRARY_STATIC} )
    endif()
    
    mark_as_advanced(
        MYSQL_CPP_LIBRARY_DYNAMIC
        MYSQL_CPP_LIBRARY_STATIC
    )
endif()

# -----------------------------------------------------------------------
# handle the QUIETLY and REQUIRED arguments and set MYSQL_FOUND to true
# if all listed variables are TRUE
# ---------------------------------------------------------------------
include( FindPackageHandleStandardArgs )
find_package_handle_standard_args( MySQL 
    DEFAULT_MSG 
    MYSQL_CLIENT_INCLUDE_DIR
    MYSQL_CPP_INCLUDE_DIR
    MYSQL_LIBRARIES_DYNAMIC
    MYSQL_LIBRARIES_STATIC
)
