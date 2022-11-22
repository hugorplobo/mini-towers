class_name ProtocolParserClient
extends Node

func parse(ip: String, port: int, data: String):
	var lines = data.split("\n")
	var type = lines[0]
	
	print(type)
	
	match type:
		"i'm a server":
			NetworkClient.emit_signal("found_server", ip, int(lines[1]))
		"greetings":
			NetworkClient.id = lines[1]
			lines.remove(0)
			lines.remove(0)
			for client in lines:
				NetworkClient.add_client(client)
			NetworkClient.emit_signal("greetings")
		"new player":
			NetworkClient.add_client(lines[1])
			NetworkClient.emit_signal("new_player", lines[1])
		"start game":
			NetworkClient.game_seed = lines[1]
			NetworkClient.emit_signal("start_game")
