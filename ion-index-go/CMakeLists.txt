set(SOURCE_FILE main.go)
add_go_executable(ion-index-go ${SOURCE_FILE})
generate_swagger(ion-index-go)

add_dependencies(ion-index-go ion-marker)
