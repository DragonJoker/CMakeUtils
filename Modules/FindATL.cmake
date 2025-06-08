find_package( PackageHandleStandardArgs )

if ( MSVC )
	if ( NOT ATL_DIR )
		if ( MSVC14 )
			get_filename_component( VS_DIR "[HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\VisualStudio\\14.0\\Setup\\VS;ProductDir]" REALPATH )
			if ( NOT EXISTS ${VS_DIR}/ )
				cmake_host_system_information( RESULT VS_MAJOR QUERY WINDOWS_REGISTRY "HKEY_LOCAL_MACHINE/SOFTWARE/Microsoft/VisualStudio/14.0/VC/Runtimes/X64" VALUE "Major" )
				cmake_host_system_information( RESULT VS_MINOR QUERY WINDOWS_REGISTRY "HKEY_LOCAL_MACHINE/SOFTWARE/Microsoft/VisualStudio/14.0/VC/Runtimes/X64" VALUE "Minor" )
				cmake_host_system_information( RESULT VS_BUILD QUERY WINDOWS_REGISTRY "HKEY_LOCAL_MACHINE/SOFTWARE/Microsoft/VisualStudio/14.0/VC/Runtimes/X64" VALUE "Bld" )
				set( VS_VERSION "${VS_MAJOR}.${VS_MINOR}.${VS_BUILD}")
				if ( ${VS_MINOR} GREATER_EQUAL "30" )
					set( ATL_DIR "C:/Program Files/Microsoft Visual Studio/2022/Community/VC/Tools/MSVC/${VS_VERSION}/atlmfc" )
				elseif ( ${VS_MINOR} GREATER_EQUAL "20" )
					set( ATL_DIR "C:/Program Files/Microsoft Visual Studio/2019/Community/VC/Tools/MSVC/${VS_VERSION}/atlmfc" )
				elseif ( ${VS_MINOR} GREATER_EQUAL "1" )
					set( ATL_DIR "C:/Program Files/Microsoft Visual Studio/2017/Community/VC/Tools/MSVC/${VS_VERSION}/atlmfc" )
				else ()
					set( ATL_DIR "C:/Program Files/Microsoft Visual Studio/2015/Community/VC/Tools/MSVC/${VS_VERSION}/atlmfc" )
				endif ()
			endif ()
			if ( NOT EXISTS ${VS_DIR}/ )
				cmake_host_system_information( RESULT VS_VERSION QUERY WINDOWS_REGISTRY "HKEY_LOCAL_MACHINE/SOFTWARE/WOW6432Node/Microsoft/DevDiv/VC/Servicing/14.0/CRT.Appx" VALUE "Version" )
				string( REGEX MATCH "^([0-9]+)\\.([0-9]+)\\.([0-9]+)" VS_VERSION_MATCH ${VS_VERSION} )
				set( VS_MINOR ${CMAKE_MATCH_2})
				if ( ${VS_MINOR} GREATER_EQUAL "30" )
					set( ATL_DIR "C:/Program Files/Microsoft Visual Studio/2022/Community/VC/Tools/MSVC/${VS_VERSION}/atlmfc" )
				elseif ( ${VS_MINOR} GREATER_EQUAL "20" )
					set( ATL_DIR "C:/Program Files/Microsoft Visual Studio/2019/Community/VC/Tools/MSVC/${VS_VERSION}/atlmfc" )
				elseif ( ${VS_MINOR} GREATER_EQUAL "1" )
					set( ATL_DIR "C:/Program Files/Microsoft Visual Studio/2017/Community/VC/Tools/MSVC/${VS_VERSION}/atlmfc" )
				else ()
					set( ATL_DIR "C:/Program Files/Microsoft Visual Studio/2015/Community/VC/Tools/MSVC/${VS_VERSION}/atlmfc" )
				endif ()
			endif ()
		elseif ( MSVC12 )
			get_filename_component( VS_DIR "[HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\VisualStudio\\12.0\\Setup\\VS;ProductDir]" REALPATH )
		elseif ( MSVC11 )
			get_filename_component( VS_DIR "[HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\VisualStudio\\11.0\\Setup\\VS;ProductDir]" REALPATH )
		elseif ( MSVC10 )
			get_filename_component( VS_DIR "[HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\VisualStudio\\10.0\\Setup\\VS;ProductDir]" REALPATH )
		else()
			message( STATUS "!! Could not find a compatible Visual Studio directory!" )
		endif()
		if ( EXISTS ${VS_DIR}/ )
			set( ATL_DIR ${VS_DIR}/VC )
		endif ()
	endif()

	if ( ATL_DIR )
		FIND_PATH( ATL_ROOT_DIR include/atlbase.h
			HINTS
			PATH_SUFFIXES
				atlmfc
			PATHS
				${ATL_DIR}
		)

		FIND_PATH( ATL_INCLUDE_DIR atlbase.h 
			HINTS
			PATH_SUFFIXES
				include
			PATHS
				${ATL_ROOT_DIR}
		)
	endif()

	mark_as_advanced( ATL_ROOT_DIR ATL_INCLUDE_DIR )
	find_package_handle_standard_args( ATL DEFAULT_MSG ATL_INCLUDE_DIR )
endif()