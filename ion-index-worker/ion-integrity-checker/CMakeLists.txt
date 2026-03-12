cmake_minimum_required(VERSION 3.16)

add_executable(ion-integrity-checker
    src/main.cpp
    src/IntegrityChecker.cpp
)

target_compile_features(ion-integrity-checker PRIVATE cxx_std_20)
target_link_libraries(ion-integrity-checker iondb-scanner)

install(TARGETS ion-integrity-checker RUNTIME DESTINATION bin)
