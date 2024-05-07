extends CharacterBody2D
class_name Goblin


var _player_ref = null # ref ao personagem principal
var _state_machine
var _is_attacking: bool = false

@export_category("Objects")
@export var _texture: Sprite2D = null
@export var _animation: AnimationPlayer = null
@export var _attack_timer: Timer = null
@export var _animation_tree: AnimationTree = null

#func _ready() -> void: # chamado quando o nó entra na árvore de cena pela primeira vez.
	##_animation_tree.active = true # para ativar a animationTree, caso tenhamos esquecido de reativar ao editar alguma animation
	#_state_machine = _animation_tree["parameters/playback"] # a partir desse playback poderemos viajar entre o idle e walk
	
func _physics_process(_delta: float) -> void:
	#_animate()
	if _player_ref != null:
		# retornando a direço entre o inimigo e o personagem - subtrai a posicao do inimigo e personagem, normalizando o vetor para retornar valores entre -1 e 1
		# os pontos em questao: posicao global do inimigo, posicao global personagem
		var _direction: Vector2 = global_position.direction_to(_player_ref.global_position)
		velocity = _direction * 40
		move_and_slide()

func _on_detection_area_body_entered(_body) -> void:
	if _body.is_in_group("player"):
		_player_ref = _body
		
	

# saindo da area de deteccao do inimigo
func _on_detection_area_body_exited(_body) -> void:
	if _body.is_in_group("player"):
		_player_ref = null
		


#func _animate() -> void:
	#if velocity != Vector2.ZERO:
		#if velocity.x > 0:
			#_animation.play("right_walk")
		#if velocity.x < 0:
			#_animation.play("left_walk")
	
	#if velocity != Vector2.ZERO:
		#_animation.play("walk")
		#return
	#_animation.play("idle")
