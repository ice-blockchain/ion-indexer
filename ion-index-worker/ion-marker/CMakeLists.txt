cmake_minimum_required(VERSION 3.16)

# enable PIC for all targets by default
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

# generate C++ from TL-B
add_custom_command(
    OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/auto/schemes.cpp ${CMAKE_CURRENT_BINARY_DIR}/auto/schemes.h
    COMMAND ${CMAKE_COMMAND} -E make_directory ${CMAKE_CURRENT_BINARY_DIR}/auto
    COMMAND $<TARGET_FILE:tlbc>
    -o ${CMAKE_CURRENT_BINARY_DIR}/auto/schemes
    -n schemes
    -z
    ${CMAKE_CURRENT_SOURCE_DIR}/src/schemes/schemes.tlb
    COMMAND ${CMAKE_COMMAND} -E echo "Generated schemes.cpp and schemes.h from TLB"
    DEPENDS tlbc ${CMAKE_CURRENT_SOURCE_DIR}/src/schemes/schemes.tlb
    VERBATIM
)

# core library
add_library(ion-marker-core STATIC
    src/special.cpp
    src/logic.cpp
    ${CMAKE_CURRENT_BINARY_DIR}/auto/schemes.h
    ${CMAKE_CURRENT_BINARY_DIR}/auto/schemes.cpp
)

target_compile_features(ion-marker-core PUBLIC cxx_std_20)
target_link_libraries(ion-marker-core PUBLIC iondb-scanner)
target_include_directories(ion-marker-core PUBLIC 
    ${CMAKE_CURRENT_SOURCE_DIR}/src
    ${CMAKE_CURRENT_BINARY_DIR}/auto
    external/ion
)

# c-api library for go
add_library(ion-marker SHARED
    src/wrapper.cpp
)

target_compile_features(ion-marker PRIVATE cxx_std_20)
target_link_libraries(ion-marker PRIVATE ion-marker-core)

# cli executable
add_executable(ion-marker-cli
    src/main.cpp
)

target_compile_features(ion-marker-cli PRIVATE cxx_std_20)
target_link_libraries(ion-marker-cli PRIVATE ion-marker-core)

# install targets
install(TARGETS ion-marker-core ion-marker ion-marker-cli
    RUNTIME DESTINATION bin
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
)

install(FILES 
    src/logic.h
    src/wrapper.h
    DESTINATION include/ion-marker
)
