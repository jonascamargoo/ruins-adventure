extends CharacterBody2D

class_name Skeleton

#referência ao player
var _player_ref = null
#variável que confirma a morte
var _is_dead: bool = false
#variável que confirma se o inimigo está atacando
var _is_attacking: bool = false
#variável usada para a animation_tree do personagem
var _state_machine

#exportando os objetos (forma de conexão): 
@export_category("Objects")
@export var _texture: Sprite2D = null
@export var _animation_tree: AnimationTree = null
@export var _timer: Timer = null

#exportando as variáveis (uma outraforma de conexão):
@export_category("Variables")
@export var _health_enemy: int = 2

#função ready, primeira a ser chamada, 
#permitindo assim o bom funcionamento das animações
func _ready() -> void:
	_animation_tree.active = true
	_state_machine = _animation_tree["parameters/playback"]

#detecta quando o corpo do personagem entra na ColisionShape circular
func _on_detection_area_body_entered(_body) -> bool:
	if _body.is_in_group("player"):
		_player_ref = _body
		return true
	else:
		return false

#detecta quando o corpo do personagem sai na ColisionShape circular:
func _on_detection_area_body_exited(_body) -> void:
	if _body.is_in_group("player"):
		velocity = Vector2.ZERO
		_player_ref = null

#função onde ocorrem os processos, execuções, do inimigo:
func _physics_process(_delta: float) -> void:
	if _is_dead:
		return
	_animate()
	if _player_ref != null:
		if _player_ref._is_dead:
			velocity = Vector2.ZERO
			move_and_slide()
			return
		else:
			var _direction: Vector2 = global_position.direction_to(_player_ref.global_position)
			var _distance: float = global_position.distance_to(_player_ref.global_position)
			if _on_detection_area_body_entered(_player_ref):
				_move(_direction)
				if _distance < 25:
					_is_attacking = true
					_attack()

	else:
		velocity = Vector2.ZERO
		_animate()
	move_and_slide()

func _move(_direction: Vector2) -> void:
	velocity = _direction * 30
	if _direction != Vector2.ZERO:
		_animation_tree["parameters/idle/blend_position"] = _direction
		_animation_tree["parameters/walk/blend_position"] = _direction
		_animation_tree["parameters/attack/blend_position"] = _direction
		return 

func _attack() -> void:
	_timer.start()
	$skelly_attack.play()
	_state_machine.travel("attack")
	_player_ref.update_player_health()
	return

func _on_attack_timer_timeout() -> void:
	_is_attacking = false

func _animate() -> void:
	if _is_dead:
		$skelly_death.play()
		_state_machine.travel("death")
		await get_tree().create_timer(1.0).timeout
		queue_free()
	else:
		if velocity.length() > 1:
			_state_machine.travel("walk")
			return
		
	_state_machine.travel("idle")

func update_enemy_health() -> void:
	if _health_enemy <= 0:
		_is_dead = true
		_animate()
	else:
		_health_enemy -= 1
		print(_health_enemy)

func _on_attack_area_body_entered(_body)-> bool:
	if _player_ref.is_in_group("player"):
		_is_attacking = true
		
	return _is_attacking
