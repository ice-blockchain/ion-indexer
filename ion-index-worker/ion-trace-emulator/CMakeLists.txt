cmake_minimum_required(VERSION 3.16)

add_library(ion-trace-emulator-core STATIC
    src/TraceEmulator.cpp
    src/OverlayListener.cpp
    src/BlockEmulator.cpp
    src/TraceInterfaceDetector.cpp
    src/Measurement.cpp
)
target_include_directories(ion-trace-emulator-core
    PUBLIC ../external/ion
    PUBLIC src/
    PUBLIC iondb-scanner/src
)
target_link_directories(ion-trace-emulator-core
    PUBLIC ../external/ion
)

target_link_libraries(ion-trace-emulator-core PUBLIC iondb-scanner overlay emulator_static)
target_compile_features(ion-trace-emulator-core PRIVATE cxx_std_20)

add_executable(ion-trace-emulator
    src/main.cpp
    src/DbEventListener.cpp
    src/TraceScheduler.cpp
    src/InvalidatedTraceTracker.cpp
    src/TraceInserter.cpp
    src/RedisListener.cpp
    src/Measurement.h
    src/Measurement.cpp
)
target_include_directories(ion-trace-emulator
    PUBLIC ${CMAKE_CURRENT_BINARY_DIR}/../external/redis-plus-plus/src
)
target_compile_features(ion-trace-emulator PRIVATE cxx_std_20)
target_compile_definitions(ion-trace-emulator PRIVATE -DMSGPACK_USE_DEFINE_MAP)
target_link_libraries(ion-trace-emulator ion-trace-emulator-core hiredis redis++_static msgpack-cxx)
target_link_options(ion-trace-emulator PUBLIC -rdynamic)
install(TARGETS ion-trace-emulator RUNTIME DESTINATION bin)
