set(SOURCE_FILE main.go)
add_go_executable(ion-emulate-go ${SOURCE_FILE})
add_dependencies(ion-emulate-go ion-marker)