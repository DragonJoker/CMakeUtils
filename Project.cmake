include( Languages )
include( Logging )
include( CompilerVersion )
include( ComputeAbi )
include( FileUtils )

if( MSVC )
	find_package( VLD )
endif()
if( VLD_FOUND )
	message( STATUS "+ Found Visual Leak Detector" )
	option( PROJECTS_USE_VLD "Use Visual Leaks Detector" TRUE )
	if ( PROJECTS_USE_VLD )
		include_directories( ${VLD_INCLUDE_DIR} )
		link_directories( ${VLD_LIBRARY_DIR} )
		add_definitions( -DVLD_AVAILABLE )
		msg_debug( "Using Visual Leak Detector to check for Memory leaks" )
	endif()
else ()
	set( PROJECTS_USE_VLD FALSE )
endif ()

set( PROJECTS_VERSION "" )
set( PROJECTS_SOVERSION "" )
if( (NOT "${VERSION_MAJOR}" STREQUAL "") AND (NOT "${VERSION_MINOR}" STREQUAL "") AND (NOT "${VERSION_BUILD}" STREQUAL "") )
	set( PROJECTS_VERSION "${VERSION_MAJOR}.${VERSION_MINOR}" )
	set( PROJECTS_SOVERSION "${VERSION_BUILD}" )
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
	get_filename_component( _PROJECTS_DIR ${CMAKE_SOURCE_DIR} PATH )
	set( PROJECTS_OUTPUT_DIR "${_PROJECTS_DIR}" CACHE PATH "The path to the output directory" )
	message( STATUS "PROJECTS_OUTPUT_DIR not defined, defaulting to ${PROJECTS_OUTPUT_DIR}" )
else ()
	set( PROJECTS_OUTPUT_DIR "${PROJECTS_OUTPUT_DIR}" CACHE PATH "The path to the output directory" )
endif ()

set( PROJECTS_BINARIES_OUTPUT_DIR "${PROJECTS_OUTPUT_DIR}/binaries/${PROJECTS_PLATFORM}" CACHE PATH "The path to the built binaries" FORCE )
set( PROJECTS_SETUP_OUTPUT_DIR "${PROJECTS_OUTPUT_DIR}/setup/${PROJECTS_PLATFORM}" CACHE PATH "The path to the built setup packages" FORCE )
set( PROJECTS_DOCUMENTATION_OUTPUT_DIR "${PROJECTS_OUTPUT_DIR}/doc/${PROJECTS_PLATFORM}" CACHE PATH "The path to the built documentation" FORCE )

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

macro( install_subdir_headers TARGET SUBDIR CURDIR )
	file(
		GLOB
			_HEADERS
			Src/${CURDIR}${SUBDIR}/*.h
			Src/${CURDIR}${SUBDIR}/*.hpp
			Src/${CURDIR}${SUBDIR}/*.inl
	)
	install(
		FILES ${_HEADERS}
		COMPONENT ${TARGET}_dev
		DESTINATION include/${TARGET}/${CURDIR}${SUBDIR}
	)
endmacro()

macro( install_headers TARGET )
	list_subdirs( _SUBDIRS ${CMAKE_CURRENT_SOURCE_DIR}/Src )
	foreach( _SUBDIR ${_SUBDIRS} )
		install_subdir_headers( ${TARGET} ${_SUBDIR} "" )
		list_subdirs( _SUBSUBDIRS ${CMAKE_CURRENT_SOURCE_DIR}/Src/${_SUBDIR} )
		foreach( _SUBSUBDIR ${_SUBSUBDIRS} )
			install_subdir_headers( ${TARGET} ${_SUBSUBDIR} "${_SUBDIR}/" )
			list_subdirs( _SUBSUBSUBDIRS ${CMAKE_CURRENT_SOURCE_DIR}/Src/${_SUBDIR}/${_SUBSUBDIR} )
			foreach( _SUBSUBSUBDIR ${_SUBSUBSUBDIRS} )
				install_subdir_headers( ${TARGET} ${_SUBSUBSUBDIR} "${_SUBDIR}/${_SUBSUBDIR}/" )
			endforeach()
		endforeach()
	endforeach()

	file(
		GLOB
			TARGET_HEADERS
			${CMAKE_CURRENT_SOURCE_DIR}/Src/*.h
			${CMAKE_CURRENT_SOURCE_DIR}/Src/*.hpp
			${CMAKE_CURRENT_SOURCE_DIR}/Src/*.inl
			${CMAKE_CURRENT_BINARY_DIR}/Src/*.h
			${CMAKE_CURRENT_BINARY_DIR}/Src/*.hpp
			${CMAKE_CURRENT_BINARY_DIR}/Src/*.inl
	)
	install(
		FILES ${TARGET_HEADERS}
		COMPONENT ${TARGET}_dev
		DESTINATION include/${TARGET}
	)
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
function( add_target TARGET_NAME TARGET_TYPE TARGET_DEPENDENCIES TARGET_LINKED_LIBRARIES )# ARGV4=PCH_HEADER ARGV5=PCH_SOURCE ARGV6=OPT_C_FLAGS ARGV7=OPT_CXX_FLAGS ARGV8=OPT_LINK_FLAGS ARGV9=OPT_FILES
	set( PCH_HEADER "${ARGV4}" )
	set( PCH_SOURCE "${ARGV5}" )
	set( OPT_C_FLAGS "${ARGV6}" )
	set( OPT_CXX_FLAGS "${ARGV7}" )
	set( OPT_LINK_FLAGS "${ARGV8}" )
	set( OPT_FILES "${ARGV9}" )
	if((NOT "${CMAKE_BUILD_TYPE}" STREQUAL "") OR MSVC)
		#First we retrieve the kind of target we will build
		string( COMPARE EQUAL ${TARGET_TYPE} "dll" IS_DLL )
		string( COMPARE EQUAL ${TARGET_TYPE} "api_dll" IS_API_DLL )
		string( COMPARE EQUAL ${TARGET_TYPE} "lib" IS_LIB )
		string( COMPARE EQUAL ${TARGET_TYPE} "bin" IS_BIN )
		string( COMPARE EQUAL ${TARGET_TYPE} "bin_dos" IS_BIN_DOS )
		string( COMPARE EQUAL ${TARGET_TYPE} "plugin" IS_PLUGIN )
		string( COMPARE EQUAL ${TARGET_TYPE} "api_plugin" IS_API_PLUGIN )
		msg_debug( "----------------------------------------------------------------------------------------------------" )
		msg_debug( "Target    ${TARGET_NAME}" )
		msg_debug( "Type      ${TARGET_TYPE}" )
		msg_debug( "PCH_HEADER            [${PCH_HEADER}]" )
		msg_debug( "PCH_SOURCE            [${PCH_SOURCE}]" )
		msg_debug( "OPT_C_FLAGS           [${OPT_C_FLAGS}]" )
		msg_debug( "OPT_CXX_FLAGS         [${OPT_CXX_FLAGS}]" )
		msg_debug( "IS_DLL                [${IS_DLL}]" )
		msg_debug( "IS_API_DLL            [${IS_API_DLL}]" )
		msg_debug( "IS_LIB                [${IS_LIB}]" )
		msg_debug( "IS_BIN                [${IS_BIN}]" )
		msg_debug( "IS_BIN_DOS            [${IS_BIN_DOS}]" )
		msg_debug( "IS_PLUGIN             [${IS_PLUGIN}]" )
		msg_debug( "IS_API_PLUGIN         [${IS_API_PLUGIN}]" )
		set( BIN_FOLDER bin )
		if ( IS_LIB )
			#We compute the extended name of the target (libs only)
			compute_abi_name( TARGET_ABI_NAME TARGET_ABI_NAME_DEBUG )
			msg_debug( "TARGET_ABI_NAME       ${TARGET_ABI_NAME}" )
			msg_debug( "TARGET_ABI_NAME_DEBUG ${TARGET_ABI_NAME_DEBUG}" )
		else ()
			set( TARGET_ABI_NAME_DEBUG "d" )
			if ( IS_PLUGIN OR IS_API_PLUGIN )
				set( SUB_FOLDER "/${MAIN_PROJECT_NAME}" )
				set( BIN_FOLDER lib )
			endif ()
		endif ()
		if ( NOT ${PROJECT_NAME}_WXWIDGET )
			set( ${PROJECT_NAME}_WXWIDGET 0 )
		endif ()
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
		#Additional definition, for X64 builds
		if ( NOT "x86" STREQUAL ${PROJECTS_PLATFORM} )
			add_definitions( -D_X64 )
		endif ()
		#We then retrieve target files (located in include/${TARGET_NAME}, source/${TARGET_NAME} and resource/${TARGET_NAME}
		file(
			GLOB_RECURSE
				TARGET_SOURCE_CPP
				Src/*.cpp
		)
		file(
			GLOB_RECURSE
				TARGET_SOURCE_C
				Src/*.c
		)
		file(
			GLOB_RECURSE
				TARGET_SOURCE_H_ONLY
				Src/*.h
				Src/*.hpp
				Src/*.inl
		)
		if ( WIN32 )
			#We include resource files in Visual Studio or MINGW with Windows
			enable_language( RC )
			if ( EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/Src/Win32/${TARGET_NAME}.rc.in )
				configure_file(
					${CMAKE_CURRENT_SOURCE_DIR}/Src/Win32/${TARGET_NAME}.rc.in
					${CMAKE_CURRENT_BINARY_DIR}/Src/Win32/${TARGET_NAME}.rc
					NEWLINE_STYLE LF
				)
				set( TARGET_RSC
					${CMAKE_CURRENT_BINARY_DIR}/Src/Win32/${TARGET_NAME}.rc
				)
			elseif ( EXISTS ${CMAKE_TEMPLATES_DIR}/${TARGET_NAME}.rc.in )
				configure_file(
					${CMAKE_TEMPLATES_DIR}/${TARGET_NAME}.rc.in
					${CMAKE_CURRENT_BINARY_DIR}/Src/Win32/${TARGET_NAME}.rc
					NEWLINE_STYLE LF
				)
				set( TARGET_RSC
					${CMAKE_CURRENT_BINARY_DIR}/Src/Win32/${TARGET_NAME}.rc
				)
			elseif ( EXISTS ${CMAKE_TEMPLATES_DIR}/${RC_IN_FILE} )
				configure_file(
					${CMAKE_TEMPLATES_DIR}/${RC_IN_FILE}
					${CMAKE_CURRENT_BINARY_DIR}/Src/Win32/${TARGET_NAME}.rc
					NEWLINE_STYLE LF
				)
				configure_file(
					${CMAKE_TEMPLATES_DIR}/resource.h.in
					${CMAKE_CURRENT_BINARY_DIR}/Src/Win32/resource.h
					NEWLINE_STYLE LF
				)
				set( TARGET_RSC
					${CMAKE_CURRENT_BINARY_DIR}/Src/Win32/${TARGET_NAME}.rc
				)
			endif ()
			if ( EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/Src/Win32/resource.h" )
				set( TARGET_RSC
					${TARGET_RSC}
					${CMAKE_CURRENT_SOURCE_DIR}/Src/Win32/resource.h
				)
			elseif ( EXISTS "${CMAKE_CURRENT_BINARY_DIR}/Src/Win32/resource.h" )
				set( TARGET_RSC
					${TARGET_RSC}
					${CMAKE_CURRENT_BINARY_DIR}/Src/Win32/resource.h
				)
			endif ()
			if ( EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/Src/Win32/${TARGET_NAME}.rc" )
				set( TARGET_RSC
					${TARGET_RSC}
					${CMAKE_CURRENT_SOURCE_DIR}/Src/Win32/${TARGET_NAME}.rc
				)
			endif()
			if ( EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/Src/Win32/${TARGET_NAME}.rc2" )
				set( TARGET_RSC
					${TARGET_RSC}
					${CMAKE_CURRENT_SOURCE_DIR}/Src/Win32/${TARGET_NAME}.rc2
				)
			endif()
			include_directories( Src/Win32 )
			set( TARGET_SOURCE_H
				${TARGET_SOURCE_H_ONLY}
				${TARGET_RSC}
			)
			source_group( "Resource Files" FILES ${TARGET_RSC} )
		else ()
			set( TARGET_SOURCE_H
				${TARGET_SOURCE_H_ONLY}
			)
		endif ()
		add_definitions(
		 -D${TARGET_NAME}_VERSION_MAJOR=${${TARGET_NAME}_VERSION_MAJOR}
		 -D${TARGET_NAME}_VERSION_MINOR=${${TARGET_NAME}_VERSION_MINOR}
		 -D${TARGET_NAME}_VERSION_BUILD=${${TARGET_NAME}_VERSION_BUILD}
		)
		set( TARGET_C_FLAGS "" )
		set( TARGET_CXX_FLAGS "" )
		set( TARGET_LINK_FLAGS "" )
		compute_compilation_flags( ${TARGET_NAME} ${TARGET_TYPE} "${OPT_C_FLAGS}" "${OPT_CXX_FLAGS}" "${OPT_LINK_FLAGS}" TARGET_C_FLAGS TARGET_CXX_FLAGS TARGET_LINK_FLAGS )
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
		if ( IS_API_DLL OR IS_DLL OR IS_PLUGIN OR IS_API_PLUGIN )
			add_library( ${TARGET_NAME} SHARED ${TARGET_SOURCE_CPP} ${TARGET_SOURCE_C} ${TARGET_SOURCE_H} ${OPT_FILES} )
			set_target_properties( ${TARGET_NAME}
				PROPERTIES
					VERSION ${PROJECTS_VERSION}
					SOVERSION ${PROJECTS_SOVERSION}
					LINK_FLAGS "${TARGET_LINK_FLAGS}"
			)
			#We now build the install script
			if ( WIN32 )
				#We install each .dll in <install_dir>/bin folder
				install(
					TARGETS ${TARGET_NAME}
					COMPONENT ${TARGET_NAME}
					CONFIGURATIONS Release RelWithDebInfo
					EXPORT ${TARGET_NAME}
					RUNTIME DESTINATION ${BIN_FOLDER}${SUB_FOLDER}
					ARCHIVE DESTINATION lib${SUB_FOLDER}
					LIBRARY DESTINATION lib${SUB_FOLDER}
				)
				install(
					TARGETS ${TARGET_NAME}
					COMPONENT ${TARGET_NAME}
					CONFIGURATIONS Debug
					EXPORT ${TARGET_NAME}
					RUNTIME DESTINATION ${BIN_FOLDER}/Debug${SUB_FOLDER}
					ARCHIVE DESTINATION lib/Debug${SUB_FOLDER}
					LIBRARY DESTINATION lib/Debug${SUB_FOLDER}
				)
			else ()
				#We install each .so in <install_dir>/lib folder
				install(
					TARGETS ${TARGET_NAME}
					COMPONENT ${TARGET_NAME}
					CONFIGURATIONS Release RelWithDebInfo
					EXPORT ${TARGET_NAME}
					LIBRARY DESTINATION lib${SUB_FOLDER}
				)
				install(
					TARGETS ${TARGET_NAME}
					COMPONENT ${TARGET_NAME}
					CONFIGURATIONS Debug
					LIBRARY DESTINATION lib/Debug${SUB_FOLDER}
				)
			endif()
			if ( IS_API_DLL OR IS_API_PLUGIN )
				#For API DLLs, we install headers to <install_dir>/include/${TARGET_NAME}
				install_headers( ${TARGET_NAME} )
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
						CONFIGURATIONS Release RelWithDebInfo
						DESTINATION bin
					)
				endif ()
			endif ()
		elseif ( IS_BIN OR IS_BIN_DOS )
			if ( WIN32 AND NOT IS_BIN_DOS )
				add_executable( ${TARGET_NAME} WIN32 ${TARGET_SOURCE_CPP} ${TARGET_SOURCE_C} ${TARGET_SOURCE_H} ${OPT_FILES} )
			else ()
				add_executable( ${TARGET_NAME} ${TARGET_SOURCE_CPP} ${TARGET_SOURCE_C} ${TARGET_SOURCE_H} ${OPT_FILES} )
			endif ()
			set_target_properties( ${TARGET_NAME}
				PROPERTIES
					LINK_FLAGS "${TARGET_LINK_FLAGS}"
			)
			#We now build the install script
			#We copy each exe in <install_dir>/bin folder
			install(
				TARGETS ${TARGET_NAME}
				COMPONENT ${TARGET_NAME}
				CONFIGURATIONS Release RelWithDebInfo
				EXPORT ${TARGET_NAME}
				RUNTIME DESTINATION bin
			)
			install(
				TARGETS ${TARGET_NAME}
				COMPONENT ${TARGET_NAME}
				CONFIGURATIONS Debug
				RUNTIME DESTINATION bin/Debug
			)
		elseif ( IS_LIB )
			add_library( ${TARGET_NAME} STATIC ${TARGET_SOURCE_CPP} ${TARGET_SOURCE_C} ${TARGET_SOURCE_H} ${OPT_FILES} )
			add_target_compilation_flags( ${TARGET_NAME} "-D${TARGET_NAME}_STATIC" )
			if ( MSVC )
				set_target_properties( ${TARGET_NAME}
					PROPERTIES
						STATIC_LIBRARY_FLAGS "${TARGET_LINK_FLAGS}"
				)
			endif()
			#We now build the install script
			#We copy each lib in <install_dir>/lib folder
			install(
				TARGETS ${TARGET_NAME}
				COMPONENT ${TARGET_NAME}_dev
				CONFIGURATIONS Release RelWithDebInfo
				EXPORT ${TARGET_NAME}
				ARCHIVE DESTINATION lib
			)
			install(
				TARGETS ${TARGET_NAME}
				COMPONENT ${TARGET_NAME}_dev
				CONFIGURATIONS Debug
				ARCHIVE DESTINATION lib/Debug
			)
			#For libs, we install headers to <install_dir>/include/${TARGET_NAME}
			install_headers( ${TARGET_NAME} )
		else()
			message( FATAL_ERROR " Unknown target type : [${TARGET_TYPE}]" )
		endif()
		#We add computed ABI name to target outputs
		set_target_properties( ${TARGET_NAME} PROPERTIES LIBRARY_OUTPUT_NAME_RELEASE "${TARGET_NAME}${TARGET_ABI_NAME}")
		set_target_properties( ${TARGET_NAME} PROPERTIES RUNTIME_OUTPUT_NAME_RELEASE "${TARGET_NAME}${TARGET_ABI_NAME}")
		set_target_properties( ${TARGET_NAME} PROPERTIES ARCHIVE_OUTPUT_NAME_RELEASE "${TARGET_NAME}${TARGET_ABI_NAME}")
		#Idem for debug
		set_target_properties( ${TARGET_NAME} PROPERTIES LIBRARY_OUTPUT_NAME_RELWITHDEBINFO "${TARGET_NAME}${TARGET_ABI_NAME}${TARGET_ABI_NAME_RELWITHDEBINFO}")
		set_target_properties( ${TARGET_NAME} PROPERTIES RUNTIME_OUTPUT_NAME_RELWITHDEBINFO "${TARGET_NAME}${TARGET_ABI_NAME}${TARGET_ABI_NAME_RELWITHDEBINFO}")
		set_target_properties( ${TARGET_NAME} PROPERTIES ARCHIVE_OUTPUT_NAME_RELWITHDEBINFO "${TARGET_NAME}${TARGET_ABI_NAME}${TARGET_ABI_NAME_RELWITHDEBINFO}")
		#Idem for debug
		set_target_properties( ${TARGET_NAME} PROPERTIES LIBRARY_OUTPUT_NAME_DEBUG "${TARGET_NAME}${TARGET_ABI_NAME}${TARGET_ABI_NAME_DEBUG}")
		set_target_properties( ${TARGET_NAME} PROPERTIES RUNTIME_OUTPUT_NAME_DEBUG "${TARGET_NAME}${TARGET_ABI_NAME}${TARGET_ABI_NAME_DEBUG}")
		set_target_properties( ${TARGET_NAME} PROPERTIES ARCHIVE_OUTPUT_NAME_DEBUG "${TARGET_NAME}${TARGET_ABI_NAME}${TARGET_ABI_NAME_DEBUG}")
		#We scan dependencies to add it to the target
		foreach( TARGET_DEPENDENCY ${TARGET_DEPENDENCIES} )
			msg_debug( "TARGET_DEPENDENCY     ${TARGET_DEPENDENCY}")
			add_dependencies( ${TARGET_NAME} ${TARGET_DEPENDENCY} )
		endforeach()
		#We scan libraries to add it to the linker
		foreach( TARGET_LIB ${TARGET_LINKED_LIBRARIES} )
			string( REPLACE "|" ";" TARGET_LIB ${TARGET_LIB})
			msg_debug( "TARGET_LIB            ${TARGET_LIB}" )
			target_link_libraries( ${TARGET_NAME} ${TARGET_LIB} )
		endforeach()
		
		set_source_files_properties( ${TARGET_SOURCE_C} PROPERTIES COMPILE_FLAGS "${TARGET_C_FLAGS}")
		set_source_files_properties( ${TARGET_SOURCE_CPP} PROPERTIES COMPILE_FLAGS "${TARGET_CXX_FLAGS}")
		
		if ( PCH_HEADER STREQUAL "" OR NOT ${PROJECTS_USE_PRECOMPILED_HEADERS} )
			msg_debug( "PRECOMPILED HEADERS   No" )
		else ()
			msg_debug( "PRECOMPILED HEADERS   Yes" )
			add_target_precompiled_header( ${TARGET_NAME} ${PCH_HEADER} ${PCH_SOURCE} ${TARGET_CXX_FLAGS} ${TARGET_SOURCE_CPP} )
		endif ()
		if ( MSVC )
			if ( ${PROJECTS_PROFILING} )
				set_target_properties( ${TARGET_NAME} PROPERTIES LINK_FLAGS_DEBUG "${TARGET_LINK_FLAGS} /OPT:NOREF /PROFILE")
			endif ()
		endif ()
		msg_debug( "TARGET_CXX_FLAGS:     ${TARGET_CXX_FLAGS}")
		msg_debug( "TARGET_PCH_FLAGS:     ${TARGET_PCH_FLAGS}")
		msg_debug( "TARGET_C_FLAGS:       ${TARGET_C_FLAGS}")
		msg_debug( "TARGET_LINK_FLAGS:    ${TARGET_LINK_FLAGS}")
	endif()
endfunction( add_target )
