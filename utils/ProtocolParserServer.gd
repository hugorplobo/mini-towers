class_name ProtocolParserServer
extends Node

func parse(ip: String, port: int, data: String):
	if data == "who is a server?":
		NetworkServer.response_discover(ip, port)
