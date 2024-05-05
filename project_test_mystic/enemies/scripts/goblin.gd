extends CharacterBody2D
class_name Goblin


var _player_ref = null # ref ao personagem principal


@export_category("Objects")
@export var _texture: Sprite2D = null
@export var _animation: AnimationPlayer = null



func _on_detection_area_body_entered(_body) -> void:
	if _body.is_in_group("player"):
		_player_ref = _body
		
	

# saindo da area de deteccao do inimigo
func _on_detection_area_body_exited(_body) -> void:
	if _body.is_in_group("player"):
		_player_ref = null
		
func _physics_process(_delta: float) -> void:
	if _player_ref != null:
		# retornando a direço entre o inimigo e o personagem - subtrai a posicao do inimigo e personagem, normalizando o vetor para retornar valores entre -1 e 1
		# os pontos em questao: posicao global do inimigo, posicao global personagem
		var _direction: Vector2 = global_position.direction_to(_player_ref.global_position)
		velocity = _direction * 40
		move_and_slide()
