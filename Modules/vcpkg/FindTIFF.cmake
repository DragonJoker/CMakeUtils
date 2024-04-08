set( VCPKG_TRIPLET_DIR
	${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}
)
set( TIFF_INCLUDE_DIR
	${VCPKG_TRIPLET_DIR}/include
)

if ( MSVC )
	set( TIFF_LIBRARY
		optimized ${VCPKG_TRIPLET_DIR}/lib/tiff.lib
		debug ${VCPKG_TRIPLET_DIR}/debug/lib/tiffd.lib
	)
else()
	set( TIFF_LIBRARY
		${VCPKG_TRIPLET_DIR}/lib/libtiff.a
	)
endif()

include( FindPackageHandleStandardArgs )
FIND_PACKAGE_HANDLE_STANDARD_ARGS( TIFF DEFAULT_MSG TIFF_INCLUDE_DIR TIFF_LIBRARY )
