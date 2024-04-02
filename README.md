# resourcetables
 Super simple compile time embedded resources, and remote runtime resources.

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

# Fetch remote resources at runtime. 3 infix operators
# are available for saving data and rewriting keys.

remote("online"):
  # Store resulting data using the key "gF1bsWr.jpeg"
  "https://i.imgur.com/gF1bsWr.jpeg"

  # Save resulting data to "new.jpeg"
  "https://i.imgur.com/gF1bsWr.jpeg" -> "new.jpeg"

  # Use "new.jpeg" as the key in the `online` table
  "https://i.imgur.com/gF1bsWr.jpeg" <- "new.jpeg"

  # Save data to "new.jpeg" and use "new.jpeg" as 
  # the key in the `online` table.
  "https://i.imgur.com/gF1bsWr.jpeg" <-> "new.jpeg"   
```
