version         = "0.1.0"
author          = "RattleyCooper"
description     = "Super simple embedded resources at compile time (with compression)."
license         = "MIT"
srcDir          = "src"

requires "nim >= 2.0.0"
requires "zippy >= 0.10.12"

bin = @["compressy"]
