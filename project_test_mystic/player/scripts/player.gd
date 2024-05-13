extends CharacterBody2D

class_name Player
const MAX_HEALTH = 1200
const MAX_ENEMIES = 10
var _state_machine
var _is_dead: bool = false
var _is_attacking: bool = false
var _player_health: float = MAX_HEALTH
var _enemies_left: int = MAX_ENEMIES
var _place = 0 # o place 0 eh a caverna principal, 1 a taberna e 2 a floresta

@export_category("Variables")
@export var _move_speed: float = 64.0
@export var _friction: float = 0.2 # significa que vai demorar mais tempo para retornar ao 0
@export var _acceleration: float = 0.4 # significa que vai demorar mais tempo para acelerar


# Quando crio uma categoria, ela aparece no canto direito da dela, junto com seus respectivos objetos
@export_category("Objects")
@export var _attack_timer: Timer = null
@export var _animation_tree: AnimationTree = null

func _ready() -> void: # chamado quando o nó entra na árvore de cena pela primeira vez.
	_animation_tree.active = true # para ativar a animationTree, caso tenhamos esquecido de reativar ao editar alguma animation
	_state_machine = _animation_tree["parameters/playback"] # a partir desse playback poderemos viajar entre o idle e walk
	$StartedFx.play()
	update_health_ui()
	update_enemies_left()
	

# o delta eh o intervalo de tempo entre um frame e o outro, a funcao eh chamada a cada delta
func _physics_process(_delta: float) -> void:
	_is_finished()
	if _is_dead:
		return
	_move()
	_attack()
	_animate()
	move_and_slide()

func _move() -> void:
	var _direction: Vector2 = Vector2(
		Input.get_axis("move_left", "move_right"),
		Input.get_axis("move_up", "move_down")
	)
	
	# verificando se o botao nao esta sendo pressionado
	if _direction != Vector2.ZERO:
		# dando um get nos parametros e atribuindo de acordo com a _direction
		_animation_tree["parameters/idle/blend_position"] = _direction
		_animation_tree["parameters/walk/blend_position"] = _direction
		_animation_tree["parameters/attack/blend_position"] = _direction
		
		velocity.x = lerp(velocity.x, _direction.normalized().x * _move_speed, _acceleration)
		velocity.y = lerp(velocity.y, _direction.normalized().y * _move_speed, _acceleration)
		return
	
	velocity.x = lerp(velocity.x, _direction.normalized().x * _move_speed, _friction)
	velocity.y = lerp(velocity.y, _direction.normalized().y * _move_speed, _friction)

func _attack() -> void:
	## se o botao de ataque for pressionado e nao tiver nenhum ataque em andamento
	if Input.is_action_just_pressed("attack") and not _is_attacking:
		$PlayerAttackFx.play()
		set_physics_process(false) # para ele parar de andar enquanto ataca
		_attack_timer.start()
		_is_attacking = true

func _animate() -> void:
	if _is_attacking:
		_state_machine.travel("attack")
		return
		
	# verificando se o personagem ta em movimento
	if velocity.length() > 3:
		_state_machine.travel("walk")
		return
	_state_machine.travel("idle")


# Quando o timer zerar, ele dispara um sinal. Esse sinal é representado por essa função
# Ao zerar, essa função é chamada
func _on_attack_timer_timeout() -> void:
	set_physics_process(true) # voltar a andar enquanto ataca
	_is_attacking = false

func _on_attack_area_body_entered(_body) -> void:
	# se o corpo em questao for do tipo inimigo
	if _body.is_in_group("enemy"):
		_body.update_enemy_health()

# cada hit do inimigo decrementa a vida do player. Posteriormente fazer isso com os inimigos
func update_player_health() -> void:
	_player_health -= 1
	if _player_health <= 0:
		kill_player()
	update_health_ui()

func _is_finished() -> void:
	update_enemies_left()
	if _enemies_left == 0:
		await get_tree().create_timer(2, 0).timeout
		get_tree().change_scene_to_file("res://menu/title_screen.tscn")

	
func update_health_ui() -> void:
	$HealthLabel.text = "Health: %s" % _player_health
	$HealthBar.max_value = MAX_HEALTH
	$HealthBar.value = _player_health
	
func update_enemies_left() -> void:
	$EnemiesLeft.text =  "Enemies left: %s" % _enemies_left

func kill_player() -> void:
	_is_dead = true
	_state_machine.travel("death")
	$PlayerDeathFx.play()
	# utilizando corrotinas para reiniciar o level após morte do player
	await get_tree().create_timer(1, 0).timeout
	get_tree().reload_current_scene()
