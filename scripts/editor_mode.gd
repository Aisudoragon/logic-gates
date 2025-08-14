class_name EditorMode

enum Mode {
	SELECT,
	WIRE,
	GATE,
}

enum Gate {
	NOT,
	AND,
	NAND,
	OR,
	NOR,
	XOR,
	XNOR,
	STARTSTOP,
}

enum Direction {
	RIGHT = 1,
	DOWN = 2,
	LEFT = 4,
	UP = 8,
}
