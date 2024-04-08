set( VCPKG_TRIPLET_DIR
	${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}
)
set( JPEG_INCLUDE_DIR
	${VCPKG_TRIPLET_DIR}/include
)

if ( MSVC )
	set( JPEG_LIBRARY
		optimized ${VCPKG_TRIPLET_DIR}/lib/jpeg.lib
		debug ${VCPKG_TRIPLET_DIR}/debug/lib/jpeg.lib
	)
else()
	set( JPEG_LIBRARY
		${VCPKG_TRIPLET_DIR}/lib/libjpeg.a
	)
endif()

include( FindPackageHandleStandardArgs )
FIND_PACKAGE_HANDLE_STANDARD_ARGS( JPEG DEFAULT_MSG JPEG_INCLUDE_DIR JPEG_LIBRARY )
