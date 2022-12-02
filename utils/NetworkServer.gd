extends Node

export var is_server := false
var is_in_discover_mode := false
var is_in_lobby := false
var is_in_game := false
var main_socket: TCP_Server
var discover_socket: PacketPeerUDP
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
	is_server = true
	is_in_discover_mode = true
	is_in_lobby = true
	main_socket = TCP_Server.new()
	discover_socket = PacketPeerUDP.new()
	
	discover_socket.listen(9001, "0.0.0.0")
	main_socket.listen(9002, "0.0.0.0")
	server_thread.start(self, "listen_tcp")
	discover_thread.start(self, "listen_udp")

func stop_server():
	is_server = false
	server_thread = Thread.new()
	discover_thread = Thread.new()
	main_socket.stop()
	discover_socket.close()
	clients = []
	ids = []
	next_client_id = 1
	is_in_game = false

func listen_tcp():
	while is_in_lobby:
		if not main_socket.is_connection_available():
			continue
		
		var connection = main_socket.take_connection()
		if (connection):
			print("new connection")
			emit_signal("connection", next_client_id, connection.get_connected_host())
			new_player(connection)
			clients.append(connection)
			ids.append(next_client_id)
			
			var thread = Thread.new()
			thread.start(self, "handle_connection", [connection, next_client_id])

func listen_udp():
	while is_in_discover_mode:
		if discover_socket.wait() == OK:
			var data = discover_socket.get_var()
			parser.parse(discover_socket.get_packet_ip(), discover_socket.get_packet_port(), data)

func handle_connection(init_data):
	print("iniciando thread de conexão")
	var socket: StreamPeerTCP = init_data[0]
	
	while is_in_game or is_in_lobby:
		var data = socket.get_var()
		
		if data:
			parser.parse(socket.get_connected_host(), socket.get_connected_port(), data)

func on_disconnection(id: int, ip: String, port: int):
	ids.remove(ids.find(id))
	var socket
	
	for client in clients:
		var client_socket: StreamPeerTCP = client
		if client_socket.get_connected_host() == ip and client_socket.get_connected_port() == port:
			socket = client_socket
			break
	
	clients.remove(clients.find(socket))
	send_message("disconnection\n%d" % id)
	emit_signal("disconnection", id)

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
	is_in_lobby = false
	is_in_game = true
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	game_seed = rng.randi()
	
	for client in clients:
		client.put_var("start game\n%d" % game_seed)

func send_message(message: String):
	for client in clients:
		client.put_var(message)
