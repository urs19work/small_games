extends Sprite2D

@export var max_rotation_speed = 25.7       # Максимальная скорость вращения
@export var min_rotation_speed = 5.5        # Минимальная скорость вращения
@export var max_friction = 0.991            # Максимально возможный коэффициент замедления вращения
@export var min_friction = 0.981            # Минимально возможный коэффициент замедления вращения

var friction_coefficient                     # Коэффициент замедления вращения

var touch_start_position = Vector2.ZERO      # Начало касания
var touch_end_position = Vector2.ZERO        # Конечная позиция касания
var current_rotation_speed = 0               # Текущая скорость вращения
var last_touch_time = 0                      # Время начала касания
var rotating = false                         # Флаг вращения

var sectors_count = 8                        # Количество секторов на барабане
var spin_sign = 1                            # В какую сторону вращается барабан (по ЧС / против ЧС)

func _ready():
	set_process_input(true)                  # Включаем обработку событий ввода

func _input(event):
	if event is InputEventMouseButton:       # проверяем что нажата кнопка мыши
		if event.pressed:
			handle_touch_start(event.position)           # если ЛКМ нажата, обрабатываем нажатие
		elif event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:   # Левая кнопка мыши отпущена
			handle_touch_release()                       # если ЛКМ не нажата, обрабатываем отпускание ЛКМ

	elif event is InputEventScreenTouch:              # проверяем что есть касание тачскрина
		if event.pressed:
			handle_touch_start(event.position)         # если палец касается тачскрина, обрабатываем нажатие
		elif not event.pressed:                        # Палец убран от экрана отпущено
			handle_touch_release()
	elif event is InputEventMouseMotion or event is InputEventScreenDrag:
		touch_end_position = event.position           # фиксируем позицию в которой находится палец / указатель мыши

# обработка нажатия кнопки мыши / пальца на экран
func handle_touch_start(pos):
	touch_start_position = pos                    # сохраняем параметры начала перемещения указателя / пальца
	last_touch_time = Time.get_ticks_msec()

# обработка отпускание кнопки мыши / пальца от экрана
func handle_touch_release():
	var distance = touch_start_position.distance_to(touch_end_position)
	var speed = clamp(max_rotation_speed * (distance / 750), min_rotation_speed, max_rotation_speed)
	# код расчета силы вращения барабана запустится только если барабан не вращается.
	if rotating == false:
		# включаем вращение барабана в зависимости от скорости и расстояния перемещения указателя / пальца
		spin_sign = sign(touch_start_position.normalized().angle_to(touch_end_position.normalized()))
		current_rotation_speed = speed * spin_sign
		rotating = true
		friction_coefficient = randf_range(min_friction, max_friction)

# Замедление
func slow_down():
	if rotating == true:
		current_rotation_speed *= friction_coefficient
		if abs(current_rotation_speed) < 0.1:
			rotating = false

# Основной игровой цикл
func _process(delta):
	if rotating:
		rotate(current_rotation_speed * delta)
		slow_down()
