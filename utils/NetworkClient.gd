extends Node

var discover_socket := PacketPeerUDP.new()
var main_socket := StreamPeerTCP.new()
var udp_thread := Thread.new()
var tcp_thread := Thread.new()
var parser := ProtocolParserClient.new()
var server_ip
var is_discovering := false
var clients := []
var id := -1
var game_seed := -1

signal found_server(ip, players_qtd)
signal greetings
signal new_player(id)
signal start_game
signal state(id, new_state)
signal create_block(field_id, block_id, block_type, next_block_type)
signal free_block(field_id, block_id)
signal petrify_all(field_id)
signal resize

func start_discover():
	is_discovering = true
	udp_thread.start(self, "run_udp_thread")

func run_udp_thread():
	while is_discovering:
		discover()
		var data = discover_socket.get_var()
		if data != null:
			parser.parse(discover_socket.get_packet_ip(), discover_socket.get_packet_port(), data)
		yield(get_tree().create_timer(1), "timeout")

func run_tcp_thread():
	while true:
		var data = main_socket.get_var()
		if data:
			parser.parse(main_socket.get_connected_host(), main_socket.get_connected_port(), data)

func discover():
	print("discovering servers...")
	for i in range(3):
		discover_socket.set_broadcast_enabled(true)
		discover_socket.set_dest_address("255.255.255.255", 9001)
		discover_socket.put_var("who is a server?")

func add_client(client):
	clients.append(client)

func set_server_ip(ip: String):
	server_ip = ip

func connect_to_server():
	print("connecting")
	if main_socket.connect_to_host(server_ip, 9002) == OK:
		is_discovering = false
		tcp_thread.start(self, "run_tcp_thread")
		return true
	else:
		return false

func send_message(message: String):
	main_socket.put_var(message)

func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		print("fechando")
		main_socket.disconnect_from_host()
		get_tree().quit()
