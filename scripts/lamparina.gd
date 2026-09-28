class_name Lamparina
extends Area2D

signal jogador_protegido

const LARGURA_CENARIO := 1152.0
const MARGEM := 60.0

@onready var sprite: Sprite2D = $Sprite2D


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func x_na_tela() -> float:
	return sprite.global_position.x


func mudar_de_lugar() -> void:
	var novo_x = randf_range(MARGEM, LARGURA_CENARIO - MARGEM)
	global_position.x = novo_x - sprite.position.x


func apagar() -> void:
	set_deferred("monitoring", false)


func _on_body_entered(body: Node2D) -> void:
	if body is Jogador:
		mudar_de_lugar()
		jogador_protegido.emit()
