# - Try to find GTKmm 3.0
# Once done, this will define
#
#  GTKmm_FOUND - system has GTKmm
#  GTKmm_INCLUDE_DIRS - the GTKmm include directories
#  GTKmm_LIBRARIES - link these to use GTKmm

include(LibFindMacros)

# Dependencies
libfind_package(GTKmm GTK)
libfind_package(GTKmm Glibmm)
libfind_package(GTKmm GIOmm)
libfind_package(GTKmm GDKmm)
libfind_package(GTKmm Pangomm)
libfind_package(GTKmm Atkmm)

set(GTKmm_Version 3.0)


# Use pkg-config to get hints about paths
libfind_pkg_check_modules(GTKmm_PKGCONF gtkmm-${GTKmm_Version})

# Main include dir
find_path(GTKmm_INCLUDE_DIR
  NAMES gtkmm.h
  PATHS ${GTKmm_PKGCONF_INCLUDE_DIRS}
  PATH_SUFFIXES gtkmm-${GTKmm_Version}
)

# Glib-related libraries also use a separate config header, which is in lib dir
find_path(GTKmmConfig_INCLUDE_DIR
  NAMES gtkmmconfig.h
  PATHS ${GTKmm_PKGCONF_INCLUDE_DIRS} 
  PATH_SUFFIXES lib/gtkmm-${GTKmm_Version}/include 
)

libfind_library(GTKmm gtkmm ${GTKmm_Version})

# Set the include dir variables and the libraries and let libfind_process do the rest.
# NOTE: Singular variables for this library, plural for libraries this this lib depends on.
set(GTKmm_PROCESS_INCLUDES 
        GTKmm_INCLUDE_DIR 
        GTKmmConfig_INCLUDE_DIR 
        GTK_INCLUDE_DIRS 
        Glibmm_INCLUDE_DIRS 
        GIOmm_INCLUDE_DIRS 
        GDKmm_INCLUDE_DIRS 
        Pangomm_INCLUDE_DIRS 
        Atkmm_INCLUDE_DIRS)

set(GTKmm_PROCESS_LIBS 
        GTKmm_LIBRARY 
        GTK_LIBRARIES 
        Glibmm_LIBRARIES 
        GIOmm_LIBRARIES 
        GDKmm_LIBRARIES 
        Pangomm_LIBRARIES 
        Atkmm_LIBRARIES)
        
libfind_process(GTKmm)

