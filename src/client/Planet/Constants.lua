local Constants = {}

Constants.Planet = { --most of these will come from seed or another source
	MAX_MESH_SIZE = 2048 * 0.98,
	RADIUS = 5000,
	RESOLUTION = 32,
	CENTER = Vector3.zero,
	CHUNK_HYSTERESIS = 0.05,
}

Constants.GRAVITY_ACCELERATION = 500

Constants.Movement = {
	MAX_SPEED = 20,
	SPRINT_SPEED = 100,

	GROUND_ACCELERATION = 800,
	AIR_ACCELERATION = 20,

	JUMP_FORCE = 80,
	TURN_SPEED = math.rad(540),

	MIN_RAY_DISTANCE = 3,
}

Constants.Camera = {
	SENSITIVITY = 0.003,

	MIN_DISTANCE = 5,
	MAX_DISTANCE = 1000, -- 30,

	MIN_PITCH = math.rad(-70),
	MAX_PITCH = math.rad(70),

	ZOOM_SPEED = 2,
	MIN_ZOOM_SPEED = 0.5,
	MAX_ZOOM_SPEED = 3,

	RADIUS = 0.5,
	COLLISION_PADDING = 0.1,
}

Constants.Settings = {
	Keybinds = {},
	Camera = {
		Sensitivity = 0.003,
		PitchInversion = false,
		YawInversion = false,
	},
}

Constants.Faces = {
	["+X"] = {
		Name = "+X",
		Normal = Vector3.new(1, 0, 0),
		Right = Vector3.new(0, 0, -1),
		Up = Vector3.new(0, 1, 0),
	},

	["-X"] = {
		Name = "-X",
		Normal = Vector3.new(-1, 0, 0),
		Right = Vector3.new(0, 0, 1),
		Up = Vector3.new(0, 1, 0),
	},

	["+Y"] = {
		Name = "+Y",
		Normal = Vector3.new(0, 1, 0),
		Right = Vector3.new(1, 0, 0),
		Up = Vector3.new(0, 0, -1),
	},

	["-Y"] = {
		Name = "-Y",
		Normal = Vector3.new(0, -1, 0),
		Right = Vector3.new(1, 0, 0),
		Up = Vector3.new(0, 0, 1),
	},

	["+Z"] = {
		Name = "+Z",
		Normal = Vector3.new(0, 0, 1),
		Right = Vector3.new(1, 0, 0),
		Up = Vector3.new(0, 1, 0),
	},

	["-Z"] = {
		Name = "-Z",
		Normal = Vector3.new(0, 0, -1),
		Right = Vector3.new(-1, 0, 0),
		Up = Vector3.new(0, 1, 0),
	},
}

return Constants
