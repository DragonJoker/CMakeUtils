# Find OpenGL ES 3
# ----------------
#
# Finds the glslang library.
#
# This module defines:
#
# ::
#
#   glslang_FOUND        - True if glslang library is found.
#   glslang_INCLUDE_DIR  - The glslang include directiories.
#   glslang_LIBRARIES    - The glslang libraries.
#

find_package( PackageHandleStandardArgs )

find_path( glslang_ROOT_DIR include/glslang/Public/ShaderLang.h
	HINTS
	PATHS
		/usr/local
		/usr
)


if ( glslang_ROOT_DIR )
	find_path( glslang_INCLUDE_DIR glslang/Public/ShaderLang.h
		HINTS
		PATH_SUFFIXES
			include
		PATHS
			${glslang_ROOT_DIR}
			/usr/local/include
			/usr/include
	)

	if ( CMAKE_CL_64 OR CMAKE_GENERATOR MATCHES Win64 )
		set( _PLATFORM "x64" )
	else ()
		set( _PLATFORM "x86" )
	endif ()
	if ( WIN32 )
		set( LIB_EXTENSION "lib" )
		set( LIB_PREFIX "" )
	else ()
		set( LIB_EXTENSION "so" )
		set( LIB_PREFIX "lib" )
	endif ()

	find_path( glslang_LIBRARY_RELEASE_DIR ${LIB_PREFIX}glslang.${LIB_EXTENSION}
		HINTS
		PATH_SUFFIXES
			lib/${_PLATFORM}/Release
			lib/${_PLATFORM}
			/usr/local/lib
			/usr/lib
		PATHS
			${glslang_ROOT_DIR}
	)

	find_path( glslang_LIBRARY_DEBUG_DIR ${LIB_PREFIX}glslang.${LIB_EXTENSION}
		HINTS
		PATH_SUFFIXES
			lib/${_PLATFORM}/Debug
			/usr/local/lib
			/usr/lib
		PATHS
			${glslang_ROOT_DIR}
	)

	find_library( glslang_LIBRARY_RELEASE
		NAMES
			${LIB_PREFIX}glslang.${LIB_EXTENSION}
		HINTS
		PATHS
			${glslang_LIBRARY_RELEASE_DIR}
	)

	find_library( glslang_LIBRARY_DEBUG
		NAMES
			${LIB_PREFIX}glslang.${LIB_EXTENSION}
		HINTS
		PATHS
			${glslang_LIBRARY_DEBUG_DIR}
	)

	find_library( OSDependent_LIBRARY_RELEASE
		NAMES
			${LIB_PREFIX}OSDependent.${LIB_EXTENSION}
		HINTS
		PATHS
			${glslang_LIBRARY_RELEASE_DIR}
	)

	find_library( OSDependent_LIBRARY_DEBUG
		NAMES
			${LIB_PREFIX}OSDependent.${LIB_EXTENSION}
		HINTS
		PATHS
			${glslang_LIBRARY_DEBUG_DIR}
	)

	find_library( OGLCompiler_LIBRARY_RELEASE
		NAMES
			${LIB_PREFIX}OGLCompiler.${LIB_EXTENSION}
		HINTS
		PATHS
			${glslang_LIBRARY_RELEASE_DIR}
	)

	find_library( OGLCompiler_LIBRARY_DEBUG
		NAMES
			${LIB_PREFIX}OGLCompiler.${LIB_EXTENSION}
		HINTS
		PATHS
			${glslang_LIBRARY_DEBUG_DIR}
	)

	mark_as_advanced( glslang_LIBRARY_RELEASE_DIR )
	mark_as_advanced( glslang_LIBRARY_DEBUG_DIR )
	mark_as_advanced( glslang_LIBRARY_RELEASE )
	mark_as_advanced( glslang_LIBRARY_DEBUG )
	mark_as_advanced( OSDependent_LIBRARY_RELEASE )
	mark_as_advanced( OSDependent_LIBRARY_DEBUG )
	mark_as_advanced( OGLCompiler_LIBRARY_RELEASE )
	mark_as_advanced( OGLCompiler_LIBRARY_DEBUG )
	find_package_handle_standard_args( glslang DEFAULT_MSG
		glslang_LIBRARY_RELEASE
		glslang_INCLUDE_DIR )

	IF ( glslang_FOUND )
		IF (MSVC)
			if ( glslang_LIBRARY_DEBUG )
				set( glslang_LIBRARIES
					optimized ${glslang_LIBRARY_RELEASE}
					debug ${glslang_LIBRARY_DEBUG}
					optimized ${OSDependent_LIBRARY_RELEASE}
					debug ${OSDependent_LIBRARY_DEBUG}
					optimized ${OGLCompiler_LIBRARY_RELEASE}
					debug ${OGLCompiler_LIBRARY_DEBUG}
					CACHE STRING "glslang libraries"
				)
				set( glslang_LIBRARY_DIRS
					${glslang_LIBRARY_RELEASE_DIR}
					${glslang_LIBRARY_DEBUG_DIR}
				)
			else()
				set( glslang_LIBRARIES
					${glslang_LIBRARY_RELEASE}
					${OSDependent_LIBRARY_RELEASE}
					${OGLCompiler_LIBRARY_RELEASE}
					CACHE STRING "glslang libraries"
				)
				set( glslang_LIBRARY_DIRS
					${glslang_LIBRARY_RELEASE_DIR}
				)
			endif()
		ELSE ()
			if ( glslang_LIBRARY_DEBUG )
				set( glslang_LIBRARIES
					optimized ${glslang_LIBRARY_RELEASE}
					debug ${glslang_LIBRARY_DEBUG}
					optimized ${OSDependent_LIBRARY_RELEASE}
					debug ${OSDependent_LIBRARY_DEBUG}
					optimized ${OGLCompiler_LIBRARY_RELEASE}
					debug ${OGLCompiler_LIBRARY_DEBUG}
					CACHE STRING "glslang libraries"
				)
				set( glslang_LIBRARY_DIRS
					${glslang_LIBRARY_RELEASE_DIR}
					${glslang_LIBRARY_DEBUG_DIR}
				)
			else()
				set( glslang_LIBRARIES
					${glslang_LIBRARY_RELEASE}
					${OSDependent_LIBRARY_RELEASE}
					${OGLCompiler_LIBRARY_RELEASE}
					CACHE STRING "glslang libraries"
				)
				set( glslang_LIBRARY_DIRS
					${glslang_LIBRARY_RELEASE_DIR}
				)
			endif()
		ENDIF ()
	ENDIF ()
endif ()
