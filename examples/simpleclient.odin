package main

// Reimplementation of the simple_client
// Source; https://github.com/jackaudio/jack-example-tools/blob/main/example-clients/simple_client.c
// Run this program via: odin run simpleclient.odin  -file

import "core:c"
import "core:c/libc"
import "core:fmt"
import "core:math"
import "core:os"
import "core:time"
import jack ".."

output_port1, output_port2: ^jack.jack_port_t
client: ^jack.jack_client_t

TABLE_SIZE :: 200

psTestData :: struct {
	sine:        [TABLE_SIZE]f32,
	left_phase:  int,
	right_phase: int,
}

shutdown :: proc "c" (arg: rawptr) {
	return
}

process :: proc "c" (nframes: jack.jack_nframes_t, arg: rawptr) -> c.int {
	out1, out2: [^]jack.jack_default_audio_sample_t
	data := cast(^psTestData)arg
	i: int
	out1 = cast([^]jack.jack_default_audio_sample_t)jack.port_get_buffer(output_port1, nframes)
	out2 = cast([^]jack.jack_default_audio_sample_t)jack.port_get_buffer(output_port2, nframes)

	for i in 0 ..< nframes {
		out1[i] = data.sine[data.left_phase]
		out2[i] = data.sine[data.right_phase]
		data.left_phase += 1
		if data.left_phase >= TABLE_SIZE {
			data.left_phase -= TABLE_SIZE
		}
		data.right_phase += 3
		if data.right_phase >= TABLE_SIZE {
			data.right_phase -= TABLE_SIZE
		}
	}
	return 0
}

main :: proc() {
	fmt.eprintfln("Jack Version: %s", jack.get_version_string())

	data: psTestData
	ports: [^]cstring
	client_name: cstring
	server_name: cstring = nil
	options: jack.jack_options_t = {.NullOption}
	status: jack.jack_status_t

	if len(os.args) >= 2 {
		client_name = cstring(raw_data(os.args[1]))
		if len(os.args) >= 3 {
			server_name = cstring(raw_data(os.args[2]))
			options = {.NullOption, .ServerName}
		}
	} else {
		temp_name := libc.strrchr(raw_data(os.args[0]), '/')
		if temp_name == nil {
			client_name = cstring(raw_data(os.args[0]))
		} else {
			client_name = cstring(temp_name[1:])
		}
	}

	fmt.eprintfln("Client Name: %s", client_name)
	fmt.eprintfln("Server Name: %s", server_name)

	for i in 0 ..< TABLE_SIZE {
		data.sine[i] = 0.2 * math.sin(f32(i) / TABLE_SIZE * math.PI * 2)
	}


	client = jack.client_open(client_name, options, &status, server_name)
	if client == nil {
		fmt.eprintfln("jack_client_open() failed, status: %v", status)
		if jack.JackStatus.ServerFailed in status {
			fmt.eprintfln("Unable to connect to Jack Server")
		}
		return
	}
	if jack.JackStatus.ServerStarted in status {
		fmt.eprintfln("Jack Server started")
	}

	if jack.JackStatus.NameNotUnique in status {
		client_name = cstring(jack.get_client_name(client))
	}

	jack.set_process_callback(client, process, &data)

	jack.on_shutdown(client, shutdown, nil)

	output_port1 = jack.port_register(
		client,
		"output1",
		jack.JACK_DEFAULT_AUDIO_TYPE,
		{.PortIsOutput},
		0,
	)

	output_port2 = jack.port_register(
		client,
		"output2",
		jack.JACK_DEFAULT_AUDIO_TYPE,
		{.PortIsOutput},
		0,
	)

	if (output_port1 == nil) || (output_port2 == nil) {
		fmt.eprintfln("No more Jack Ports available\n")
		return
	}
	if (jack.activate(client) != 0) {
		fmt.eprintfln("Cannot activate client")
		return
	}

	ports = jack.get_ports(client, nil, nil, {.PortIsPhysical, .PortIsInput})

	port_0 := jack.port_by_name(client, ports[0])
	fmt.eprintfln("Port Info: %v", jack.port_flags(port_0))


	if ports == nil {
		fmt.eprintfln("No phyical playback ports")
		return
	}
	if (jack.connect(client, jack.port_name(output_port1), ports[0]) != 0) {
		fmt.eprintfln("Cannot connect output ports")
	}

	if (jack.connect(client, jack.port_name(output_port2), ports[1]) != 0) {
		fmt.eprintfln("Cannot connect output ports")
	}

	jack.free(ports)

	target_duration_in_seconds := 1.0
	begin_time := time.now()

	for {
		current_time := time.now()
		duration := time.diff(begin_time, current_time)
		if time.duration_seconds(duration) >= target_duration_in_seconds {
			break
		}
	}

	jack.client_close(client)


}
