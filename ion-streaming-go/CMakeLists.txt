set(SOURCE_FILE main.go healthz.go)
add_go_executable(ion-streaming-go ${SOURCE_FILE})
add_dependencies(ion-streaming-go ion-marker)
