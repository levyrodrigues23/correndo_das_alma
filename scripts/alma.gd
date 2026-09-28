class_name Alma
extends Node2D

signal pegou_jogador

const FORA_ESQUERDA := -140.0
const FORA_DIREITA := 1292.0
const ALTURA_VOO_INICIAL := 400.0

@export var tipo: TipoAlma

var alvo: Node2D
var lamparina: Lamparina
var multiplicador_velocidade := 1.0
var chao_y := 487.0

var direcao := 1
var tempo_fora := 0.0
var ativa := true

@onready var sprite: AnimatedSprite2D = $Sprite
@onready var hitbox: Area2D = $Hitbox
@onready var forma: CollisionShape2D = $Hitbox/Forma


func _ready() -> void:
	sprite.sprite_frames = montar_animacao()
	sprite.scale = Vector2.ONE * tipo.escala
	sprite.play("andar")

	var tamanho_sprite = Vector2(tipo.largura_quadro, tipo.altura_quadro) * tipo.escala
	var retangulo = RectangleShape2D.new()
	retangulo.size = tamanho_sprite * tipo.hitbox
	forma.shape = retangulo

	if not tipo.voa:
		forma.position.y = (tamanho_sprite.y - retangulo.size.y) / 2.0

	entrar_em_cena()


func montar_animacao() -> SpriteFrames:
	var frames = SpriteFrames.new()
	frames.add_animation("andar")
	frames.set_animation_speed("andar", tipo.fps)
	frames.set_animation_loop("andar", true)

	for i in range(tipo.quadros):
		var quadro = AtlasTexture.new()
		quadro.atlas = tipo.textura
		quadro.region = Rect2(
			i * tipo.largura_quadro,
			tipo.linha_animacao * tipo.altura_quadro,
			tipo.largura_quadro,
			tipo.altura_quadro
		)
		frames.add_frame("andar", quadro)

	return frames


func altura_sprite() -> float:
	return tipo.altura_quadro * tipo.escala


func entrar_em_cena() -> void:
	var vem_da_esquerda = randi_range(0, 1) == 0
	if lamparina != null:
		vem_da_esquerda = lamparina.x_na_tela() > (FORA_ESQUERDA + FORA_DIREITA) / 2.0
	direcao = 1 if vem_da_esquerda else -1

	var x = FORA_ESQUERDA if vem_da_esquerda else FORA_DIREITA
	var y = ALTURA_VOO_INICIAL if tipo.voa else chao_y - altura_sprite() / 2.0

	global_position = Vector2(x, y)
	visible = true


func sair_de_cena() -> void:
	visible = false
	tempo_fora = randf_range(1.0, 2.5)


func espantar() -> void:
	if tipo.voa:
		entrar_em_cena()
	else:
		sair_de_cena()


func parar() -> void:
	ativa = false
	sprite.pause()


func _physics_process(delta: float) -> void:
	if not ativa or alvo == null:
		return

	if not visible:
		tempo_fora -= delta
		if tempo_fora <= 0.0:
			entrar_em_cena()
		return

	var velocidade = tipo.velocidade * multiplicador_velocidade
	var movimento: Vector2

	if tipo.voa:
		movimento = (alvo.global_position - global_position).normalized() * velocidade
	else:
		movimento = Vector2(direcao * velocidade, 0)

	global_position += movimento * delta

	if movimento.x != 0:
		sprite.flip_h = movimento.x < 0

	if not tipo.voa:
		var saiu = (
			(direcao > 0 and global_position.x > FORA_DIREITA)
			or (direcao < 0 and global_position.x < FORA_ESQUERDA)
		)
		if saiu:
			sair_de_cena()
			return

	if hitbox.has_overlapping_areas():
		pegou_jogador.emit()
