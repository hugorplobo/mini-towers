extends Control

var lobby = preload("res://scenes/lobby/Lobby.tscn")
var servers = preload("res://scenes/servers/Servers.tscn")

func _on_ServerButton_button_up():
	get_tree().change_scene_to(lobby)
	NetworkServer.start_server()

func _on_ConnectButton_button_up():
	get_tree().change_scene_to(servers)
