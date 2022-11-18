extends Node

var main_socket: TCP_Server
var discover_socket: PacketPeerUDP
var mutex := Mutex.new()
var server_thread := Thread.new()
var discover_thread := Thread.new()
var parser = ProtocolParserServer.new()

signal connection(player)
signal disconnection(player)

func start_server():
	print("starting server...")
	main_socket = TCP_Server.new()
	discover_socket = PacketPeerUDP.new()
	
	discover_socket.listen(9001, "0.0.0.0")
	main_socket.listen(9002, "0.0.0.0")
	server_thread.start(self, "listen_tcp")
	discover_thread.start(self, "listen_udp")

func listen_tcp():
	while (true):
		var connection = main_socket.take_connection()
		if (connection):
			print("connection received...")
			var thread = Thread.new()
			thread.start(self, "handle_connection", connection)

func listen_udp():
	while (true):
		if discover_socket.wait() == OK:
			var data = discover_socket.get_var()
			parser.parse(discover_socket.get_packet_ip(), discover_socket.get_packet_port(), data)

func handle_connection(socket: StreamPeerTCP):
	print(socket)

func response_discover(ip: String, port: int):
	discover_socket.set_dest_address(ip, port)
	discover_socket.put_var("i'm a server")
