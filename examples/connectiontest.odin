package main

import "core:fmt"
import jack ".."

main :: proc() {
    status:jack.jack_status_t
    client := jack.client_open("odin-client", {.NoStartServer},&status)
    if client == nil {
        fmt.println("Failed to connect to JACK server.")
        return
    }

    defer jack.client_close(client)

    result := jack.activate(client)
    if result != 0 {
        fmt.println("Failed to activate JACK client.")
        return
    }

    fmt.println("JACK client activated.")
}
