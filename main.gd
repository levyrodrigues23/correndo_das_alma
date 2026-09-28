extends Node2D

const CENA_ALMA := preload("res://alma.tscn")
const CENA_MANDACARU := preload("res://mandacaru.tscn")
const FANTASMA := preload("res://almas/fantasma.tres")
const CRIATURAS_DO_CHAO := [
	preload("res://almas/burrinha.tres"),
	preload("res://almas/hilux_preta.tres"),
	preload("res://almas/perna_cabeluda.tres"),
	preload("res://almas/velho_do_saco.tres"),
]

const TEMPO_TOTAL := 90.0
const CHAO_Y := 487.0

const INTERVALO_ACELERAR := 15.0
const AUMENTO_POR_NIVEL := 0.15

const MOMENTOS_NOVA_CRIATURA := [70.0, 50.0, 28.0]

const QUANTIDADE_MANDACARUS := 2
const MANDACARU_X_MIN := 90.0
const MANDACARU_X_MAX := 1060.0
const DISTANCIA_DO_JOGADOR := 160.0
const DISTANCIA_DA_LAMPARINA := 110.0
const DISTANCIA_ENTRE_MANDACARUS := 200.0

const COR_NOITE := Color(0.7, 0.75, 1.0)
const COR_AMANHECER := Color(1.0, 0.9, 0.78)

@export var vidas: int = 3
@export var tempo_invencivel: float = 1.5

@onready var jogador: Jogador = $personagem_principal
@onready var lamparina: Lamparina = $luz
@onready var amanhecer: CanvasModulate = $Amanhecer
@onready var hud = $HUD
@onready var tela_fim = $Fim

var tempo_restante := TEMPO_TOTAL
var nivel_velocidade := 0
var pode_tomar_dano := true
var jogo_terminou := false

var almas: Array[Alma] = []
var mandacarus: Array[Mandacaru] = []
var criaturas_restantes: Array = []
var proxima_criatura := 0


func _ready() -> void:
	amanhecer.color = COR_NOITE
	lamparina.jogador_protegido.connect(_on_jogador_protegido)

	criar_mandacarus()

	criaturas_restantes = CRIATURAS_DO_CHAO.duplicate()
	criaturas_restantes.shuffle()
	criar_alma(FANTASMA)

	hud.mostrar_vidas(vidas)
	hud.mostrar_tempo(tempo_restante, TEMPO_TOTAL)


func criar_mandacarus() -> void:
	for i in range(QUANTIDADE_MANDACARUS):
		var mandacaru: Mandacaru = CENA_MANDACARU.instantiate()
		mandacaru.espetou_jogador.connect(tomar_dano)
		add_child(mandacaru)
		mandacarus.append(mandacaru)

	replantar_mandacarus()


func replantar_mandacarus() -> void:
	var ocupados: Array[float] = []

	for mandacaru in mandacarus:
		var x = sortear_lugar_livre(ocupados)
		ocupados.append(x)
		mandacaru.plantar(x, CHAO_Y)


func sortear_lugar_livre(ocupados: Array[float]) -> float:
	var x := MANDACARU_X_MIN

	for tentativa in range(40):
		x = randf_range(MANDACARU_X_MIN, MANDACARU_X_MAX)
		var livre = (
			abs(x - jogador.global_position.x) > DISTANCIA_DO_JOGADOR
			and abs(x - lamparina.x_na_tela()) > DISTANCIA_DA_LAMPARINA
		)
		for outro in ocupados:
			if abs(x - outro) < DISTANCIA_ENTRE_MANDACARUS:
				livre = false
		if livre:
			return x

	return x


func criar_alma(tipo: TipoAlma) -> void:
	var alma: Alma = CENA_ALMA.instantiate()
	alma.tipo = tipo
	alma.alvo = jogador
	alma.lamparina = lamparina
	alma.chao_y = CHAO_Y
	alma.multiplicador_velocidade = multiplicador_atual()
	alma.pegou_jogador.connect(tomar_dano)
	add_child(alma)
	almas.append(alma)


func multiplicador_atual() -> float:
	return 1.0 + nivel_velocidade * AUMENTO_POR_NIVEL


func _physics_process(delta: float) -> void:
	if jogo_terminou:
		return

	tempo_restante = max(tempo_restante - delta, 0.0)

	atualizar_noite()
	acelerar_almas()
	chamar_nova_criatura()

	if tempo_restante <= 0.0:
		vitoria()


func atualizar_noite() -> void:
	var progresso = 1.0 - tempo_restante / TEMPO_TOTAL
	hud.mostrar_tempo(tempo_restante, TEMPO_TOTAL)
	amanhecer.color = COR_NOITE.lerp(COR_AMANHECER, progresso * progresso)


func acelerar_almas() -> void:
	var nivel = int((TEMPO_TOTAL - tempo_restante) / INTERVALO_ACELERAR)
	if nivel <= nivel_velocidade:
		return

	nivel_velocidade = nivel
	for alma in almas:
		alma.multiplicador_velocidade = multiplicador_atual()

	hud.mostrar_aviso("As almas ficaram mais rápidas!")


func chamar_nova_criatura() -> void:
	if proxima_criatura >= MOMENTOS_NOVA_CRIATURA.size():
		return
	if tempo_restante > MOMENTOS_NOVA_CRIATURA[proxima_criatura]:
		return

	proxima_criatura += 1
	var tipo: TipoAlma = criaturas_restantes.pop_back()
	criar_alma(tipo)
	hud.mostrar_aviso(tipo.nome + " apareceu!")


func tomar_dano() -> void:
	if not pode_tomar_dano or jogo_terminou:
		return

	vidas -= 1
	hud.mostrar_vidas(vidas)

	if vidas <= 0:
		game_over()
		return

	pode_tomar_dano = false
	jogador.piscar()

	await get_tree().create_timer(tempo_invencivel).timeout

	pode_tomar_dano = true


func _on_jogador_protegido() -> void:
	for alma in almas:
		alma.espantar()

	replantar_mandacarus()


func parar_tudo() -> void:
	jogo_terminou = true
	jogador.parar()
	lamparina.apagar()

	for alma in almas:
		alma.parar()

	for mandacaru in mandacarus:
		mandacaru.parar()


func game_over() -> void:
	parar_tudo()
	tela_fim.mostrar("GAME OVER", "As almas te pegaram antes do sol nascer.")


func vitoria() -> void:
	parar_tudo()

	for alma in almas:
		alma.visible = false

	tela_fim.mostrar("AMANHECEU!", "O sol nasceu no sertão e as almas foram embora.")
