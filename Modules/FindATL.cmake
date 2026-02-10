find_package( PackageHandleStandardArgs )

if ( MSVC )
	if ( NOT ATL_DIR )
		if ( MSVC14 )
			set( VS_BASE_DIR "C:/Program Files/Microsoft Visual Studio" )
			if ( EXISTS ${VS_BASE_DIR}/18/ )
				set( VS_BASE_DIR ${VS_BASE_DIR}/18 )
			elseif ( EXISTS ${VS_BASE_DIR}/2022/ )
				set( VS_BASE_DIR ${VS_BASE_DIR}/2022 )
			elseif ( EXISTS ${VS_BASE_DIR}/2019/ )
				set( VS_BASE_DIR ${VS_BASE_DIR}/2019 )
			elseif ( EXISTS ${VS_BASE_DIR}/2017/ )
				set( VS_BASE_DIR ${VS_BASE_DIR}/2017 )
			elseif ( EXISTS ${VS_BASE_DIR}/2015/ )
				set( VS_BASE_DIR ${VS_BASE_DIR}/2015 )
			endif ()
			if ( EXISTS ${VS_BASE_DIR}/Professional/ )
				set( VS_BASE_DIR ${VS_BASE_DIR}/Professional )
			else ()
				set( VS_BASE_DIR ${VS_BASE_DIR}/Community )
			endif ()
			get_filename_component( VS_DIR "[HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\VisualStudio\\14.0\\Setup\\VS;ProductDir]" REALPATH )
			if ( NOT EXISTS ${VS_DIR}/ )
				cmake_host_system_information( RESULT VS_MAJOR QUERY WINDOWS_REGISTRY "HKEY_LOCAL_MACHINE/SOFTWARE/Microsoft/VisualStudio/14.0/VC/Runtimes/X64" VALUE "Major" )
				cmake_host_system_information( RESULT VS_MINOR QUERY WINDOWS_REGISTRY "HKEY_LOCAL_MACHINE/SOFTWARE/Microsoft/VisualStudio/14.0/VC/Runtimes/X64" VALUE "Minor" )
				cmake_host_system_information( RESULT VS_BUILD QUERY WINDOWS_REGISTRY "HKEY_LOCAL_MACHINE/SOFTWARE/Microsoft/VisualStudio/14.0/VC/Runtimes/X64" VALUE "Bld" )
				set( VS_VERSION "${VS_MAJOR}.${VS_MINOR}.${VS_BUILD}")
				set( ATL_DIR ${VS_BASE_DIR}/VC/Tools/MSVC/${VS_VERSION}/atlmfc )
			endif ()
			if ( NOT EXISTS ${VS_DIR}/ )
				cmake_host_system_information( RESULT VS_VERSION QUERY WINDOWS_REGISTRY "HKEY_LOCAL_MACHINE/SOFTWARE/WOW6432Node/Microsoft/DevDiv/VC/Servicing/14.0/CRT.Appx" VALUE "Version" )
				if ( NOT VS_VERSION )
					cmake_host_system_information( RESULT VS_VERSION QUERY WINDOWS_REGISTRY "HKEY_LOCAL_MACHINE/SOFTWARE/WOW6432Node/Microsoft/DevDiv/VC/Servicing/14.0/CRT.Appx.ARM64" VALUE "Version" )
				endif ()
				if ( VS_VERSION )
					set( ATL_DIR ${VS_BASE_DIR}/VC/Tools/MSVC/${VS_VERSION}/atlmfc )
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