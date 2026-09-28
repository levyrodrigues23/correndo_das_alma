extends Control


@onready var botao_iniciar = $Centro/Iniciar

func _ready() -> void:
	botao_iniciar.grab_focus()

func _on_iniciar_pressed() -> void:
	get_tree().change_scene_to_file("res://main.tscn")
