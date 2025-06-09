#******************************************************************************
# add_com_interfaces
#
# Syntax: add_com_interfaces( <output list> <idl1> [<idl2> [...]] )
# Notes: 
#   <idlN> should be absolute paths so the MIDL compiler can find them.
#   For every idl file xyz.idl, two files xyz_h.h and xyz.c are generated
#   which are added to the <output list>
#
#******************************************************************************
macro( add_com_interfaces OUTPUT_LIST )
	if( ${CMAKE_SIZEOF_VOID_P} EQUAL 4 )
		set( MIDL_ARCH win32 )
	else()
		set( MIDL_ARCH x64 )
	endif()
	foreach( IDL_FILE ${ARGN} )
		get_filename_component( OUT_FILE ${IDL_FILE} NAME_WE )
		get_filename_component( IN_PATH ${IDL_FILE} PATH )

		set( OUT_HEADER_NAME ${OUT_FILE}_i.h )
		set( OUT_HEADER ${CMAKE_CURRENT_BINARY_DIR}/${OUT_HEADER_NAME} )
		set( OUT_IID_NAME ${OUT_FILE}_i.c )
		set( OUT_IID ${CMAKE_CURRENT_BINARY_DIR}/${OUT_IID_NAME} )

		add_custom_command( OUTPUT ${OUT_HEADER} ${OUT_IID}
			DEPENDS ${IDL_FILE}
			COMMAND midl
			ARGS ${IDL_FILE} /nologo /env ${MIDL_ARCH} /header ${OUT_HEADER_NAME} /iid ${OUT_IID_NAME} /out ${CMAKE_CURRENT_BINARY_DIR} /I ${CMAKE_CURRENT_SOURCE_DIR}
			WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
		)
		set_source_files_properties( ${OUT_HEADER} ${OUT_IID}
			PROPERTIES
				GENERATED TRUE
		)
		set_source_files_properties( ${IDL_FILE}
			PROPERTIES
				HEADER_FILE_ONLY TRUE
		)
		set( ${OUTPUT_LIST} ${${OUTPUT_LIST}} ${OUT_HEADER} ${OUT_IID} )
	endforeach()
endmacro( add_com_interfaces )

#******************************************************************************
# add_com_interop
#
# Syntax: add_com_interop( <target_name> <idl1> [<idl2> [...]] )
# Notes:
#   For each provided IDL file, creates a library to link to C# projects,
#   to be able to use the classes described in the IDL.
#
#******************************************************************************
macro( add_com_interop _TARGET_NAME )
	# Find tlbimp executable
	file( GLOB TLBIMPv7_FILES "C:/Program Files*/Microsoft SDKs/Windows/v7*/bin/TlbImp.exe" )
	file( GLOB TLBIMPv8_FILES "C:/Program Files*/Microsoft SDKs/Windows/v8*/bin/*/TlbImp.exe" )
	file( GLOB TLBIMPv10_FILES "C:/Program Files*/Microsoft SDKs/Windows/v10*/bin/*/TlbImp.exe" )
	list( APPEND TLBIMP_FILES ${TLBIMPv7_FILES} ${TLBIMPv8_FILES} ${TLBIMPv10_FILES} )
	if( TLBIMP_FILES )
		list( GET TLBIMP_FILES -1 TLBIMP_FILE )
	endif()
	if( NOT TLBIMP_FILE )
		message( FATAL_ERROR "Cannot found tlbimp.exe. Try to download .NET Framework SDK and .NET Framework targeting pack." )
		return()
	endif()

	# Setup output path
	set( TLBIMP_OUTPUT_PATH ${PROJECTS_BINARIES_OUTPUT_DIR} )
	set( TLBIMP_LOCATION_PATH ${TLBIMP_OUTPUT_PATH} )
	if( "${TLBIMP_OUTPUT_PATH}" STREQUAL "" )
		set( TLBIMP_OUTPUT_PATH ${CMAKE_RUNTIME_OUTPUT_DIRECTORY} )
		set( TLBIMP_LOCATION_PATH ${CMAKE_RUNTIME_OUTPUT_DIRECTORY} )
	else()
		set( TLBIMP_OUTPUT_PATH ${TLBIMP_OUTPUT_PATH}/$<CONFIGURATION>/bin )
		set( TLBIMP_LOCATION_PATH ${TLBIMP_LOCATION_PATH}/$(Configuration)/bin )
	endif()
	if( "${TLBIMP_OUTPUT_PATH}" STREQUAL "" )
		set( TLBIMP_OUTPUT_PATH ${CMAKE_CURRENT_BINARY_DIR} )
		set( TLBIMP_LOCATION_PATH ${CMAKE_CURRENT_BINARY_DIR} )
	endif()

	# Parse provided IDL files
	foreach( IDL_FILE ${ARGN} )
		get_filename_component( IDL_FILENAME_WE ${IDL_FILE} NAME_WE )
		set( TLBIMP_OUTPUT_NAME ${IDL_FILENAME_WE}Interop )
		set( TLBIMP_OUTPUT ${TLBIMP_OUTPUT_PATH}/${TLBIMP_OUTPUT_NAME}.dll )
		set( OUT_HEADER_NAME ${OUT_FILE}_i.h )
		set( OUT_HEADER ${CMAKE_CURRENT_BINARY_DIR}/${OUT_HEADER_NAME} )
		# The command running tlbimp.exe
		add_custom_command( OUTPUT  ${TLBIMP_OUTPUT}
			COMMAND ${TLBIMP_FILE}
			ARGS "${CMAKE_CURRENT_BINARY_DIR}/${IDL_FILENAME_WE}.tlb" /silence:3002 "/out:${TLBIMP_OUTPUT}"
			DEPENDS ${OUT_HEADER}
			WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
			VERBATIM
		)
		add_custom_target( ${IDL_FILENAME_WE}TlbImp
			DEPENDS ${OUT_HEADER} ${TLBIMP_OUTPUT}
			SOURCES ${IDL_FILE}
		)
		set_target_properties( ${IDL_FILENAME_WE}TlbImp
			PROPERTIES
				FOLDER "Interop"
		)
		add_library( ${TLBIMP_OUTPUT_NAME}
			SHARED
			IMPORTED GLOBAL
		)
		add_dependencies( ${TLBIMP_OUTPUT_NAME}
			${IDL_FILENAME_WE}TlbImp
		)
		set_target_properties( ${TLBIMP_OUTPUT_NAME}
			PROPERTIES
				IMPORTED_LOCATION_DEBUG "${TLBIMP_LOCATION_PATH}/${TLBIMP_OUTPUT_NAME}.dll"
				IMPORTED_LOCATION_RELEASE "${TLBIMP_LOCATION_PATH}/${TLBIMP_OUTPUT_NAME}.dll"
				IMPORTED_COMMON_LANGUAGE_RUNTIME "CSharp"
		)
	endforeach()
endmacro( add_com_interop )

#******************************************************************************
# add_interface
#
# Notes:
#   Creates the RGS file to be able to register the object as a COM component
#   Adds the RGS file to the RGS files list, for the resources .rc file
#   Adds the RGS file id to the resources .h file
#
#******************************************************************************
macro( add_interface OBJECT_IID RESRC_LIST RESH_LIST RESOURCE_ID OBJECT_NAME )
	SET( _OBJECT_IID ${OBJECT_IID} )
	SET( _OBJECT_NAME ${OBJECT_NAME} )
	configure_file(
		${CMAKE_TEMPLATES_DIR}/ComInterface.rgs.in
		${CMAKE_CURRENT_BINARY_DIR}/Win32/Com${_OBJECT_NAME}.rgs
	)
	set( ${RESRC_LIST} "${${RESRC_LIST}}\nIDR_${_OBJECT_NAME}	REGISTRY	\"${CMAKE_CURRENT_BINARY_DIR}/Win32/Com${_OBJECT_NAME}.rgs\"" )
	set( ${RESH_LIST} "${${RESH_LIST}}\n#define IDR_${_OBJECT_NAME}		${${RESOURCE_ID}}" )
	math( EXPR ${RESOURCE_ID} "${${RESOURCE_ID}}+1")
endmacro( add_interface )

#******************************************************************************
# register_target
#
# Notes:
#   Adds a post build, and a post install events to register a DLL, using
#   regsvr32.
#
#******************************************************************************
function( register_target _TARGET_NAME )
	if ( WIN32 )
		set( _PATH_DEBUG "${PROJECTS_BINARIES_OUTPUT_DIR_DEBUG}/bin/${_TARGET_NAME}d.dll" )
		set( _PATH_RELEASE "${PROJECTS_BINARIES_OUTPUT_DIR_RELEASE}/bin/${_TARGET_NAME}.dll" )
		set( _PATH_RELWITHDEBINFO "${PROJECTS_BINARIES_OUTPUT_DIR_RELWITHDEBINFO}/bin/${_TARGET_NAME}.dll" )
		file( TO_NATIVE_PATH ${_PATH_DEBUG} _PATH_DEBUG )
		file( TO_NATIVE_PATH ${_PATH_RELEASE} _PATH_RELEASE )
		file( TO_NATIVE_PATH ${_PATH_RELWITHDEBINFO} _PATH_RELWITHDEBINFO )
		set( _COMMAND_DEBUG "regsvr32 /s ${_PATH_DEBUG}" )
		set( _COMMAND_RELEASE "regsvr32 /s ${_PATH_RELEASE}" )
		set( _COMMAND_RELWITHDEBINFO "regsvr32 /s ${_PATH_RELWITHDEBINFO}" )

		add_custom_command(
			TARGET ${_TARGET_NAME}
			POST_BUILD
			COMMAND runas /trustlevel:0x20000
				$<$<CONFIG:Debug>:"${_COMMAND_DEBUG}">
				$<$<CONFIG:Release>:"${_COMMAND_RELEASE}">
				$<$<CONFIG:RelWithDebInfo>:"${_COMMAND_RELWITHDEBINFO}">
		)
	endif ()
endfunction( register_target )
