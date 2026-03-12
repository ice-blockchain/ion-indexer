cmake_minimum_required(VERSION 3.16)

add_executable(ion-index-clickhouse 
    src/main.cpp
    src/InsertManagerClickhouse.cpp
    src/IndexScheduler.cpp
)

target_compile_features(ion-index-clickhouse PRIVATE cxx_std_20)
target_link_libraries(ion-index-clickhouse iondb-scanner clickhouse-cpp-lib)

install(TARGETS ion-index-clickhouse RUNTIME DESTINATION bin)
