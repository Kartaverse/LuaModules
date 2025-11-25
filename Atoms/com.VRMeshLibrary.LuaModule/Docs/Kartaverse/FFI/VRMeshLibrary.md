# SGO VR Mesh Library Lua Module

This Lua module provides bindings for the SGO VR Mesh Library, allowing you to read and write VR Mesh files (`.vrmesh`) using LuaJIT.

## Installation

1.  **Dependencies**: Ensure you have LuaJIT installed.
2.  **Files**: You need the `vrmesh.lua` file and the compiled shared library `vrmesh_ffi.so`.
3.  **Placement**: Place both files in the same directory, or ensure `vrmesh.lua` is in your `package.path` and `vrmesh_ffi.so` is in the same directory as `vrmesh.lua`.

## Usage

```lua
local vrmesh = require("vrmesh")

-- Create a new instance
local meshFile = vrmesh.new()

-- Open a file for reading
local res = meshFile:openRead("example.vrmesh", vrmesh.FLAG_GENERATEMISSINGINDEX)
if res == vrmesh.NOERROR then
    -- ... process file ...
end

-- Close and destroy
meshFile:close()
meshFile:destroy()
```

## API Reference

### Constants

*   `vrmesh.NOERROR`: Operation successful (0)
*   `vrmesh.ERROR_FILENOTFOUND`: File not found (-1)
*   `vrmesh.FLAG_GENERATEMISSINGINDEX`: Flag to generate index if missing (1)
*   ... (See `vrmesh.lua` for full list of error codes)

### Methods

#### `vrmesh.new()`
Creates a new MeshFile instance.
*   **Returns**: A new `MeshFile` object.

#### `MeshFile:destroy()`
Destroys the MeshFile instance and frees resources.

#### `MeshFile:openRead(filename, flags)`
Opens a VR Mesh file for reading.
*   `filename`: Path to the .vrmesh file.
*   `flags`: Open flags (e.g., `vrmesh.FLAG_GENERATEMISSINGINDEX`).
*   **Returns**: Result code (0 for success).

#### `MeshFile:openWrite(filename, tracks, flags)`
Opens a VR Mesh file for writing.
*   `filename`: Path to the .vrmesh file.
*   `tracks`: Number of tracks.
*   `flags`: Open flags.
*   **Returns**: Result code.

#### `MeshFile:close()`
Closes the currently open file.
*   **Returns**: Result code.

#### `MeshFile:getFileHeader()`
Retrieves the file header information.
*   **Returns**: A table containing header fields (`tracks`, `frame_start`, `frame_end`, etc.) or `nil` on error.

#### `MeshFile:getMeshInfo(track, frame)`
Retrieves information about a mesh at a specific track and frame.
*   `track`: Track index.
*   `frame`: Frame number.
*   **Returns**: A table containing mesh info (`frameStart`, `frameEnd`, `size`, `fileOffset`) or `nil` on error.

#### `MeshFile:readMeshData(fileOffset, bufferSize)`
Reads the actual mesh data from the file.
*   `fileOffset`: Offset obtained from `getMeshInfo`.
*   `bufferSize`: Size obtained from `getMeshInfo`.
*   **Returns**: A table containing mesh data (`format`, `grid_x`, `grid_y`, `data_size`, `mesh_data`) and the actual read size, or `nil` on error.

#### `MeshFile:addMesh(track, frameStart, frameEnd, format, grid_x, grid_y, meshDataStr)`
Adds a mesh to the file (when opened for writing).
*   `track`: Track index.
*   `frameStart`: Start frame.
*   `frameEnd`: End frame.
*   `format`: Mesh format.
*   `grid_x`: Grid X dimension.
*   `grid_y`: Grid Y dimension.
*   `meshDataStr`: Binary string containing the mesh data.
*   **Returns**: Result code.

#### `MeshFile:setTimeData(frameTime, frameScale)`
Sets the time data for the file.
*   `frameTime`: Frame duration.
*   `frameScale`: Time scale.
*   **Returns**: Result code.