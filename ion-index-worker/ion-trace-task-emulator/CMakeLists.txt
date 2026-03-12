cmake_minimum_required(VERSION 3.16)

add_executable(ion-trace-task-emulator
    src/main.cpp
    src/TraceTaskScheduler.cpp
    src/TaskResultInserter.cpp
    src/RedisListener.cpp
    src/TonConnectProcessor.cpp
)
target_include_directories(ion-trace-task-emulator
    PUBLIC ${CMAKE_CURRENT_BINARY_DIR}/../external/redis-plus-plus/src
)
target_compile_features(ion-trace-task-emulator PRIVATE cxx_std_20)
target_link_libraries(ion-trace-task-emulator ion-trace-emulator-core hiredis redis++_static msgpack-cxx)
target_link_options(ion-trace-task-emulator PUBLIC -rdynamic)
target_compile_definitions(ion-trace-task-emulator PRIVATE -DMSGPACK_USE_DEFINE_MAP)
install(TARGETS ion-trace-task-emulator RUNTIME DESTINATION bin)
