include( CompilerVersion )
include( Logging )

if ( MSVC14 )
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
	DumpCompilerVersion( COMPILER_VERSION )
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

#--------------------------------------------------------------------------------------------------
#	Function :	compute_abi_name
# 	Function which computes the extended library name, with compiler version and debug flag
#--------------------------------------------------------------------------------------------------
function( compute_abi_name ABI_Name ABI_Name_Debug )
	set( _ABI_Name "-${COMPILER}")
	set( _ABI_Name_Debug "-d")
	set( ${ABI_Name} ${_ABI_Name} PARENT_SCOPE )
	set( ${ABI_Name_Debug} ${_ABI_Name_Debug} PARENT_SCOPE )
endfunction( compute_abi_name )