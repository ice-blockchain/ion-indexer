cmake_minimum_required(VERSION 3.16)

add_executable(ion-smc-scanner
    src/main.cpp
    src/SmcScanner.cpp
    src/PostgreSQLInserter.cpp
    src/ShardBatchScanner.cpp
)
target_include_directories(ion-smc-scanner
    PUBLIC src
)
target_compile_features(ion-smc-scanner PRIVATE cxx_std_20)
target_link_libraries(ion-smc-scanner iondb-scanner pqxx)

set(INTERFACES_DETECTOR_TYPES "" CACHE STRING "Semicolon-separated list of detectors to instantiate")
string(REPLACE ";" "," DETECTORS_COMMA "${INTERFACES_DETECTOR_TYPES}")

if(DETECTORS_COMMA)
    target_compile_definitions(ion-smc-scanner PRIVATE INTERFACES_DETECTOR_TYPES=${DETECTORS_COMMA})
endif(DETECTORS_COMMA)

install(TARGETS ion-smc-scanner RUNTIME DESTINATION bin)
