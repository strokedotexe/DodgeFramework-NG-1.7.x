cmake_minimum_required(VERSION 3.21)

project(
        DodgeFramework
        VERSION 1.0.0
        DESCRIPTION "A SKSE plugin to trigger dodge animation."
        LANGUAGES CXX)

set(PROJECT_FRIENDLY_NAME "Dodge Framework")

set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_INTERPROCEDURAL_OPTIMIZATION ON)

########################################################################################################################
## CommonLibSSE NG (alandtse fork -- the one that reads address library format 5 / Skyrim 1.7.x)
########################################################################################################################
# DMCO ships no VR behavior files, so VR is left out to keep the binary lean.
set(ENABLE_SKYRIM_SE ON CACHE BOOL "" FORCE)
set(ENABLE_SKYRIM_AE ON CACHE BOOL "" FORCE)
set(ENABLE_SKYRIM_VR OFF CACHE BOOL "" FORCE)
set(BUILD_TESTS OFF CACHE BOOL "" FORCE)

add_subdirectory(extern/CommonLibSSE-NG CommonLibSSE EXCLUDE_FROM_ALL)
get_target_property(COMMONLIB_SRC_DIR CommonLibSSE SOURCE_DIR)
include(${COMMONLIB_SRC_DIR}/cmake/CommonLibSSE.cmake)

find_path(SIMPLEINI_INCLUDE_DIRS "SimpleIni.h")

configure_file(
        ${CMAKE_CURRENT_SOURCE_DIR}/cmake/version.rc.in
        ${CMAKE_CURRENT_BINARY_DIR}/version.rc
        @ONLY)

########################################################################################################################
## Plugin
########################################################################################################################
# NAME must stay "DodgeFramework": it is what the MCM, the .log filename and DMCO's
# Papyrus/behavior files all key off of.
add_commonlibsse_plugin(${PROJECT_NAME}
        NAME "DodgeFramework"
        AUTHOR "Ersh"
        VERSION 1.0.0
        USE_ADDRESS_LIBRARY
        SOURCES
        src/main.cpp
        src/Events.cpp
        src/Hooks.cpp
        src/Papyrus.cpp
        src/Settings.cpp
        ${CMAKE_CURRENT_BINARY_DIR}/version.rc)

target_compile_features(${PROJECT_NAME} PRIVATE cxx_std_23)

# Symbols are kept in the optimized build so crash loggers can resolve DMCO frames.
target_compile_options(${PROJECT_NAME} PRIVATE /Zi)
target_link_options(${PROJECT_NAME} PRIVATE /DEBUG:FULL /OPT:REF /OPT:ICF)

target_compile_definitions(${PROJECT_NAME}
        PRIVATE
        WIN32_LEAN_AND_MEAN
        NOMINMAX
        UNICODE
        _UNICODE)

target_include_directories(${PROJECT_NAME}
        PRIVATE
        ${CMAKE_CURRENT_SOURCE_DIR}/src
        ${SIMPLEINI_INCLUDE_DIRS})

target_precompile_headers(${PROJECT_NAME} PRIVATE src/PCH.h)
