# resourcetables
 Super simple compile time embedded resources.

## Install

Download, unzip, navigate to the src directory and copy the `resourcetables.nim` file into your project.  For some reason the macros can't open files when the script is imported from a different directory.

## Examples

```nim
import resourcetables

# Embed an entire directory
const assets = embed("asset-folder")
echo assets["some-file.txt"]

# Embed specific resources
embed("specificRes"):
  "another/file.txt"
  # use triple quoted string to retain full path
  """other/stuff.png"""  

# Access resources
specificRes["file.txt]
specificRes["other/stuff.png]

```
