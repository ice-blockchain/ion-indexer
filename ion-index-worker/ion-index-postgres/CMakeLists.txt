cmake_minimum_required(VERSION 3.16)

add_executable(ion-index-postgres
    src/main.cpp
    src/InsertManagerPostgres.cpp
    src/IndexScheduler.cpp
)

target_compile_features(ion-index-postgres PRIVATE cxx_std_20)
target_link_libraries(ion-index-postgres iondb-scanner pqxx)
target_link_options(ion-index-postgres PUBLIC -rdynamic)

install(TARGETS ion-index-postgres RUNTIME DESTINATION bin)

add_executable(ion-index-postgres-migrate
    src/migrate.cpp
)

target_compile_features(ion-index-postgres-migrate PRIVATE cxx_std_20)
target_link_libraries(ion-index-postgres-migrate pqxx tdutils)
target_link_options(ion-index-postgres-migrate PUBLIC -rdynamic)

install(TARGETS ion-index-postgres-migrate RUNTIME DESTINATION bin)
