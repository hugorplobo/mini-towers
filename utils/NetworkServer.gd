extends Node

export var is_server := false
var is_in_discover_mode := false
var main_socket: TCP_Server
var discover_socket: PacketPeerUDP
var mutex := Mutex.new()
var server_thread := Thread.new()
var discover_thread := Thread.new()
var parser := ProtocolParserServer.new()
var clients := []
var ids := []
var next_client_id := 1
var game_seed := -1

signal connection(id, player)
signal disconnection(player)
signal left(id)
signal right(id)
signal down(id)
signal rotate_left(id)
signal rotate_right(id)
signal impulse_left(id)
signal impulse_right(id)

func start_server():
#	print("starting server...")
	is_server = true
	is_in_discover_mode = true
	main_socket = TCP_Server.new()
	discover_socket = PacketPeerUDP.new()
	
	discover_socket.listen(9001, "0.0.0.0")
	main_socket.listen(9002, "0.0.0.0")
	server_thread.start(self, "listen_tcp")
	discover_thread.start(self, "listen_udp")

func listen_tcp():
	while true:
		var connection = main_socket.take_connection()
		if (connection):
#			print("connection received...")
			emit_signal("connection", next_client_id, connection.get_connected_host())
			new_player(connection)
			clients.append(connection)
			ids.append(next_client_id)
			
			var thread = Thread.new()
			thread.start(self, "handle_connection", connection)

func listen_udp():
	while is_in_discover_mode:
		if discover_socket.wait() == OK:
			var data = discover_socket.get_var()
			parser.parse(discover_socket.get_packet_ip(), discover_socket.get_packet_port(), data)

func handle_connection(socket: StreamPeerTCP):
	print("%s" % socket.get_connected_host())
	socket.put_var(greetings())
	
	while true:
		var data = socket.get_var()
		if data:
			parser.parse(socket.get_connected_host(), socket.get_connected_port(), data)

func new_player(player: StreamPeerTCP):
	for client in clients:
		client.put_var("new player\n%d\n%s" % [next_client_id, player.get_connected_host()])

func greetings():
	var message = "greetings\n%d" % next_client_id
	next_client_id += 1
	
	for id in ids:
		message += "\n%d" % id
	
	return message

func response_discover(ip: String, port: int):
	discover_socket.set_dest_address(ip, port)
	discover_socket.put_var("i'm a server\n%d" % (clients.size() + 1))

func start_game():
	is_in_discover_mode = false
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	game_seed = rng.randi()
	
	for client in clients:
		client.put_var("start game\n%d" % game_seed)

func send_message(message: String):
	for client in clients:
		client.put_var(message)
