set( VCPKG_TRIPLET_DIR
	${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}
)
set( PNG_INCLUDE_DIR
	${VCPKG_TRIPLET_DIR}/include
)
set( PNG_INCLUDE_DIRS
	${PNG_INCLUDE_DIR}
	${ZLIB_INCLUDE_DIR}
)

if ( MSVC )
	set( PNG_LIBRARY_RELEASE ${VCPKG_TRIPLET_DIR}/lib/libpng16.lib )
	set( PNG_LIBRARY_DEBUG ${VCPKG_TRIPLET_DIR}/debug/lib/libpng16d.lib )
	set( PNG_LIBRARY
		optimized ${PNG_LIBRARY_RELEASE}
		debug ${PNG_LIBRARY_DEBUG}
	)
else ()
	set( PNG_LIBRARY
		${VCPKG_TRIPLET_DIR}/lib/libpng16.a
	)
endif ()

include( FindPackageHandleStandardArgs )
FIND_PACKAGE_HANDLE_STANDARD_ARGS( PNG DEFAULT_MSG PNG_INCLUDE_DIR PNG_LIBRARY )

if( PNG_FOUND )
	if ( NOT TARGET PNG::PNG )
		add_library( PNG::PNG UNKNOWN IMPORTED )
		set_target_properties( PNG::PNG PROPERTIES
			INTERFACE_INCLUDE_DIRECTORIES "${PNG_INCLUDE_DIRS}"
			INTERFACE_LINK_LIBRARIES ZLIB::ZLIB )
		if ( (CMAKE_SYSTEM_NAME STREQUAL "Linux") AND ("${PNG_LIBRARY}" MATCHES "\\${CMAKE_STATIC_LIBRARY_SUFFIX}$") )
			set_property( TARGET PNG::PNG APPEND PROPERTY INTERFACE_LINK_LIBRARIES m )
		endif ()

		if ( EXISTS "${PNG_LIBRARY}" )
			set_target_properties( PNG::PNG PROPERTIES
				IMPORTED_LINK_INTERFACE_LANGUAGES "C"
				IMPORTED_LOCATION "${PNG_LIBRARY}" )
		endif ()
		if ( EXISTS "${PNG_LIBRARY_RELEASE}" )
			set_property( TARGET PNG::PNG APPEND PROPERTY
				IMPORTED_CONFIGURATIONS RELEASE )
			set_target_properties( PNG::PNG PROPERTIES
				IMPORTED_LINK_INTERFACE_LANGUAGES_RELEASE "C"
				IMPORTED_LOCATION_RELEASE "${PNG_LIBRARY_RELEASE}" )
		endif ()
		if ( EXISTS "${PNG_LIBRARY_DEBUG}" )
			set_property( TARGET PNG::PNG APPEND PROPERTY
				IMPORTED_CONFIGURATIONS DEBUG )
			set_target_properties( PNG::PNG PROPERTIES
				IMPORTED_LINK_INTERFACE_LANGUAGES_DEBUG "C"
				IMPORTED_LOCATION_DEBUG "${PNG_LIBRARY_DEBUG}" )
		endif ()
	endif ()
endif ()