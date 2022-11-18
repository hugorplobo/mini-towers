extends Control

var server_item = preload("res://scenes/servers/ServerItem.tscn")
var server_ips = []

func _ready():
	$AnimationPlayer.play("Loading")
	NetworkClient.start_discover()
	NetworkClient.connect("found_server", self, "on_found_server")

func on_found_server(ip: String, players_qtd: int):
	if not server_ips.has(ip):
		server_ips.append(ip)
		var server = server_item.instance()
		server.get_node("HBoxContainer/VBoxContainer/Ip").text = ip
		server.get_node("HBoxContainer/VBoxContainer/PlayersQtd").text = "Players: %d/4" % players_qtd
		$VBoxContainer.add_child(server)
