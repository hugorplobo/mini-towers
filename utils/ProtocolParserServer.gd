class_name ProtocolParserServer
extends Node

func parse(ip: String, port: int, data: String):
	var lines = data.split("\n")
	var type = lines[0]
	
	print(type)
	
	if type == "who is a server?":
		NetworkServer.response_discover(ip, port)
