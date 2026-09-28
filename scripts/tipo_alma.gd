class_name TipoAlma
extends Resource

@export var nome: String = "Alma"
@export var textura: Texture2D
@export var largura_quadro: int = 32
@export var altura_quadro: int = 32
@export var linha_animacao: int = 0
@export var quadros: int = 4
@export var fps: float = 8.0
@export var escala: float = 3.0

@export var voa: bool = false
@export var velocidade: float = 150.0

@export var hitbox: Vector2 = Vector2(0.5, 0.5)
