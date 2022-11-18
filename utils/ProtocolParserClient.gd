class_name ProtocolParserClient
extends Node

func parse(ip: String, port: int, data: String):
	if data == "i'm a server":
		print(data)
		NetworkClient.emit_signal("found_server", ip, 2)
