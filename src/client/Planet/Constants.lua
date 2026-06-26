local Constants = {}

Constants.MAX_MESH_SIZE = 2048 * 0.98
Constants.RADIUS = 5000
Constants.RESOLUTION = 32
Constants.PLANET_CENTER = Vector3.zero
Constants.ChunksPerFace = 16

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
