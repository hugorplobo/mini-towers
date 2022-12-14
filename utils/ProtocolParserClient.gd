class_name ProtocolParserClient
extends Node

func parse(ip: String, port: int, data: String):
	var lines = data.split("\n")
	var type = lines[0]
	
	print(data, "\n")
	lines.remove(0)
	
	match type:
		"i'm a server":
			NetworkClient.emit_signal("found_server", ip, int(lines[0]))
		"greetings":
			if NetworkClient.id == -1:
				NetworkClient.id = lines[0]
			lines.remove(0)
			
			for client in lines:
				if not NetworkClient.clients.has(client):
					NetworkClient.add_client(client)
			
			NetworkClient.emit_signal("greetings")
		"new player":
			NetworkClient.add_client(lines[0])
			NetworkClient.emit_signal("new_player", lines[0])
		"start game":
			NetworkClient.game_seed = lines[0]
			NetworkClient.emit_signal("start_game")
		"state":
			var id = lines[0]
			lines.remove(0)
			NetworkClient.emit_signal("state", id, lines)
		"create block":
			NetworkClient.emit_signal("create_block", lines[0], lines[1], lines[2], lines[3])
		"free block":
			NetworkClient.emit_signal("free_block", lines[0], lines[1])
		"petrify all":
			NetworkClient.emit_signal("petrify_all", lines[0])
		"resize":
			NetworkClient.emit_signal("resize")
		"disconnection":
			NetworkClient.on_disconnection(lines[0])
		"end game":
			NetworkClient.emit_signal("end_game", lines[0])
			NetworkClient.disconnect_from_server()
