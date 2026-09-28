class_name Mandacaru
extends Area2D

signal espetou_jogador

const ALTURA_VISUAL := 50.0
const TAMANHO_ESPINHOS := Vector2(12.0, 22.0)

var ativo := true

@onready var sprite: Sprite2D = $Sprite2D
@onready var espinhos: CollisionShape2D = $Espinhos


func _ready() -> void:
	sprite.scale = Vector2.ONE * (ALTURA_VISUAL / sprite.texture.get_height())
	sprite.position.y = -ALTURA_VISUAL / 2.0

	var retangulo = RectangleShape2D.new()
	retangulo.size = TAMANHO_ESPINHOS
	espinhos.shape = retangulo
	espinhos.position.y = -TAMANHO_ESPINHOS.y / 2.0


func plantar(x: float, chao_y: float) -> void:
	global_position = Vector2(x, chao_y)


func parar() -> void:
	ativo = false


func _physics_process(_delta: float) -> void:
	if ativo and has_overlapping_areas():
		espetou_jogador.emit()
