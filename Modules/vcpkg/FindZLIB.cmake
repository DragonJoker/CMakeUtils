set( VCPKG_TRIPLET_DIR
	${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}
)
set( ZLIB_INCLUDE_DIR
	${VCPKG_TRIPLET_DIR}/include
)

if ( MSVC )
	set( ZLIB_LIBRARY_RELEASE
		${VCPKG_TRIPLET_DIR}/lib/zlib.lib
	)
	set( ZLIB_LIBRARY_DEBUG
		${VCPKG_TRIPLET_DIR}/debug/lib/zlibd.lib
	)
	set( ZLIB_LIBRARY
		optimized ${ZLIB_LIBRARY_RELEASE}
		debug ${ZLIB_LIBRARY_DEBUG}
	)
else()
	set( ZLIB_LIBRARY
		${VCPKG_TRIPLET_DIR}/lib/libz.a
	)
endif()

include( FindPackageHandleStandardArgs )
FIND_PACKAGE_HANDLE_STANDARD_ARGS( ZLIB DEFAULT_MSG ZLIB_INCLUDE_DIR ZLIB_LIBRARY )

if ( ZLIB_FOUND )
	set( ZLIB_INCLUDE_DIRS ${ZLIB_INCLUDE_DIR} )

	if ( NOT ZLIB_LIBRARIES )
		set(ZLIB_LIBRARIES ${ZLIB_LIBRARY})
	endif ()

	if ( NOT TARGET ZLIB::ZLIB )
		add_library(ZLIB::ZLIB UNKNOWN IMPORTED)
		set_target_properties(ZLIB::ZLIB PROPERTIES
			INTERFACE_INCLUDE_DIRECTORIES "${ZLIB_INCLUDE_DIRS}")

		if ( EXISTS "${ZLIB_LIBRARY}" )
			set_target_properties( ZLIB::ZLIB PROPERTIES
				IMPORTED_LINK_INTERFACE_LANGUAGES "C"
				IMPORTED_LOCATION "${ZLIB_LIBRARY}" )
		endif ()
		if ( EXISTS "${ZLIB_LIBRARY_RELEASE}" )
			set_property( TARGET ZLIB::ZLIB APPEND PROPERTY
				IMPORTED_CONFIGURATIONS RELEASE )
			set_target_properties( ZLIB::ZLIB PROPERTIES
				IMPORTED_LINK_INTERFACE_LANGUAGES_RELEASE "C"
				IMPORTED_LOCATION_RELEASE "${ZLIB_LIBRARY_RELEASE}" )
		endif ()
		if ( EXISTS "${ZLIB_LIBRARY_DEBUG}" )
			set_property( TARGET ZLIB::ZLIB APPEND PROPERTY
				IMPORTED_CONFIGURATIONS DEBUG )
			set_target_properties( ZLIB::ZLIB PROPERTIES
				IMPORTED_LINK_INTERFACE_LANGUAGES_DEBUG "C"
				IMPORTED_LOCATION_DEBUG "${ZLIB_LIBRARY_DEBUG}" )
		endif ()
	endif ()
endif ()
