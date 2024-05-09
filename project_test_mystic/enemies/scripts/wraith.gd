extends CharacterBody2D
class_name Wraith

var _is_dead: bool = false
var _player_ref = null # ref ao personagem principal
var _state_machine
var _is_attacking: bool = false
var _enemy_health: float = 3

@export_category("Objects")
@export var _texture: Sprite2D = null
@export var _animation: AnimationPlayer = null
@export var _animation_tree: AnimationTree = null

func _ready() -> void: # chamado quando o nó entra na árvore de cena pela primeira vez.
	_state_machine = _animation_tree["parameters/playback"] # a partir desse playback poderemos viajar entre o idle e walk
	
func _physics_process(_delta: float) -> void:
	if _is_dead:
		return
	_animate()
	if _player_ref != null:
		if _player_ref._is_dead:
			velocity = Vector2.ZERO
			move_and_slide()
			return
		_move()
		move_and_slide()

func _move() -> void:
	# retornando a direço entre o inimigo e o personagem - subtrai a posicao do inimigo e personagem, normalizando o vetor para retornar valores entre -1 e 1
	# os pontos em questao: posicao global do inimigo, posicao global personagem
	var _direction: Vector2 = global_position.direction_to(_player_ref.global_position)
	var _distance:  float = global_position.distance_to(_player_ref.global_position)
	if _distance < 20:
		_attack()
	if _direction != Vector2.ZERO:
		# dando um get nos parametros e atribuindo de acordo com a _direction
		_animation_tree["parameters/idle/blend_position"] = _direction
		_animation_tree["parameters/walk/blend_position"] = _direction
		_animation_tree["parameters/attack/blend_position"] = _direction
		velocity = _direction * 40
		return
	


func _attack() -> void:
	var _distance:  float = global_position.distance_to(_player_ref.global_position)
	if _distance < 20:
		if !_is_attacking:
			$WraithAttackFx.play()
		_is_attacking = true
		_player_ref.update_player_health() # caso queira decrementar a vida do player

func _animate() -> void:
	if _is_attacking:
		_state_machine.travel("attack")
		return
	if velocity.length() > 3:
		_state_machine.travel("walk")
		return
	_state_machine.travel("idle")
	

func update_enemy_health() -> void:
	_enemy_health -= 1 # caso queira decrementar a vida
	if _enemy_health <= 0:
	
		kill_enemy()

func kill_enemy() -> void:
	$WraithDeathFx.play()
	_is_dead = true
	_state_machine.travel("death")

func _on_detection_area_body_entered(_body) -> void:
	if _body.is_in_group("player"):
		_player_ref = _body
	

func _on_detection_area_body_exited(_body):
	if _body.is_in_group("player"):
		_player_ref = null


func _on_animation_finished(_anim_name: String) -> void:
	#if _anim_name == "right_death":
		#queue_free()
	#if _anim_name == "left_death":
		#queue_free()
	queue_free()
