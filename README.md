# odin-jack

**A binding for the [JACK Audio Connection Kit](https://jackaudio.org/) for the [Odin programming language](https://odin-lang.org/)**

`odin-jack` provides Odin language bindings to the JACK audio server library, allowing you to build real-time audio applications using JACK's low-latency, callback-based audio processing model.

This binding is intended for developers working with JACK in Odin for audio synthesis, routing, DSP, or experimentation with real-time audio systems.

---

## Features

- Connect to the JACK audio server
- Register audio input/output ports
- Implement JACK process callbacks
- Control client activation, deactivation, and shutdown
- Query JACK server and client information
- Written in idiomatic Odin style

---

## Requirements

- [Odin programming language](https://odin-lang.org/) (latest version recommended)
- JACK development libraries (`libjack`)
- A running JACK audio server (e.g., `jackd`)

---

## Usage

### Importing the Library

Clone this repository into your Odin project, and import it using the appropriate path:

```odin
import jack "path/to/odin-jack"
```

### Minimal Example

```odin
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
```

More examples are available in the `examples/` directory.

---

## License

This binding (`odin-jack`) is licensed under the GNU LGPLv3 License. See the [LICENSE](./LICENSE) file for details.

**Note on JACK licensing:**

* The JACK **client library** (`libjack`) is licensed under the **LGPL**.
* The JACK **server** (`jackd`) is licensed under the **GPL**.

Using this binding to interface with `libjack` does **not** impose GPL requirements on your application, as long as you do not distribute or statically link against the GPL-only server components.

For full licensing details, refer to:
[https://jackaudio.org/api/](https://jackaudio.org/api/)

---

## Contributing

Contributions are welcome. If you'd like to fix bugs, improve the binding, or add features, feel free to open a pull request or issue.

Please follow the style conventions of Odin and keep the bindings as close to the original C API semantics as reasonable, while making the interface idiomatic for Odin users.

---

## Roadmap / TODO

* [ ] Implement more [example-client](https://github.com/jackaudio/jack-example-tools/blob/main/example-clients)
* [ ] Add documentation comments for the binding

---

## Acknowledgments

* [JACK Audio Connection Kit](https://jackaudio.org/)
* [Odin Programming Language](https://odin-lang.org/)

