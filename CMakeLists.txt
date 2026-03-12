set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${CMAKE_CURRENT_SOURCE_DIR}/cmake")

cmake_minimum_required(VERSION 3.16)

project(ion-indexer LANGUAGES CXX Go)

include(cmake/golang.cmake)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

add_subdirectory(ion-index-worker)
add_subdirectory(ion-emulate-go)
add_subdirectory(ion-index-go)
add_subdirectory(ion-streaming-go)
add_subdirectory(ion-metadata-fetcher)
add_subdirectory(ion-trace-ttl-tracker)
