class_name ProtocolParserServer
extends Node

func parse(ip: String, port: int, data: String):
	var lines = data.split("\n")
	var type = lines[0]
	
	print(type)
	lines.remove(0)
	
	match type:
		"who is a server?":
			NetworkServer.response_discover(ip, port)
		"left":
			NetworkServer.emit_signal("left", lines[0])
		"right":
			NetworkServer.emit_signal("right", lines[0])
		"down":
			NetworkServer.emit_signal("down", lines[0])
		"rotate left":
			NetworkServer.emit_signal("rotate_left", lines[0])
		"rotate right":
			NetworkServer.emit_signal("rotate_right", lines[0])
		"impulse left":
			NetworkServer.emit_signal("impulse_left", lines[0])
		"impulse right":
			NetworkServer.emit_signal("impulse_right", lines[0])
		"disconnect":
			NetworkServer.on_disconnection(int(lines[0]), ip, port)
