extends CharacterBody2D
class_name Wraith

var _is_dead: bool = false
var _player_ref = null # ref ao personagem principal
var _state_machine
var _is_attacking: bool = false
var _enemy_health: float = 3

@export_category("Objects")
@export var _animation_tree: AnimationTree = null

func _ready() -> void:
	_state_machine = _animation_tree["parameters/playback"]
	
func _physics_process(_delta: float) -> void:
	if _is_dead:
		return
	_animate()
	if _player_ref != null:
		var _direction: Vector2 = global_position.direction_to(_player_ref.global_position)
		var _distance:  float = global_position.distance_to(_player_ref.global_position)
		if _player_ref._is_dead:
			velocity = Vector2.ZERO
			move_and_slide()
			return
		_attack(_distance)
		_move(_direction, _distance)
		move_and_slide()

func _move(_direction: Vector2, _distance: float) -> void:
	if _direction != Vector2.ZERO:
		# dando um get nos parametros e atribuindo de acordo com a _direction
		_animation_tree["parameters/idle/blend_position"] = _direction
		_animation_tree["parameters/walk/blend_position"] = _direction
		_animation_tree["parameters/attack/blend_position"] = _direction
		velocity = _direction * 40
		return

func _attack(_distance) -> void:
	if _distance < 20 && _is_attacking:
		$WraithAttackFx.play()
		_is_attacking = true
		_player_ref.update_player_health()

func _animate() -> void:
	if _is_attacking:
		_state_machine.travel("attack")
		return
	if velocity.length() > 3:
		_state_machine.travel("walk")
		return
	_state_machine.travel("idle")
	
func update_enemy_health() -> void:
	_enemy_health -= 1
	if _enemy_health <= 0:
		kill_enemy()

func kill_enemy() -> void:
	$WraithDeathFx.play()
	_player_ref._enemies_left -= 1
	_is_dead = true
	_state_machine.travel("death")
	await get_tree().create_timer(1, 0).timeout
	queue_free()

func _on_detection_area_body_entered(_body) -> void:
	if _body.is_in_group("player"):
		_player_ref = _body
	

func _on_detection_area_body_exited(_body):
	if _body.is_in_group("player"):
		_player_ref = null

