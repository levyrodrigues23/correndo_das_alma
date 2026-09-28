extends CanvasLayer

@onready var titulo: Label = $Painel/Linhas/Titulo
@onready var mensagem: Label = $Painel/Linhas/Mensagem
@onready var botao_jogar_de_novo: Button = $Painel/Linhas/JogarDeNovo


func _ready() -> void:
	visible = false


func mostrar(texto_titulo: String, texto_mensagem: String) -> void:
	titulo.text = texto_titulo
	mensagem.text = texto_mensagem
	visible = true
	botao_jogar_de_novo.grab_focus()


func _on_jogar_de_novo_pressed() -> void:
	get_tree().reload_current_scene()


func _on_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://menu.tscn")
