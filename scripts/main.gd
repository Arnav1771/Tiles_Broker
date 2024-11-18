extends Control

const GRID_WIDTH: int = 20
const GRID_HEIGHT: int = 20
const BLOCK_SIZE: int = 100

var grid: Array[Array] = []
var block_color: Color = Color(1, 0, 0)  # Default block color (Red)
var color_index: int = 2  # To track the current color

# Predefined colors to cycle through when pressing "C"
var colors: Array = [
	Color(1, 0, 0),   # Red
	Color(0, 1, 0),   # Green
	Color(0, 0, 1),   # Blue
	Color(1, 1, 0),   # Yellow
	Color(1, 0.5, 0), # Orange
	Color(0.5, 0, 1), # Purple
	Color(0, 1, 1),   # Cyan
	Color(1, 0, 1),   # Magenta
	Color(0.5, 1, 0)  # Lime
]

@onready var game_area: ColorRect = $gameArea
@onready var grid_lines: Node2D = $gameArea/GridLines

var grid_position: Vector2

func _ready() -> void:
	# Initialize grid and other components
	add_to_group("main_scene")
	initialize_grid()
	draw_grid_lines()
	grid_position = game_area.position

# Initialize the grid with null values
func initialize_grid() -> void:
	for x in range(GRID_WIDTH):
		var column: Array[Variant] = []
		for y in range(GRID_HEIGHT):
			column.append(null)  # Empty grid
		grid.append(column)

# Draw the grid lines
func draw_grid_lines() -> void:
	for x in range(GRID_WIDTH + 1):
		var line: Line2D = Line2D.new()
		line.add_point(Vector2(x * BLOCK_SIZE, 0))
		line.add_point(Vector2(x * BLOCK_SIZE, GRID_HEIGHT * BLOCK_SIZE))
		line.width = 1
		line.default_color = Color.WHITE
		grid_lines.add_child(line)

	for y in range(GRID_HEIGHT + 1):
		var line: Line2D = Line2D.new()
		line.add_point(Vector2(0, y * BLOCK_SIZE))
		line.add_point(Vector2(GRID_WIDTH * BLOCK_SIZE, y * BLOCK_SIZE))
		line.width = 1
		line.default_color = Color.WHITE
		grid_lines.add_child(line)

# Draw the blocks (called every frame)
func _draw() -> void:
	for x in range(GRID_WIDTH):
		for y in range(GRID_HEIGHT):
			var block = grid[x][y]
			if block != null:
				draw_rect(Rect2(Vector2(x * BLOCK_SIZE, y * BLOCK_SIZE), Vector2(BLOCK_SIZE, BLOCK_SIZE)), block)

# Handle mouse clicks
func _input(event: InputEvent) -> void:
	# Handle mouse input
	if event is InputEventMouseButton and event.pressed:
		var mouse_pos = get_global_mouse_position()
		var relative_mouse_pos = mouse_pos - grid_position
		var grid_x = int(relative_mouse_pos.x / BLOCK_SIZE)
		var grid_y = int(relative_mouse_pos.y / BLOCK_SIZE)
		if grid_x >= 0 and grid_x < GRID_WIDTH and grid_y >= 0 and grid_y < GRID_HEIGHT:
			grid[grid_x][grid_y] = block_color  # Place block with current color
		queue_redraw()
		check_for_alignments()
	
	# Handle key input for "A" key press
	if event is InputEventKey:
		if event.pressed and event.scancode == KEY_A:  # Check if 'A' key is pressed
			change_block_color()

	# Check for "C" key press to cycle through colors
	if event is InputEventKey and event.pressed:
		if event.scancode == KEY_F:
			change_block_color()  # Change block color when "C" is pressed

# Function to cycle through colors when "C" key is pressed
func change_block_color() -> void:
	color_index = (color_index + 1) % colors.size()  # Cycle through colors
	block_color = colors[color_index]  # Update the block color
	print("Block color changed to: ", block_color)  # Optional: Debug output
	queue_redraw()  # Redraw the grid with the new color

# Function to check for alignments of 3-5 blocks of the same color
func check_for_alignments():
	# Horizontal and Vertical alignment checking
	for y in range(GRID_HEIGHT):
		var consecutive_blocks: Array = []
		for x in range(GRID_WIDTH):
			if grid[x][y] == block_color:
				consecutive_blocks.append(Vector2(x, y))
			else:
				if consecutive_blocks.size() >= 3 and consecutive_blocks.size() <= 5:
					remove_blocks(consecutive_blocks)
				consecutive_blocks.clear()
		if consecutive_blocks.size() >= 3 and consecutive_blocks.size() <= 5:
			remove_blocks(consecutive_blocks)

	for x in range(GRID_WIDTH):
		var consecutive_blocks: Array = []
		for y in range(GRID_HEIGHT):
			if grid[x][y] == block_color:
				consecutive_blocks.append(Vector2(x, y))
			else:
				if consecutive_blocks.size() >= 3 and consecutive_blocks.size() <= 5:
					remove_blocks(consecutive_blocks)
				consecutive_blocks.clear()
		if consecutive_blocks.size() >= 3 and consecutive_blocks.size() <= 5:
			remove_blocks(consecutive_blocks)

	# Check for diagonal alignments
	check_diagonal_alignments()

# Function to check for diagonal alignments
func check_diagonal_alignments() -> void:
	# Top-left to bottom-right diagonal
	for x in range(GRID_WIDTH):
		for y in range(GRID_HEIGHT):
			if grid[x][y] == block_color:
				var diagonal_blocks: Array = []
				var tx = x
				var ty = y
				while tx < GRID_WIDTH and ty < GRID_HEIGHT and grid[tx][ty] == block_color:
					diagonal_blocks.append(Vector2(tx, ty))
					tx += 1
					ty += 1
				if diagonal_blocks.size() >= 3 and diagonal_blocks.size() <= 5:
					remove_blocks(diagonal_blocks)

	# Top-right to bottom-left diagonal
	for x in range(GRID_WIDTH - 1, -1, -1):
		for y in range(GRID_HEIGHT):
			if grid[x][y] == block_color:
				var diagonal_blocks: Array = []
				var tx = x
				var ty = y
				while tx >= 0 and ty < GRID_HEIGHT and grid[tx][ty] == block_color:
					diagonal_blocks.append(Vector2(tx, ty))
					tx -= 1
					ty += 1
				if diagonal_blocks.size() >= 3 and diagonal_blocks.size() <= 5:
					remove_blocks(diagonal_blocks)

# Function to remove blocks from the grid
func remove_blocks(blocks: Array) -> void:
	for block_pos in blocks:
		grid[block_pos.x][block_pos.y] = null
	queue_redraw()  # Redraw after blocks are removed
