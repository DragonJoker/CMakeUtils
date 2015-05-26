# - Try to find Pangomm 1.4
# Once done, this will define
#
#  Pangomm_FOUND - system has Pangomm
#  Pangomm_INCLUDE_DIRS - the Pangomm include directories
#  Pangomm_LIBRARIES - link these to use Pangomm

include(LibFindMacros)

# Dependencies
libfind_package(Pangomm Pango)
libfind_package(Pangomm Cairomm)
libfind_package(Pangomm Glibmm)

# Use pkg-config to get hints about paths
libfind_pkg_check_modules(Pangomm_PKGCONF pangomm-1.4)

# Main include dir
find_path(Pangomm_INCLUDE_DIR
  NAMES pangomm.h
  PATHS ${Pangomm_PKGCONF_INCLUDE_DIRS}
  PATH_SUFFIXES pangomm-1.4
)

# Glib-related libraries also use a separate config header, which is in lib dir
find_path(PangommConfig_INCLUDE_DIR
  NAMES pangommconfig.h
  PATHS ${Pangomm_PKGCONF_INCLUDE_DIRS} 
  PATH_SUFFIXES lib/pangomm-1.4/include 
)

libfind_library(Pangomm pangomm 1.4)

# Set the include dir variables and the libraries and let libfind_process do the rest.
# NOTE: Singular variables for this library, plural for libraries this this lib depends on.
set(Pangomm_PROCESS_INCLUDES 
        Pangomm_INCLUDE_DIR
        PangommConfig_INCLUDE_DIR 
        Pango_INCLUDE_DIRS 
        Cairomm_INCLUDE_DIRS 
        Glibmm_INCLUDE_DIRS)

set(Pangomm_PROCESS_LIBS 
        Pangomm_LIBRARY 
        Pango_LIBRARIES 
        Cairomm_LIBRARIES 
        Glibmm_LIBRARIES)
        
libfind_process(Pangomm)

