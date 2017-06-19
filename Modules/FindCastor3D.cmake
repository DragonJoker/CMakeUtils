# FindCastor3D
# ------------
#
# Locate Castor3D library
#
# This module defines
#
# ::
#
#   Castor3D_LIBRARIES, the libraries to link against
#   Castor3D_FOUND, if false, do not try to link to Castor3D
#   Castor3D_INCLUDE_DIRS, where to find headers.
#

find_package( PackageHandleStandardArgs )

if ( NOT Castor3D_FIND_COMPONENTS )
	set( Castor3D_FIND_COMPONENTS CastorUtils GlslWriter Castor3D GuiCommon CastorTest )
endif ()

#--------------------------------------------------------------------------------------------------
#	Function :	DumpCompilerVersion
# 	Function which gives the GNU Compiler version, used to build name of project's libs
#--------------------------------------------------------------------------------------------------
function( dump_compiler_version OUTPUT_VERSION)
	exec_program( ${CMAKE_CXX_COMPILER}
        ARGS ${CMAKE_CXX_COMPILER_ARG1} -dumpversion 
        OUTPUT_VARIABLE COMPILER_VERSION
    )
	string( REGEX 
        REPLACE
        "([0-9])\\.([0-9])(\\.[0-9])?" "\\1\\2"
        COMPILER_VERSION
        ${COMPILER_VERSION}
    )
	set( ${OUTPUT_VERSION} ${COMPILER_VERSION} PARENT_SCOPE )
endfunction()

#--------------------------------------------------------------------------------------------------
#	Function :	compute_abi_name
# 	Function which computes the extended library name, with compiler version and debug flag
#--------------------------------------------------------------------------------------------------
function( compute_abi_name ABI_Name ABI_Name_Debug )
	if ( MSVC14 )
		set( COMPILER "vc15" )
	elseif ( MSVC14 )
		set( COMPILER "vc14" )
	elseif ( MSVC12 )
		set( COMPILER "vc12" )
	elseif ( MSVC11 )
		set( COMPILER "vc11" )
	elseif ( MSVC10 )
		set( COMPILER "vc10" )
	elseif ( MSVC90 )
		set( COMPILER "vc9" )
	elseif ( MSVC80 )
		set( COMPILER "vc8" )
	elseif ( MSVC71 )
		set( COMPILER "vc7_1" )
	elseif ( MSVC70 )
		set( COMPILER "vc7" )
	elseif ( MSVC60 )
		set( COMPILER "vc6" )
	elseif ( ${CMAKE_CXX_COMPILER_ID} STREQUAL "Intel" OR ${CMAKE_CXX_COMPILER} MATCHES "icl" OR ${CMAKE_CXX_COMPILER} MATCHES "icpc" )
		set( COMPILER "icc" )
	elseif (BORLAND)
		set( _ABI_Name "-bcb")
	elseif("${CMAKE_CXX_COMPILER_ID}" STREQUAL "SunPro")
		set( _ABI_Name "sw")
	elseif ( CMAKE_COMPILER_IS_GNUCXX )
		dump_compiler_version( COMPILER_VERSION )
		if ( MINGW )
			set( COMPILER "mingw${COMPILER_VERSION}" )
		elseif ( CYGWIN )
			set( COMPILER "cygw${COMPILER_VERSION}" )
		elseif ( APPLE )
			set( _ABI_Name "xgcc${COMPILER_VERSION}")
		else ()
			set( COMPILER "gcc${COMPILER_VERSION}" )
		endif ()
	endif ()
	set( _ABI_Name "-${COMPILER}")
	set( _ABI_Name_Debug "-d")
	set( ${ABI_Name} ${_ABI_Name} PARENT_SCOPE )
	set( ${ABI_Name_Debug} ${_ABI_Name}${_ABI_Name_Debug} PARENT_SCOPE )
endfunction( compute_abi_name )

set( Castor3D_FOUND TRUE )

set( Castor3D_INCLUDE_DIRS "" CACHE STRING "Castor3D include directories" FORCE )
set( Castor3D_LIBRARIES "" CACHE STRING "Castor3D libraries" FORCE )

find_path( Castor3D_ROOT_DIR include/Castor3D/Castor3DPrerequisites.hpp
	HINTS
	PATH_SUFFIXES
		Castor3D
	PATHS
		/usr/local
		/usr
)

if ( Castor3D_ROOT_DIR )
	foreach( COMPONENT ${Castor3D_FIND_COMPONENTS} )
		set( ABI_Name )
		set( ABI_Name_Debug )
		if ( ( ${COMPONENT} STREQUAL GuiCommon ) OR ( ${COMPONENT} STREQUAL CastorTest ) )
			compute_abi_name( ABI_Name ABI_Name_Debug )
		else ()
			set( ABI_Name )
			set( ABI_Name_Debug "d" )
		endif ()

		find_path( Castor3D_${COMPONENT}_INCLUDE_DIR ${COMPONENT}Prerequisites.hpp
			HINTS
			PATH_SUFFIXES
				include/${COMPONENT}
			PATHS
				${Castor3D_ROOT_DIR}
				/usr/local/include
				/usr/include
		)

		if( MSVC )
			find_path( Castor3D_${COMPONENT}_LIBRARY_RELEASE_DIR ${COMPONENT}${ABI_Name}.lib
				HINTS
				PATH_SUFFIXES
					lib
				PATHS
					${Castor3D_ROOT_DIR}
			)
			find_path( Castor3D_${COMPONENT}_LIBRARY_DEBUG_DIR ${COMPONENT}${ABI_Name_Debug}.lib
				HINTS
				PATH_SUFFIXES
					lib/Debug
				PATHS
					${Castor3D_ROOT_DIR}
			)

			find_library( Castor3D_${COMPONENT}_LIBRARY_RELEASE
				NAMES
					${COMPONENT}${ABI_Name}.lib
				HINTS
				PATHS
					${Castor3D_${COMPONENT}_LIBRARY_RELEASE_DIR}
			)
			find_library( Castor3D_${COMPONENT}_LIBRARY_DEBUG
				NAMES
					${COMPONENT}${ABI_Name_Debug}.lib
				HINTS
				PATHS
					${Castor3D_${COMPONENT}_LIBRARY_DEBUG_DIR}
			)
		else()
			find_path(Castor3D_${COMPONENT}_LIBRARY_RELEASE_DIR lib${COMPONENT}${ABI_Name}.so
				HINTS
				PATH_SUFFIXES
					lib64
					lib
				PATHS
					${Castor3D_${COMPONENT}_ROOT_DIR}
			)
			find_path(Castor3D_${COMPONENT}_LIBRARY_DEBUG_DIR lib${COMPONENT}${ABI_Name_Debug}.so
				HINTS
				PATH_SUFFIXES
					lib64/Debug
					lib/Debug
				PATHS
					${Castor3D_ROOT_DIR}
			)

			find_library( Castor3D_${COMPONENT}_LIBRARY_RELEASE
				NAMES
					lib${COMPONENT}${ABI_Name}.so
				HINTS
				PATHS
					${Castor3D_${COMPONENT}_LIBRARY_RELEASE_DIR}
			)

			find_library(Castor3D_${COMPONENT}_LIBRARY_DEBUG
				NAMES
					lib${COMPONENT}${ABI_Name_Debug}.so
				HINTS
				PATHS
					${Castor3D_${COMPONENT}_LIBRARY_DEBUG_DIR}
			)
		endif()

		mark_as_advanced( Castor3D_${COMPONENT}_LIBRARY_RELEASE )
		find_package_handle_standard_args( Castor3D_${COMPONENT} DEFAULT_MSG Castor3D_${COMPONENT}_LIBRARY_RELEASE Castor3D_${COMPONENT}_INCLUDE_DIR )

		if ( Castor3D_${COMPONENT}_FOUND )
			if (MSVC)
				if ( Castor3D_${COMPONENT}_LIBRARY_DEBUG )
					set( Castor3D_${COMPONENT}_LIBRARIES optimized ${Castor3D_${COMPONENT}_LIBRARY_RELEASE} debug ${Castor3D_${COMPONENT}_LIBRARY_DEBUG} CACHE STRING "Castor3D ${COMPONENT} library" )
					set( Castor3D_${COMPONENT}_LIBRARY_DIRS ${Castor3D_${COMPONENT}_LIBRARY_RELEASE_DIR} ${Castor3D_${COMPONENT}_LIBRARY_DEBUG_DIR} )
				else ()
					set( Castor3D_${COMPONENT}_LIBRARIES ${Castor3D_${COMPONENT}_LIBRARY_RELEASE} CACHE STRING "Castor3D ${COMPONENT} library" )
					set( Castor3D_${COMPONENT}_LIBRARY_DIRS ${Castor3D_${COMPONENT}_LIBRARY_RELEASE_DIR})
				endif ()
			else ()
				if ( Castor3D_LIBRARY_DEBUG )
					set( Castor3D_${COMPONENT}_LIBRARIES optimized ${Castor3D_${COMPONENT}_LIBRARY_RELEASE} debug ${Castor3D_${COMPONENT}_LIBRARY_DEBUG} CACHE STRING "Castor3D ${COMPONENT} library" )
					set( Castor3D_${COMPONENT}_LIBRARY_DIRS ${Castor3D_${COMPONENT}_LIBRARY_RELEASE_DIR} ${Castor3D_${COMPONENT}_LIBRARY_DEBUG_DIR} )
				else ()
					set( Castor3D_${COMPONENT}_LIBRARIES ${Castor3D_${COMPONENT}_LIBRARY_RELEASE} CACHE STRING "Castor3D ${COMPONENT} library" )
					set( Castor3D_${COMPONENT}_LIBRARY_DIRS ${Castor3D_${COMPONENT}_LIBRARY_RELEASE_DIR})
				endif ()
			endif ()
			set( Castor3D_INCLUDE_DIRS
				${Castor3D_INCLUDE_DIRS}
				${Castor3D_${COMPONENT}_INCLUDE_DIR}
				CACHE STRING "Castor3D include directories" FORCE
			)
			set( Castor3D_LIBRARIES
				${Castor3D_LIBRARIES}
				${Castor3D_${COMPONENT}_LIBRARIES}
				CACHE STRING "Castor3D libraries" FORCE
			)
		endif ()

		if ( Castor3D_FOUND AND NOT Castor3D_${COMPONENT}_FOUND )
			set( Castor3D_FOUND FALSE )
		endif ()

		unset( Castor3D_${COMPONENT}_LIBRARY_RELEASE_DIR CACHE )
		unset( Castor3D_${COMPONENT}_LIBRARY_DEBUG_DIR CACHE )
		unset( Castor3D_${COMPONENT}_LIBRARY_DEBUG_DIR CACHE )
	endforeach ()
endif ()