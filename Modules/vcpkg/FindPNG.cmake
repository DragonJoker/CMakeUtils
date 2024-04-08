set( VCPKG_TRIPLET_DIR
	${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}
)
set( PNG_INCLUDE_DIR
	${VCPKG_TRIPLET_DIR}/include
)

if ( MSVC )
	set( PNG_LIBRARY
		optimized ${VCPKG_TRIPLET_DIR}/lib/libpng16.lib
		debug ${VCPKG_TRIPLET_DIR}/debug/lib/libpng16d.lib
	)
else()
	set( PNG_LIBRARY
		${VCPKG_TRIPLET_DIR}/lib/libpng16.a
	)
endif()

include( FindPackageHandleStandardArgs )
FIND_PACKAGE_HANDLE_STANDARD_ARGS( PNG DEFAULT_MSG PNG_INCLUDE_DIR PNG_LIBRARY )
