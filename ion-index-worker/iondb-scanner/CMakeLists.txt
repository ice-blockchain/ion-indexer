cmake_minimum_required(VERSION 3.16)

add_library(iondb-scanner STATIC
    src/InsertManager.cpp
    src/InsertManagerBase.cpp
    src/DbScanner.cpp
    src/DataParser.cpp
    src/TraceAssembler.cpp
    src/EventProcessor.cpp
    src/queue_state.cpp
    src/parse_token_data.cpp
    src/parse_contract_methods.cpp
    src/convert-utils.cpp
    src/tokens-tlb.cpp
    src/Statistics.cpp
    src/smc-interfaces/Tokens.cpp
    src/smc-interfaces/NftSale.cpp
    src/smc-interfaces/NftSaleV4.cpp
    src/smc-interfaces/execute-smc.cpp
    src/smc-interfaces/Multisig.cpp
    src/smc-interfaces/Multisig.h
    src/smc-interfaces/FetchAccountFromShard.cpp
    src/smc-interfaces/FetchAccountFromShard.h
    src/smc-interfaces/Vesting.cpp
    src/smc-interfaces/Telemint.cpp
)

target_include_directories(iondb-scanner 
    PUBLIC src/
)

target_compile_features(iondb-scanner PRIVATE cxx_std_20)
target_link_libraries(iondb-scanner PUBLIC validator-db validator-disk ion_validator tddb smc-envelope msgpack-cxx)

set(TLB_TOKENS
  ${CMAKE_CURRENT_SOURCE_DIR}/src/tokens-tlb.cpp
  ${CMAKE_CURRENT_SOURCE_DIR}/src/tokens-tlb.h
)

add_custom_command(
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/src
    COMMAND tlbc -o tokens-tlb -n tokens::gen -z tlb/tokens.tlb
    COMMENT "Generate tokes tlb source files"
    OUTPUT ${TLB_TOKENS}
    DEPENDS tlbc src/tlb/tokens.tlb
)

add_custom_target(tlb_generate_tokens DEPENDS ${TLB_TOKENS})
add_dependencies(iondb-scanner tlb_generate_tokens)

set(IONDB_SCANNER_TEST_SOURCE
  ${CMAKE_CURRENT_SOURCE_DIR}/test/tests.cpp
  PARENT_SCOPE
)

add_executable(test-iondb test/tests.cpp ${IONDB_SCANNER_TEST_SOURCE})
target_include_directories(test-iondb
    PUBLIC external/ion
    PUBLIC src/
)

target_link_libraries(test-iondb PRIVATE tdutils tdactor smc-envelope iondb-scanner ion_block)
add_dependencies(test-iondb test-tdutils)
