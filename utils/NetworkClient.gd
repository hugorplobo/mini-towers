extends Node

var discover_socket := PacketPeerUDP.new()
var main_socket := StreamPeerTCP.new()
var udp_thread := Thread.new()
var parser := ProtocolParserClient.new()

signal found_server(ip, players_qtd)

func start_discover():
	udp_thread.start(self, "run_udp_thread")

func run_udp_thread():
	while true:
		discover()
		var data = discover_socket.get_var()
		if data:
			parser.parse(discover_socket.get_packet_ip(), discover_socket.get_packet_port(), data)
		yield(get_tree().create_timer(2), "timeout")

func discover():
	print("discovering servers...")
	discover_socket = PacketPeerUDP.new()
	discover_socket.set_broadcast_enabled(true)
	discover_socket.set_dest_address("255.255.255.255", 9001)
	discover_socket.put_var("who is a server?")

func connect_to_server(ip: String):
	print("connecting")
	main_socket.connect_to_host(ip, 9002)
