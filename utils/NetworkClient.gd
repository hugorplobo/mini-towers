extends Node

var discover_socket := PacketPeerUDP.new()
var main_socket := StreamPeerTCP.new()
var udp_thread := Thread.new()
var tcp_thread := Thread.new()
var parser := ProtocolParserClient.new()
var server_ip
var is_discovering := false
var is_in_game := true
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
signal disconnection(id)
signal end_game(id)

func start_discover():
	is_discovering = true
	udp_thread.start(self, "run_udp_thread")

func disconnect_from_server():
	is_in_game = false
	clients = []
	udp_thread = Thread.new()
	tcp_thread = Thread.new()
	main_socket.disconnect_from_host()

func run_udp_thread():
	while is_discovering:
		discover()
		var data = discover_socket.get_var()
		if data != null:
			parser.parse(discover_socket.get_packet_ip(), discover_socket.get_packet_port(), data)
		yield(get_tree().create_timer(1), "timeout")

func run_tcp_thread():
	while is_in_game:
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

func connect_to_server(ip: String):
	print("connecting")
	if main_socket.connect_to_host(ip, 9002) == OK:
		print("connected")
		server_ip = ip
		is_discovering = false
		is_in_game = true
		tcp_thread.start(self, "run_tcp_thread")
		return true
	else:
		return false

func on_disconnection(id):
	clients.remove(id)
	emit_signal("disconnection", int(id))

func send_message(message: String):
	main_socket.put_var(message)

func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		print("fechando")
		main_socket.put_var("disconnect\n%d" % id)
		main_socket.disconnect_from_host()
		get_tree().quit()
