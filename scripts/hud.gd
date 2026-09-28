extends CanvasLayer

@onready var vidas_label: Label = $Painel/Linhas/Vidas
@onready var tempo_label: Label = $Painel/Linhas/Tempo
@onready var progresso: ProgressBar = $Painel/Linhas/Progresso
@onready var aviso_label: Label = $Aviso

var avisos_pendentes := 0


func _ready() -> void:
	aviso_label.visible = false


func mostrar_vidas(vidas: int) -> void:
	vidas_label.text = "Vidas: " + "❤️".repeat(vidas)


func mostrar_tempo(restante: float, total: float) -> void:
	var minutos = int(restante) / 60
	var segundos = int(restante) % 60
	tempo_label.text = "Amanhecer em %02d:%02d" % [minutos, segundos]
	progresso.value = 1.0 - restante / total


func mostrar_aviso(texto: String) -> void:
	aviso_label.text = texto
	aviso_label.visible = true
	avisos_pendentes += 1

	await get_tree().create_timer(2.5).timeout

	avisos_pendentes -= 1
	if avisos_pendentes == 0:
		aviso_label.visible = false
