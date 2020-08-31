include( Languages )
include( Logging )
include( CompilerVersion )
include( ComputeAbi )
include( PrecompiledHeaders )
include( FileUtils )

set( PROJECTS_VERSION "" )
set( PROJECTS_SOVERSION "" )
if( (NOT "${VERSION_MAJOR}" STREQUAL "") AND (NOT "${VERSION_MINOR}" STREQUAL "") AND (NOT "${VERSION_BUILD}" STREQUAL "") )
	set( PROJECTS_VERSION "${VERSION_MAJOR}.${VERSION_MINOR}" )
	set( PROJECTS_SOVERSION "${VERSION_MAJOR}" )
endif()
#--------------------------------------------------------------------------------------------------
#	Defining output paths for each project configuration
#--------------------------------------------------------------------------------------------------
if ( MSVC )
	option( PROJECTS_PROFILING "Activate code profiling or not" FALSE )
endif()

set( PROJECTS_PLATFORM "x86" )
if ( MSVC )
	if( (CMAKE_CL_64 OR CMAKE_GENERATOR MATCHES Win64) )
		set( PROJECTS_PLATFORM_FLAGS "/MACHINE:X64" )
		set( PROJECTS_PLATFORM "x64" )
	else()
		set( PROJECTS_PLATFORM_FLAGS "/MACHINE:X86" )
	endif()
elseif ( ANDROID )
	set( PROJECTS_PLATFORM ${ANDROID_ABI} )
else()
	if( (${CMAKE_SIZEOF_VOID_P} EQUAL 8) AND NOT MINGW )
		set( PROJECTS_PLATFORM_FLAGS "-m64" )
		if ( WIN32 )
			set( PROJECTS_PLATFORM "x64" )
		else ()
			set( PROJECTS_PLATFORM "amd64" )
		endif ()
	else()
		set( PROJECTS_PLATFORM_FLAGS "-m32" )
	endif()
endif()

get_filename_component( CMAKE_PARENT_DIR ${CMAKE_CURRENT_SOURCE_DIR} PATH )

set( PROJECTS_TEMPLATES_DIR ${CMAKE_CURRENT_SOURCE_DIR}/CMake/Templates )

if ( "${PROJECTS_OUTPUT_DIR}" STREQUAL "" )
	if ( "${CMAKE_SOURCE_DIR}" STREQUAL "${CMAKE_CURRENT_SOURCE_DIR}" )
		set( _PROJECTS_DIR ${CMAKE_SOURCE_DIR} )
	else ()
		get_filename_component( _PROJECTS_DIR ${CMAKE_SOURCE_DIR} PATH )
	endif ()
	set( PROJECTS_OUTPUT_DIR "${_PROJECTS_DIR}" CACHE PATH "The path to the output directory" )
	message( STATUS "PROJECTS_OUTPUT_DIR not defined, defaulting to ${PROJECTS_OUTPUT_DIR}" )
else ()
	set( PROJECTS_OUTPUT_DIR "${PROJECTS_OUTPUT_DIR}" CACHE PATH "The path to the output directory" )
endif ()

set( PROJECTS_BINARIES_OUTPUT_DIR "${PROJECTS_OUTPUT_DIR}/binaries/${PROJECTS_PLATFORM}" CACHE PATH "The path to the built binaries" FORCE )
set( PROJECTS_SETUP_OUTPUT_DIR "${PROJECTS_OUTPUT_DIR}/setup/${PROJECTS_PLATFORM}" CACHE PATH "The path to the built setup packages" FORCE )
set( PROJECTS_DOCUMENTATION_OUTPUT_DIR "${PROJECTS_OUTPUT_DIR}/doc" CACHE PATH "The path to the built documentation" FORCE )

set( PROJECTS_BINARIES_OUTPUT_DIR_RELWITHDEBINFO ${PROJECTS_BINARIES_OUTPUT_DIR}/RelWithDebInfo )
set( PROJECTS_BINARIES_OUTPUT_DIR_RELEASE ${PROJECTS_BINARIES_OUTPUT_DIR}/Release )
set( PROJECTS_BINARIES_OUTPUT_DIR_DEBUG ${PROJECTS_BINARIES_OUTPUT_DIR}/Debug )

set( CMAKE_ARCHIVE_OUTPUT_DIRECTORY_DEBUG "${PROJECTS_BINARIES_OUTPUT_DIR_DEBUG}/lib/" )
set( CMAKE_LIBRARY_OUTPUT_DIRECTORY_DEBUG "${PROJECTS_BINARIES_OUTPUT_DIR_DEBUG}/lib/" )
set( CMAKE_RUNTIME_OUTPUT_DIRECTORY_DEBUG "${PROJECTS_BINARIES_OUTPUT_DIR_DEBUG}/bin/" )
set( CMAKE_ARCHIVE_OUTPUT_DIRECTORY_RELEASE "${PROJECTS_BINARIES_OUTPUT_DIR_RELEASE}/lib/" )
set( CMAKE_LIBRARY_OUTPUT_DIRECTORY_RELEASE "${PROJECTS_BINARIES_OUTPUT_DIR_RELEASE}/lib/" )
set( CMAKE_RUNTIME_OUTPUT_DIRECTORY_RELEASE "${PROJECTS_BINARIES_OUTPUT_DIR_RELEASE}/bin/" )
set( CMAKE_ARCHIVE_OUTPUT_DIRECTORY_RELWITHDEBINFO "${PROJECTS_BINARIES_OUTPUT_DIR_RELWITHDEBINFO}/lib/" )
set( CMAKE_LIBRARY_OUTPUT_DIRECTORY_RELWITHDEBINFO "${PROJECTS_BINARIES_OUTPUT_DIR_RELWITHDEBINFO}/lib/" )
set( CMAKE_RUNTIME_OUTPUT_DIRECTORY_RELWITHDEBINFO "${PROJECTS_BINARIES_OUTPUT_DIR_RELWITHDEBINFO}/bin/" )

msg_debug( "PROJECTS_BINARIES_OUTPUT_DIR                  ${PROJECTS_BINARIES_OUTPUT_DIR}" )
msg_debug( "CMAKE_ARCHIVE_OUTPUT_DIRECTORY_DEBUG          ${CMAKE_ARCHIVE_OUTPUT_DIRECTORY_DEBUG}" )
msg_debug( "CMAKE_LIBRARY_OUTPUT_DIRECTORY_DEBUG          ${CMAKE_LIBRARY_OUTPUT_DIRECTORY_DEBUG}" )
msg_debug( "CMAKE_RUNTIME_OUTPUT_DIRECTORY_DEBUG          ${CMAKE_RUNTIME_OUTPUT_DIRECTORY_DEBUG}" )
msg_debug( "CMAKE_ARCHIVE_OUTPUT_DIRECTORY_RELEASE        ${CMAKE_ARCHIVE_OUTPUT_DIRECTORY_RELEASE}" )
msg_debug( "CMAKE_LIBRARY_OUTPUT_DIRECTORY_RELEASE        ${CMAKE_LIBRARY_OUTPUT_DIRECTORY_RELEASE}" )
msg_debug( "CMAKE_RUNTIME_OUTPUT_DIRECTORY_RELEASE        ${CMAKE_RUNTIME_OUTPUT_DIRECTORY_RELEASE}" )
msg_debug( "CMAKE_ARCHIVE_OUTPUT_DIRECTORY_RELWITHDEBINFO ${CMAKE_ARCHIVE_OUTPUT_DIRECTORY_RELWITHDEBINFO}" )
msg_debug( "CMAKE_LIBRARY_OUTPUT_DIRECTORY_RELWITHDEBINFO ${CMAKE_LIBRARY_OUTPUT_DIRECTORY_RELWITHDEBINFO}" )
msg_debug( "CMAKE_RUNTIME_OUTPUT_DIRECTORY_RELWITHDEBINFO ${CMAKE_RUNTIME_OUTPUT_DIRECTORY_RELWITHDEBINFO}" )

if (NOT WIN32 )
  #set( CMAKE_INSTALL_RPATH "$ORIGIN/:$ORIGIN/../lib" )
endif ()

macro( list_subdirs RESULT CURDIR )
	file( GLOB _CHILDREN RELATIVE ${CURDIR} ${CURDIR}/* )
	set( _SUBFOLDERS "" )

	foreach( _CHILD ${_CHILDREN} )
		if ( IS_DIRECTORY ${CURDIR}/${_CHILD} )
			list( APPEND _SUBFOLDERS ${_CHILD} )
		endif ()
	endforeach()
	set( ${RESULT} ${_SUBFOLDERS} )
endmacro()

macro( __target_install_headers TARGET_NAME SRCDIR DSTDIR )
	file(
		GLOB
			_HEADERS
			${SRCDIR}/*.h
			${SRCDIR}/*.hpp
			${SRCDIR}/*.inl
	)
	install(
		FILES ${_HEADERS}
		COMPONENT ${TARGET_NAME}_dev
		DESTINATION include/${DSTDIR}
	)
endmacro()

macro( target_install_subdir_headers TARGET_NAME SRCDIR SUBDIR CURDIR )
	__target_install_headers( ${TARGET_NAME}
		${SRCDIR}/${CURDIR}${SUBDIR}
		${TARGET_NAME}/${CURDIR}${SUBDIR}
	)
endmacro()

macro( target_install_dir_headers TARGET_NAME SRCDIR DSTDIR )
	file(
		GLOB
			_HEADERS
			${SRCDIR}/*.h
			${SRCDIR}/*.hpp
			${SRCDIR}/*.inl
			${SRCDIR}/*.h
			${SRCDIR}/*.hpp
			${SRCDIR}/*.inl
	)
	install(
		FILES ${_HEADERS}
		COMPONENT ${TARGET_NAME}_dev
		DESTINATION include/${DSTDIR}
	)
endmacro()

macro( target_install_headers TARGET_NAME HDR_FOLDER )
	target_install_dir_headers( ${TARGET_NAME} ${HDR_FOLDER} ${TARGET_NAME} )
	list_subdirs( _SUBDIRS ${HDR_FOLDER} )
	foreach( _SUBDIR ${_SUBDIRS} )
		target_install_subdir_headers( ${TARGET_NAME} ${HDR_FOLDER} ${_SUBDIR} "" )
		list_subdirs( _SUBSUBDIRS ${HDR_FOLDER}/${_SUBDIR} )
		foreach( _SUBSUBDIR ${_SUBSUBDIRS} )
			target_install_subdir_headers( ${TARGET_NAME} ${HDR_FOLDER} ${_SUBSUBDIR} "${_SUBDIR}/" )
			list_subdirs( _SUBSUBSUBDIRS ${HDR_FOLDER}/${_SUBDIR}/${_SUBSUBDIR} )
			foreach( _SUBSUBSUBDIR ${_SUBSUBSUBDIRS} )
				target_install_subdir_headers( ${TARGET_NAME} ${HDR_FOLDER} ${_SUBSUBSUBDIR} "${_SUBDIR}/${_SUBSUBDIR}/" )
			endforeach()
		endforeach()
	endforeach()
endmacro()

macro( find_rsc_file TARGET_NAME TARGET_TYPE )
	if ( WIN32 )
		string( COMPARE EQUAL ${TARGET_TYPE} "dll" IS_DLL )
		string( COMPARE EQUAL ${TARGET_TYPE} "api_dll" IS_API_DLL )
		string( COMPARE EQUAL ${TARGET_TYPE} "lib" IS_LIB )
		string( COMPARE EQUAL ${TARGET_TYPE} "bin" IS_BIN )
		string( COMPARE EQUAL ${TARGET_TYPE} "bin_dos" IS_BIN_DOS )
		string( COMPARE EQUAL ${TARGET_TYPE} "plugin" IS_PLUGIN )
		string( COMPARE EQUAL ${TARGET_TYPE} "api_plugin" IS_API_PLUGIN )
		if ( IS_DLL OR IS_API_DLL )
			set( RC_IN_FILE "SharedLibrary.rc.in" )
		elseif ( IS_BIN OR IS_BIN_DOS )
			set( RC_IN_FILE "Executable.rc.in" )
		elseif ( IS_PLUGIN OR IS_API_PLUGIN )
			set( RC_IN_FILE "Plugin.rc.in" )
		else ()
			set( IS_LIB TRUE )
			set( RC_IN_FILE "StaticLibrary.rc.in" )
		endif ()
		if ( NOT ${PROJECT_NAME}_WXWIDGET )
			set( ${PROJECT_NAME}_WXWIDGET 0 )
		endif ()
		#We include resource files in Visual Studio or MINGW with Windows
		enable_language( RC )
		if ( EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/Win32/${TARGET_NAME}.rc )
			set( ${TARGET_NAME}_RSC_FILES
				${CMAKE_CURRENT_SOURCE_DIR}/Win32/${TARGET_NAME}.rc
			)
		elseif ( EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/Win32/${TARGET_NAME}.rc.in )
			configure_file(
				${CMAKE_CURRENT_SOURCE_DIR}/Win32/${TARGET_NAME}.rc.in
				${CMAKE_CURRENT_BINARY_DIR}/Win32/${TARGET_NAME}.rc
				NEWLINE_STYLE LF
			)
			set( ${TARGET_NAME}_RSC_FILES
				${CMAKE_CURRENT_BINARY_DIR}/Win32/${TARGET_NAME}.rc
			)
		elseif ( EXISTS ${CMAKE_TEMPLATES_DIR}/${RC_IN_FILE} )
			configure_file(
				${CMAKE_TEMPLATES_DIR}/${RC_IN_FILE}
				${CMAKE_CURRENT_BINARY_DIR}/Win32/${TARGET_NAME}.rc
				NEWLINE_STYLE LF
			)
			set( ${TARGET_NAME}_RSC_FILES
				${CMAKE_CURRENT_BINARY_DIR}/Win32/${TARGET_NAME}.rc
			)
		endif ()
		if ( EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/Win32/resource.h" )
			set( ${TARGET_NAME}_RSC_FILES
				${${TARGET_NAME}_RSC_FILES}
				${CMAKE_CURRENT_SOURCE_DIR}/Win32/resource.h
			)
		elseif ( EXISTS "${CMAKE_CURRENT_BINARY_DIR}/Win32/resource.h" )
			set( ${TARGET_NAME}_RSC_FILES
				${${TARGET_NAME}_RSC_FILES}
				${CMAKE_CURRENT_BINARY_DIR}/Win32/resource.h
			)
		elseif ( EXISTS "${CMAKE_TEMPLATES_DIR}/resource.h.in" )
			configure_file(
				${CMAKE_TEMPLATES_DIR}/resource.h.in
				${CMAKE_CURRENT_BINARY_DIR}/Win32/resource.h
				NEWLINE_STYLE LF
			)
			set( ${TARGET_NAME}_RSC_FILES
				${${TARGET_NAME}_RSC_FILES}
				${CMAKE_CURRENT_BINARY_DIR}/Win32/resource.h
			)
		endif ()
		if ( EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/Win32/${TARGET_NAME}.rc" )
			set( ${TARGET_NAME}_RSC_FILES
				${${TARGET_NAME}_RSC_FILES}
				${CMAKE_CURRENT_SOURCE_DIR}/Win32/${TARGET_NAME}.rc
			)
		endif()
		if ( EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/Win32/${TARGET_NAME}.rc2" )
			set( ${TARGET_NAME}_RSC_FILES
				${${TARGET_NAME}_RSC_FILES}
				${CMAKE_CURRENT_SOURCE_DIR}/Win32/${TARGET_NAME}.rc2
			)
		endif()
		if ( EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/Win32/ )
			include_directories( Win32 )
		endif ()
		set( ${TARGET_NAME}_HDR_FILES
			${${TARGET_NAME}_HDR_FILES}
			${${TARGET_NAME}_RSC_FILES}
		)
		source_group( "Resource Files" FILES ${${TARGET_NAME}_RSC_FILES} )
	endif ( WIN32 )
endmacro()

macro( install_target TARGET_NAME TARGET_TYPE HDR_FOLDER )
	string( COMPARE EQUAL ${TARGET_TYPE} "dll" IS_DLL )
	string( COMPARE EQUAL ${TARGET_TYPE} "api_dll" IS_API_DLL )
	string( COMPARE EQUAL ${TARGET_TYPE} "lib" IS_LIB )
	string( COMPARE EQUAL ${TARGET_TYPE} "bin" IS_BIN )
	string( COMPARE EQUAL ${TARGET_TYPE} "bin_dos" IS_BIN_DOS )
	string( COMPARE EQUAL ${TARGET_TYPE} "plugin" IS_PLUGIN )
	string( COMPARE EQUAL ${TARGET_TYPE} "api_plugin" IS_API_PLUGIN )
	set( IS_SHARED OFF )
	if ( IS_DLL OR IS_API_DLL OR IS_PLUGIN OR IS_API_PLUGIN )
		set( IS_SHARED ON )
	endif ()
	set( IS_API OFF )
	if ( IS_API_DLL OR IS_API_PLUGIN )
		set( IS_API ON )
	endif ()
	set( IS_BINARY OFF )
	if ( IS_BIN OR IS_BIN_DOS )
		set( IS_BINARY ON )
	endif ()
	set( BIN_FOLDER bin )
	set( SUB_FOLDER "" )

	if ( NOT IS_LIB )
		if ( IS_PLUGIN OR IS_API_PLUGIN )
			if ( NOT "${MAIN_PROJECT_NAME}" STREQUAL "" )
				set( SUB_FOLDER "/${MAIN_PROJECT_NAME}" )
			endif ()
			set( BIN_FOLDER lib )
		endif ()
	endif ()
	if ( IS_SHARED )
		#We now build the install script
		if ( WIN32 )
			#We install each .dll in <install_dir>/bin folder
			install(
				TARGETS ${TARGET_NAME}
				COMPONENT ${TARGET_NAME}
				CONFIGURATIONS Release
				RUNTIME DESTINATION ${BIN_FOLDER}${SUB_FOLDER}
				ARCHIVE DESTINATION lib${SUB_FOLDER}
				LIBRARY DESTINATION lib${SUB_FOLDER}
			)
			install(
				TARGETS ${TARGET_NAME}
				COMPONENT ${TARGET_NAME}
				CONFIGURATIONS RelWithDebInfo
				RUNTIME DESTINATION ${BIN_FOLDER}/RelWithDebInfo${SUB_FOLDER}
				ARCHIVE DESTINATION lib/RelWithDebInfo${SUB_FOLDER}
				LIBRARY DESTINATION lib/RelWithDebInfo${SUB_FOLDER}
			)
			install(
				TARGETS ${TARGET_NAME}
				COMPONENT ${TARGET_NAME}
				CONFIGURATIONS Debug
				RUNTIME DESTINATION ${BIN_FOLDER}/Debug${SUB_FOLDER}
				ARCHIVE DESTINATION lib/Debug${SUB_FOLDER}
				LIBRARY DESTINATION lib/Debug${SUB_FOLDER}
			)
		else ()
			#We install each .so in <install_dir>/lib folder
			install(
				TARGETS ${TARGET_NAME}
				COMPONENT ${TARGET_NAME}
				CONFIGURATIONS Release
				LIBRARY DESTINATION lib/${SUB_FOLDER}
			)
			install(
				TARGETS ${TARGET_NAME}
				COMPONENT ${TARGET_NAME}
				CONFIGURATIONS RelWithDebInfo
				LIBRARY DESTINATION lib/RelWithDebInfo${SUB_FOLDER}
			)
			install(
				TARGETS ${TARGET_NAME}
				COMPONENT ${TARGET_NAME}
				CONFIGURATIONS Debug
				LIBRARY DESTINATION lib/Debug${SUB_FOLDER}
			)
		endif()
		if ( IS_API )
			#For API DLLs, we install headers to <install_dir>/include/${TARGET_NAME}
			target_install_headers( ${TARGET_NAME} ${HDR_FOLDER} )
			if ( IS_API_PLUGIN AND WIN32 )
				add_custom_command(
					TARGET ${TARGET_NAME}
					POST_BUILD
					COMMAND ${CMAKE_COMMAND} -E copy_if_different ${PROJECTS_BINARIES_OUTPUT_DIR}/$<CONFIGURATION>/${BIN_FOLDER}${SUB_FOLDER}/${TARGET_NAME}$<$<CONFIG:Debug>:d>.dll ${PROJECTS_BINARIES_OUTPUT_DIR}/$<CONFIGURATION>/bin
					VERBATIM
				)
				install(
					FILES ${CMAKE_RUNTIME_OUTPUT_DIRECTORY_DEBUG}${TARGET_NAME}d.dll
					COMPONENT ${TARGET_NAME}
					CONFIGURATIONS Debug
					DESTINATION bin/Debug
				)
				install(
					FILES ${CMAKE_RUNTIME_OUTPUT_DIRECTORY_RELEASE}${TARGET_NAME}.dll
					COMPONENT ${TARGET_NAME}
					CONFIGURATIONS RelWithDebInfo
					DESTINATION bin/RelWithDebInfo
				)
				install(
					FILES ${CMAKE_RUNTIME_OUTPUT_DIRECTORY_RELEASE}${TARGET_NAME}.dll
					COMPONENT ${TARGET_NAME}
					CONFIGURATIONS Release
					DESTINATION bin
				)
			endif ()
		endif ()
	elseif ( IS_BINARY )
		#We now build the install script
		#We copy each exe in <install_dir>/bin folder
		install(
			TARGETS ${TARGET_NAME}
			COMPONENT ${TARGET_NAME}
			CONFIGURATIONS Release
			RUNTIME DESTINATION bin
		)
		install(
			TARGETS ${TARGET_NAME}
			COMPONENT ${TARGET_NAME}
			CONFIGURATIONS RelWithDebInfo
			RUNTIME DESTINATION bin/RelWithDebInfo
		)
		install(
			TARGETS ${TARGET_NAME}
			COMPONENT ${TARGET_NAME}
			CONFIGURATIONS Debug
			RUNTIME DESTINATION bin/Debug
		)
	elseif ( IS_LIB )
		#We now build the install script
		#We copy each lib in <install_dir>/lib folder
		install(
			TARGETS ${TARGET_NAME}
			COMPONENT ${TARGET_NAME}_dev
			CONFIGURATIONS Release
			ARCHIVE DESTINATION lib
		)
		install(
			TARGETS ${TARGET_NAME}
			COMPONENT ${TARGET_NAME}_dev
			CONFIGURATIONS RelWithDebInfo
			ARCHIVE DESTINATION lib/RelWithDebInfo
		)
		install(
			TARGETS ${TARGET_NAME}
			COMPONENT ${TARGET_NAME}_dev
			CONFIGURATIONS Debug
			ARCHIVE DESTINATION lib/Debug
		)
		#For libs, we install headers to <install_dir>/include/${TARGET_NAME}
		target_install_headers( ${TARGET_NAME} ${HDR_FOLDER} )
	endif()
endmacro()

#--------------------------------------------------------------------------------------------------
#\function
#	add_target
#\brief
#	Main function, used to create a target of given type, with it's dependencies and libraries
#\param[in] TARGET_NAME
#	The target name.
#\param[in] TARGET_TYPE
#	Can be one of the following:
#		dll: A dll will be installed in <install_dir>/bin.
#		api_dll: Like a dll, an API dll will additionally have its includes installed in <install_dir>/include/<TARGET_NAME>.
#		lib: A lib will be installed in <install_dir>/lib.
#		bin: A binary will be installed in <install_dir>/bin.
#		bin_dos: A dos binary will be installed in <install_dir>/bin and will have a console.
#		plugin: A plugin will be installed in <install_dir>/lib/<project_name>.
#		api_plugin: Like a plugin, API plugin will additionally have its includes installed in <install_dir>/include/<TARGET_NAME>.
#\param[in] TARGET_DEPENDENCIES
#	String containing the target dependencies (not libraries), separated by ';'.
#\param[in] TARGET_LINKED_LIBRARIES
#	String containing the target linked libraries, separated by '|': NOT ';'.
#	Note that for MSVC build the form "optimized;ReleaseLib.lib;debug;DebugLib.lib" must remain untouched.
#	In fact, that '|' separator is used to make sure they are different libraries, and not the MSVC form.
#\param[in,opt] PCH_HEADER
#	The precompiled headers header file.
#\param[in,opt] PCH_SOURCE
#	The precompiled headers source file.
#\param[in,opt] OPT_C_FLAGS
#	Optional C compile flags.
#\param[in,opt] OPT_CXX_FLAGS
#	String containing the optional CXX compile flags.
#\param[in,opt] OPT_LINK_FLAGS
#	String containing the optional link flags.
#\param[in,opt] OPT_FILES
#	String containing the optional files to add to the target.
#--------------------------------------------------------------------------------------------------
function( add_target_min TARGET_NAME TARGET_TYPE )# ARGV2=PCH_HEADER ARGV3=PCH_SOURCE
	set( PCH_HEADER "${ARGV2}" )
	set( PCH_SOURCE "${ARGV3}" )
	if ( ( NOT "${CMAKE_BUILD_TYPE}" STREQUAL "" ) OR MSVC )
		#First we retrieve the kind of target we will build
		string( COMPARE EQUAL ${TARGET_TYPE} "dll" IS_DLL )
		string( COMPARE EQUAL ${TARGET_TYPE} "api_dll" IS_API_DLL )
		string( COMPARE EQUAL ${TARGET_TYPE} "lib" IS_LIB )
		string( COMPARE EQUAL ${TARGET_TYPE} "bin" IS_BIN )
		string( COMPARE EQUAL ${TARGET_TYPE} "bin_dos" IS_BIN_DOS )
		string( COMPARE EQUAL ${TARGET_TYPE} "plugin" IS_PLUGIN )
		string( COMPARE EQUAL ${TARGET_TYPE} "api_plugin" IS_API_PLUGIN )
		set( IS_SHARED OFF )
		if ( IS_DLL OR IS_API_DLL OR IS_PLUGIN OR IS_API_PLUGIN )
			set( IS_SHARED ON )
		endif ()
		set( IS_API OFF )
		if ( IS_API_DLL OR IS_API_PLUGIN )
			set( IS_API ON )
		endif ()
		set( IS_BINARY OFF )
		if ( IS_BIN OR IS_BIN_DOS )
			set( IS_BINARY ON )
		endif ()
		msg_debug( "----------------------------------------------------------------------------------------------------" )
		msg_debug( "Target    ${TARGET_NAME}" )
		msg_debug( "Type      ${TARGET_TYPE}" )
		msg_debug( "PCH_HEADER                [${PCH_HEADER}]" )
		msg_debug( "PCH_SOURCE                [${PCH_SOURCE}]" )
		msg_debug( "IS_DLL                    [${IS_DLL}]" )
		msg_debug( "IS_API_DLL                [${IS_API_DLL}]" )
		msg_debug( "IS_LIB                    [${IS_LIB}]" )
		msg_debug( "IS_BIN                    [${IS_BIN}]" )
		msg_debug( "IS_BIN_DOS                [${IS_BIN_DOS}]" )
		msg_debug( "IS_PLUGIN                 [${IS_PLUGIN}]" )
		msg_debug( "IS_API_PLUGIN             [${IS_API_PLUGIN}]" )
		msg_debug( "IS_SHARED                 [${IS_SHARED}]" )
		msg_debug( "IS_API                    [${IS_API}]" )
		msg_debug( "IS_BINARY                 [${IS_BINARY}]" )
		set( BIN_FOLDER bin )
		set( SUB_FOLDER "" )
		if ( IS_LIB )
			#We compute the extended name of the target (libs only)
			compute_abi_name( TARGET_ABI_NAME TARGET_ABI_NAME_DEBUG )
			msg_debug( "TARGET_ABI_NAME           ${TARGET_ABI_NAME}" )
			msg_debug( "TARGET_ABI_NAME_DEBUG     ${TARGET_ABI_NAME_DEBUG}" )
		else ()
			set( TARGET_ABI_NAME "" )
			set( TARGET_ABI_NAME_DEBUG "d" )
			if ( IS_PLUGIN OR IS_API_PLUGIN )
				if ( NOT "${MAIN_PROJECT_NAME}" STREQUAL "" )
					set( SUB_FOLDER "/${MAIN_PROJECT_NAME}" )
				endif ()
				set( BIN_FOLDER lib )
			endif ()
		endif ()
		set( CMAKE_DEBUG_POSTFIX "${TARGET_ABI_NAME}${TARGET_ABI_NAME_DEBUG}" CACHE STRING "" FORCE )
		set( CMAKE_RELEASE_POSTFIX "${TARGET_ABI_NAME}" CACHE STRING "" FORCE )
		set( CMAKE_RELWITHDEBINFO_POSTFIX "${TARGET_ABI_NAME}" CACHE STRING "" FORCE )
		if ( NOT ${PROJECT_NAME}_WXWIDGET )
			set( ${PROJECT_NAME}_WXWIDGET 0 )
		endif ()

		set( TARGET_COMPILE_DEFINITIONS "" )
		set( TARGET_COMPILE_FLAGS "" )
		add_target_compilation_common_flags( ${TARGET_NAME} ${TARGET_TYPE} TARGET_COMPILE_DEFINITIONS TARGET_COMPILE_FLAGS TARGET_LINK_FLAGS )

		if ( NOT "x86" STREQUAL ${PROJECTS_PLATFORM} )
			#Additional definition, for X64 builds
			set( TARGET_COMPILE_DEFINITIONS ${TARGET_COMPILE_DEFINITIONS} _X64 )
		endif ()

		set( CMAKE_ARCHIVE_OUTPUT_DIRECTORY_DEBUG "${PROJECTS_BINARIES_OUTPUT_DIR_DEBUG}/lib${SUB_FOLDER}/" )
		set( CMAKE_LIBRARY_OUTPUT_DIRECTORY_DEBUG "${PROJECTS_BINARIES_OUTPUT_DIR_DEBUG}/lib${SUB_FOLDER}/" )
		set( CMAKE_RUNTIME_OUTPUT_DIRECTORY_DEBUG "${PROJECTS_BINARIES_OUTPUT_DIR_DEBUG}/${BIN_FOLDER}${SUB_FOLDER}/" )
		set( CMAKE_ARCHIVE_OUTPUT_DIRECTORY_RELEASE "${PROJECTS_BINARIES_OUTPUT_DIR_RELEASE}/lib${SUB_FOLDER}/" )
		set( CMAKE_LIBRARY_OUTPUT_DIRECTORY_RELEASE "${PROJECTS_BINARIES_OUTPUT_DIR_RELEASE}/lib${SUB_FOLDER}/" )
		set( CMAKE_RUNTIME_OUTPUT_DIRECTORY_RELEASE "${PROJECTS_BINARIES_OUTPUT_DIR_RELEASE}/${BIN_FOLDER}${SUB_FOLDER}/" )
		set( CMAKE_ARCHIVE_OUTPUT_DIRECTORY_RELWITHDEBINFO "${PROJECTS_BINARIES_OUTPUT_DIR_RELWITHDEBINFO}/lib${SUB_FOLDER}/" )
		set( CMAKE_LIBRARY_OUTPUT_DIRECTORY_RELWITHDEBINFO "${PROJECTS_BINARIES_OUTPUT_DIR_RELWITHDEBINFO}/lib${SUB_FOLDER}/" )
		set( CMAKE_RUNTIME_OUTPUT_DIRECTORY_RELWITHDEBINFO "${PROJECTS_BINARIES_OUTPUT_DIR_RELWITHDEBINFO}/${BIN_FOLDER}${SUB_FOLDER}/" )

		#We now effectively create the target
		if ( IS_SHARED )
			add_library( ${TARGET_NAME}
				SHARED
					${${TARGET_NAME}_SRC_FILES}
					${${PROJECT_NAME}_FOLDER_SRC_C_FILES}
					${${TARGET_NAME}_HDR_FILES}
					${${TARGET_NAME}_NVS_FILES}
			)
			set_target_properties( ${TARGET_NAME}
				PROPERTIES
					VERSION ${PROJECTS_VERSION}
					SOVERSION ${PROJECTS_SOVERSION}
					CXX_STANDARD 17
			)
		elseif ( IS_BINARY )
			if ( WIN32 AND NOT IS_BIN_DOS )
				add_executable( ${TARGET_NAME}
					WIN32
						${${TARGET_NAME}_SRC_FILES}
						${${PROJECT_NAME}_FOLDER_SRC_C_FILES}
						${${TARGET_NAME}_HDR_FILES}
						${${TARGET_NAME}_NVS_FILES}
				)
			else ()
				add_executable( ${TARGET_NAME}
					${${TARGET_NAME}_SRC_FILES}
					${${PROJECT_NAME}_FOLDER_SRC_C_FILES}
					${${TARGET_NAME}_HDR_FILES}
					${${TARGET_NAME}_NVS_FILES}
			)
			endif ()
			set_target_properties( ${TARGET_NAME}
				PROPERTIES
					VS_DEBUGGER_WORKING_DIRECTORY "$(OutDir)"
					CXX_STANDARD 17
			)
		elseif ( IS_LIB )
			add_library( ${TARGET_NAME}
				STATIC
					${${TARGET_NAME}_SRC_FILES}
					${${PROJECT_NAME}_FOLDER_SRC_C_FILES}
					${${TARGET_NAME}_HDR_FILES}
					${${TARGET_NAME}_NVS_FILES}
			)
			set( TARGET_COMPILE_DEFINITIONS
				${TARGET_COMPILE_DEFINITIONS}
				${TARGET_NAME}_STATIC
			)
			set_target_properties( ${TARGET_NAME}
				PROPERTIES
					CXX_STANDARD 17
			)
		else()
			message( FATAL_ERROR " Unknown target type : [${TARGET_TYPE}]" )
		endif ()
		if ( MSVC )
			if ( ${PROJECTS_PROFILING} )
				set_target_properties( ${TARGET_NAME}
					PROPERTIES
						LINK_FLAGS_DEBUG "/OPT:NOREF /PROFILE" )
			endif ()
		endif ()

		if ( PCH_HEADER STREQUAL "" OR NOT ${PROJECTS_USE_PRECOMPILED_HEADERS} )
			msg_debug( "PRECOMPILED HEADERS       No" )
		else ()
			msg_debug( "PRECOMPILED HEADERS       Yes" )
			target_add_precompiled_header( ${TARGET_NAME}
				${PCH_HEADER}
				${PCH_SOURCE}
			)
		endif ()
		target_compile_definitions( ${TARGET_NAME}
			PRIVATE
				${TARGET_NAME}_VERSION_MAJOR=${${TARGET_NAME}_VERSION_MAJOR}
				${TARGET_NAME}_VERSION_MINOR=${${TARGET_NAME}_VERSION_MINOR}
				${TARGET_NAME}_VERSION_BUILD=${${TARGET_NAME}_VERSION_BUILD}
				${TARGET_COMPILE_DEFINITIONS}
				${PROJECTS_COMPILE_DEFINITIONS}
		)
		target_compile_options( ${TARGET_NAME}
			PUBLIC
				${TARGET_COMPILE_FLAGS}
				${PROJECTS_COMPILE_OPTIONS}
		)
		msg_debug( "TARGET_COMPILE_FLAGS:        ${TARGET_COMPILE_FLAGS}" )
		msg_debug( "TARGET_COMPILE_DEFINITIONS:  ${TARGET_COMPILE_DEFINITIONS}" )
	endif ()
endfunction()

function( add_target TARGET_NAME TARGET_TYPE HDR_FOLDER SRC_FOLDER TARGET_DEPENDENCIES TARGET_LINKED_LIBRARIES )# ARGV6=PCH_HEADER ARGV7=PCH_SOURCE ARGV8=OPT_C_FLAGS ARGV9=OPT_CXX_FLAGS ARGV10=OPT_LINK_FLAGS ARGV11=OPT_FILES
	set( PCH_HEADER "${ARGV6}" )
	set( PCH_SOURCE "${ARGV7}" )
	set( OPT_C_FLAGS "${ARGV8}" )
	set( OPT_CXX_FLAGS "${ARGV9}" )
	set( OPT_LINK_FLAGS "${ARGV10}" )
	set( OPT_FILES "${ARGV11}" )
	#We then retrieve target files (located in include/${TARGET_NAME}, source/${TARGET_NAME} and resource/${TARGET_NAME}
	file(
		GLOB_RECURSE
			TARGET_SOURCE_CPP
		CONFIGURE_DEPENDS
			${SRC_FOLDER}/*.cpp
	)
	msg_debug( "TARGET_SOURCE_CPP         ${TARGET_SOURCE_CPP}" )
	file(
		GLOB_RECURSE
			TARGET_SOURCE_C
		CONFIGURE_DEPENDS
			${SRC_FOLDER}/*.c
	)
	msg_debug( "TARGET_SOURCE_C           ${TARGET_SOURCE_C}" )
	file(
		GLOB_RECURSE
			TARGET_SOURCE_H_ONLY
		CONFIGURE_DEPENDS
			${HDR_FOLDER}/*.h
			${HDR_FOLDER}/*.hpp
			${HDR_FOLDER}/*.inl
	)
	msg_debug( "TARGET_SOURCE_H_ONLY      ${TARGET_SOURCE_H_ONLY}" )
	msg_debug( "SRC_FOLDER                [${SRC_FOLDER}]" )
	msg_debug( "HDR_FOLDER                [${HDR_FOLDER}]" )

	if ( APPLE )
		# We add Obj-C and Obj-C++ files to the project
		file(
			GLOB_RECURSE
				TARGET_SOURCE_OBJ_CPP
			CONFIGURE_DEPENDS
				${SRC_FOLDER}/*.mm
		)
		file(
			GLOB_RECURSE
				TARGET_SOURCE_OBJ_C
			CONFIGURE_DEPENDS
				${SRC_FOLDER}/*.m
		)
		set( TARGET_SOURCE_C
			${TARGET_SOURCE_C}
			${TARGET_SOURCE_OBJ_C}
		)
		set( TARGET_SOURCE_CPP
			${TARGET_SOURCE_CPP}
			${TARGET_SOURCE_OBJ_CPP}
		)
		set( ${TARGET_NAME}_HDR_FILES
			${TARGET_SOURCE_H_ONLY}
		)
	elseif ( WIN32 )
		find_rsc_file( ${TARGET_NAME} ${TARGET_TYPE} )
		if ( MSVC )
			file(
				GLOB_RECURSE
					${PROJECT_NAME}_NVS_FILES
				CONFIGURE_DEPENDS
					${HDR_FOLDER}/*.natvis
					${SRC_FOLDER}/*.natvis
					*.natvis
			)
			set( ${TARGET_NAME}_HDR_FILES
				${${TARGET_NAME}_HDR_FILES}
				${${PROJECT_NAME}_NVS_FILES}
			)
			source_group( "Natvis Files" FILES ${${PROJECT_NAME}_NVS_FILES} )
		endif ()
	else ( WIN32 )
		set( ${TARGET_NAME}_HDR_FILES
			${TARGET_SOURCE_H_ONLY}
		)
	endif ( APPLE )

	set( ${TARGET_NAME}_SRC_FILES
		${${TARGET_NAME}_SRC_FILES}
		${TARGET_SOURCE_CPP}
	)
	set( ${TARGET_NAME}_SRC_C_FILES
		${${TARGET_NAME}_SRC_C_FILES}
		${TARGET_SOURCE_C}
	)
	set( ${TARGET_NAME}_HDR_FILES
		${${TARGET_NAME}_HDR_FILES}
		${TARGET_SOURCE_H_ONLY}
	)

	add_target_min( ${TARGET_NAME} ${TARGET_TYPE} "${PCH_HEADER}" "${PCH_SOURCE}" )

	#We scan dependencies to add it to the target
	foreach( TARGET_DEPENDENCY ${TARGET_DEPENDENCIES} )
		msg_debug( "TARGET_DEPENDENCY         ${TARGET_DEPENDENCY}")
		add_dependencies( ${TARGET_NAME} ${TARGET_DEPENDENCY} )
	endforeach()

	#We scan libraries to add it to the linker
	foreach( TARGET_LIB ${TARGET_LINKED_LIBRARIES} )
		string( REPLACE "|" ";" TARGET_LIB ${TARGET_LIB})
		msg_debug( "TARGET_LIB                ${TARGET_LIB}" )
		target_link_libraries( ${TARGET_NAME} PUBLIC ${TARGET_LIB} )
	endforeach()

	install_target( ${TARGET_NAME} ${TARGET_TYPE} ${HDR_FOLDER} )
endfunction( add_target )
