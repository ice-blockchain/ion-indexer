cmake_minimum_required(VERSION 3.16)

project(ion-index-cpp)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

option(PGION "Enable adding the pgion subdirectory" OFF)
option(ION_USE_JEMALLOC "Use \"ON\" to enable JeMalloc." OFF)

# Find jemalloc
if (ION_USE_JEMALLOC)
    list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/external/ion/CMake")
    find_package(jemalloc REQUIRED)

    if (JEMALLOC_FOUND)
        include_directories(${JEMALLOC_INCLUDE_DIR})
        link_libraries(${JEMALLOC_LIBRARIES})
        add_compile_definitions(ION_USE_JEMALLOC)
    endif()
endif()

list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake)
add_subdirectory(external/ion EXCLUDE_FROM_ALL)
add_subdirectory(external/libpqxx EXCLUDE_FROM_ALL)
add_subdirectory(external/clickhouse-cpp EXCLUDE_FROM_ALL)
set(REDIS_PLUS_PLUS_BUILD_TEST OFF CACHE BOOL "disable test" FORCE)
add_subdirectory(external/redis-plus-plus EXCLUDE_FROM_ALL)
set(MSGPACK_USE_BOOST OFF CACHE BOOL "disable boost" FORCE)
set(MSGPACK_USE_STD_VARIANT_ADAPTOR ON CACHE BOOL "enable std::variant" FORCE)
add_subdirectory(external/msgpack-c EXCLUDE_FROM_ALL)

add_subdirectory(iondb-scanner)
add_subdirectory(ion-marker)
add_subdirectory(ion-index-postgres)
add_subdirectory(ion-index-clickhouse)
add_subdirectory(ion-integrity-checker)
add_subdirectory(ion-smc-scanner)
add_subdirectory(ion-trace-emulator)
add_subdirectory(ion-trace-task-emulator)
add_subdirectory(celldb-migrate)

if (PGION)
    message("Building pgion")
    add_subdirectory(pgion)
endif()
