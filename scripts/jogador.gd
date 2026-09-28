class_name Jogador
extends CharacterBody2D

const LARGURA_CENARIO := 1152.0
const MARGEM_TELA := 30.0

@export var velocidade: float = 140.0
@export var forca_pulo: float = -720.0
@export var multiplicador_gravidade: float = 2.2

var ativo := true

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D


func _physics_process(delta: float) -> void:
	if not ativo:
		return

	if not is_on_floor():
		velocity += get_gravity() * multiplicador_gravidade * delta

	var direcao = Input.get_axis("walk_left", "walk_right")
	velocity.x = direcao * velocidade

	if direcao != 0:
		sprite.flip_h = direcao < 0

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = forca_pulo
		tocar("jump")
	elif is_on_floor():
		tocar("walk" if direcao != 0 else "idle")

	move_and_slide()

	global_position.x = clamp(global_position.x, MARGEM_TELA, LARGURA_CENARIO - MARGEM_TELA)


func tocar(animacao: String) -> void:
	if sprite.sprite_frames.has_animation(animacao):
		sprite.play(animacao)


func piscar() -> void:
	var tween = create_tween().set_loops(5)
	tween.tween_property(sprite, "modulate:a", 0.25, 0.15)
	tween.tween_property(sprite, "modulate:a", 1.0, 0.15)


func parar() -> void:
	ativo = false
	velocity = Vector2.ZERO
	tocar("idle")
	sprite.modulate.a = 1.0
