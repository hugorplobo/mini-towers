extends Control

signal try_connect(ip)

func _on_Button_button_up():
	emit_signal("try_connect", $HBoxContainer/VBoxContainer/Ip.text)
