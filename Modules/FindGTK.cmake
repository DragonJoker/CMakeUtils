# - Try to find GTK 3.0
# Once done, this will define
#
#  GTK_FOUND - system has GTK
#  GTK_INCLUDE_DIRS - the GTK include directories
#  GTK_LIBRARIES - link these to use GTK

include(LibFindMacros)

# Dependencies
libfind_package(GTK GDK)
libfind_package(GTK Cairo)
libfind_package(GTK Atk)
libfind_package(GTK GIO)
libfind_package(GTK Pango)

set(GTK_Version 2.0)

# Use pkg-config to get hints about paths
libfind_pkg_check_modules(GTK_PKGCONF gtk+-${GTK_Version})

# Main include dir
find_path(GTK_INCLUDE_DIR
  NAMES gtk/gtk.h
  PATHS ${GTK_PKGCONF_INCLUDE_DIRS}
  PATH_SUFFIXES gtk-${GTK_Version}
)

# Finally the library itself
find_library(GTK_LIBRARY
  NAMES gtk-x11-${GTK_Version} gtk-win32-${GTK_Version} gtk-${GTK_Version} gtk-${GTK_Version}
  PATHS ${GTK_PKGCONF_LIBRARY_DIRS}
)

# Set the include dir variables and the libraries and let libfind_process do the rest.
# NOTE: Singular variables for this library, plural for libraries this this lib depends on.
set(GTK_PROCESS_INCLUDES GTK_INCLUDE_DIR GDK_INCLUDE_DIRS Cairo_INCLUDE_DIRS Atk_INCLUDE_DIRS GIO_INCLUDE_DIRS Pango_INCLUDE_DIRS)
set(GTK_PROCESS_LIBS GTK_LIBRARY GDK_LIBRARIES Cairo_LIBRARIES Atk_LIBRARIES GIO_LIBRARIES Pango_LIBRARIES)
libfind_process(GTK)

