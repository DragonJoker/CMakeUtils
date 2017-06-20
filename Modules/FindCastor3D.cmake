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

function( _copy_and_install_dll _TARGET_NAME _TARGET_DIR_RELEASE _TARGET_DIR_RELWITHDEBINFO _TARGET_DIR_DEBUG _DLL_PATH_RELEASE _DLL_PATH_DEBUG _DESTINATION )
	get_filename_component( _FILE ${_DLL_PATH_RELEASE} NAME_WE )
	get_filename_component( _LIB_NAME_RELEASE ${_DLL_PATH_RELEASE} NAME )
	get_filename_component( _LIB_NAME_DEBUG ${_DLL_PATH_DEBUG} NAME )
	add_custom_command(
		TARGET ${_TARGET_NAME}
		POST_BUILD
		COMMAND ${CMAKE_COMMAND} -E copy_if_different
			$<$<CONFIG:Debug>:${_DLL_PATH_DEBUG}>
			$<$<CONFIG:Debug>:${_TARGET_DIR_DEBUG}/${_DESTINATION}/${_LIB_NAME_DEBUG}>
			$<$<CONFIG:Release>:${_DLL_PATH_RELEASE}>
			$<$<CONFIG:Release>:${_TARGET_DIR_RELEASE}/${_DESTINATION}/${_LIB_NAME_RELEASE}>
			$<$<CONFIG:RelWithDebInfo>:${_DLL_PATH_RELEASE}>
			$<$<CONFIG:RelWithDebInfo>:${_TARGET_DIR_RELWITHDEBINFO}/${_DESTINATION}/${_LIB_NAME_RELEASE}>
		COMMENT "Copying ${_FILE} into binary folder"
	)
	install(
		FILES ${_DLL_PATH_RELEASE}
		DESTINATION ${_DESTINATION}
		COMPONENT ${_TARGET_NAME}
		CONFIGURATIONS Release RelWithDebInfo
	)
	install(
		FILES ${_DLL_PATH_DEBUG}
		DESTINATION ${_DESTINATION}
		COMPONENT ${_TARGET_NAME}
		CONFIGURATIONS Debug
	)
endfunction()

function( _find_debug_dll _DEBUG_DLL _RELEASE_DLL _DEBUG_PATH )
	unset( ${_DEBUG_DLL} PARENT_SCOPE )
	get_filename_component( _FILE ${_RELEASE_DLL} NAME_WE )
	set( _FILE ${_FILE}d.dll )
	find_file(
		_FOUND
		NAMES ${_FILE}
		PATHS ${_DEBUG_PATH}
		NO_DEFAULT_PATH
	)
	if ( _FOUND )
		set( ${_DEBUG_DLL} ${_FOUND} PARENT_SCOPE )
	else ()
		set( ${_DEBUG_DLL} ${_RELEASE_DLL} PARENT_SCOPE )
	endif ()
	unset( _FOUND CACHE )
endfunction()

function( _copy_dlls _TARGET_NAME _TARGET_DIR_RELEASE _TARGET_DIR_RELWITHDEBINFO _TARGET_DIR_DEBUG _SOURCE_DIR_RELEASE _SOURCE_DIR_DEBUG _DESTINATION )
	file( GLOB FILES_TO_COPY ${_SOURCE_DIR_RELEASE}/*.dll )
	foreach ( TO_COPY ${FILES_TO_COPY} )
		_find_debug_dll( TO_COPY_DEBUG ${TO_COPY} ${_SOURCE_DIR_DEBUG} )
		_copy_and_install_dll(
			${_TARGET_NAME}
			${_TARGET_DIR_RELEASE}
			${_TARGET_DIR_RELWITHDEBINFO}
			${_TARGET_DIR_DEBUG}
			${TO_COPY}
			${TO_COPY_DEBUG}
			${_DESTINATION} )
	endforeach ()
endfunction()

function( _copy_target_files _TARGET _DESTINATION )# ARGN: The files
	if ( NOT "${_DESTINATION}" STREQUAL "" )
		set( _DESTINATION ${_DESTINATION}/ )
	endif ()
	foreach ( _FILE ${ARGN} )
		get_filename_component( _FILE ${_FILE} REALPATH )
		get_filename_component( _FILE_NAME ${_FILE} NAME )
		add_custom_command(
			TARGET ${_TARGET}
			POST_BUILD
			COMMAND ${CMAKE_COMMAND} -E make_directory ${PROJECTS_BINARIES_OUTPUT_DIR}/$<CONFIGURATION>/share/Castor3D/${_DESTINATION}
			COMMAND ${CMAKE_COMMAND} -E copy_if_different ${_FILE} ${PROJECTS_BINARIES_OUTPUT_DIR}/$<CONFIGURATION>/share/Castor3D/${_DESTINATION}${_FILE_NAME}
		)
	endforeach ()
	install(
		FILES ${ARGN}
		DESTINATION share/${_TARGET}
		COMPONENT ${_TARGET}
	)
endfunction()

function( castor3d_copy_files _TARGET_NAME _TARGET_DIR_RELEASE _TARGET_DIR_RELWITHDEBINFO _TARGET_DIR_DEBUG )
	if ( WIN32 AND Castor3D_FOUND )
		set( Castor3D_BIN_DIR_RELEASE "${Castor3D_ROOT_DIR}/bin" )
		set( Castor3D_BIN_DIR_DEBUG "${Castor3D_ROOT_DIR}/bin/Debug" )
		set( Castor3D_LIB_DIR_RELEASE "${Castor3D_ROOT_DIR}/lib/Castor3D" )
		set( Castor3D_LIB_DIR_DEBUG "${Castor3D_ROOT_DIR}/lib/Debug/Castor3D" )

		include( InstallRequiredSystemLibraries )
		_copy_dlls( ${_TARGET_NAME}
			${_TARGET_DIR_RELEASE}
			${_TARGET_DIR_RELWITHDEBINFO}
			${_TARGET_DIR_DEBUG}
			${Castor3D_BIN_DIR_RELEASE}
			${Castor3D_BIN_DIR_DEBUG}
			bin )
		_copy_dlls( ${_TARGET_NAME}
			${_TARGET_DIR_RELEASE}
			${_TARGET_DIR_RELWITHDEBINFO}
			${_TARGET_DIR_DEBUG}
			${Castor3D_LIB_DIR_RELEASE}
			${Castor3D_LIB_DIR_DEBUG}
			lib/Castor3D )
	endif ()
	set( Castor3D_SHARE_DIR "${Castor3D_ROOT_DIR}/share/Castor3D" )
	file(
		GLOB
			CoreZipFiles
			${Castor3D_SHARE_DIR}/*.zip
	)
	_copy_target_files( ${_TARGET_NAME} "" ${CoreZipFiles} )
endfunction()