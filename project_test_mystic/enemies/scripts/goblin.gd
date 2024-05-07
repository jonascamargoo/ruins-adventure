extends CharacterBody2D
class_name Goblin

var _is_dead: bool = false
var _player_ref = null # ref ao personagem principal
var _state_machine
var _is_attacking: bool = false

@export_category("Objects")
@export var _texture: Sprite2D = null
@export var _animation: AnimationPlayer = null
@export var _attack_timer: Timer = null
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
	#if _distance < 20:
		#_player_ref.die()
	if _direction != Vector2.ZERO:
		# dando um get nos parametros e atribuindo de acordo com a _direction
		_animation_tree["parameters/idle/blend_position"] = _direction
		_animation_tree["parameters/walk/blend_position"] = _direction
		_animation_tree["parameters/attack/blend_position"] = _direction
		velocity = _direction * 40
		return
	

func _on_detection_area_body_entered(_body) -> void:
	if _body.is_in_group("player"):
		_player_ref = _body
		
	
# saindo da area de deteccao do inimigo
func _on_detection_area_body_exited(_body) -> void:
	if _body.is_in_group("player"):
		_player_ref = null
		
func _attack() -> void:
	var _distance:  float = global_position.distance_to(_player_ref.global_position)
	if _distance < 20:
		_is_attacking = true # para ele parar de andar enquanto ataca
		set_physics_process(false)
		_attack_timer.start()
		_is_attacking = true

func _animate() -> void:
	if _is_attacking:
		_state_machine.travel("attack")
		return
	if velocity.length() > 3:
		_state_machine.travel("walk")
		return
	_state_machine.travel("idle")
	

func _on_animation_finished(_anim_name: String) -> void:
	# so funciona para animations que nao estao em loop mode
	# quando a animacao de morte acabar, todas as refs sobre esse inimigo sumiram
	if _anim_name == "death":
		queue_free()

func update_health() -> void:
	_is_dead = true

func die() -> void:
	_is_dead = true
	_state_machine.travel("death")

func _on_attack_timer_timeout():
	set_physics_process(true) # voltar a andar enquanto ataca
	_is_attacking = false
