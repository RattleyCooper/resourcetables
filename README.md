# resourcetables
 Super simple compile time embedded resources, and remote runtime resources. Useful if you're trying to ship an application and want to create an offline or online installer.

## Install

`nimble install https://github.com/RattleyCooper/resourcetables`

## Examples

```nim
import resourcetables

# Embed an entire directory at compile time
const assets = embed("asset-folder")
echo assets["some-file.txt"]

# Embed specific resources at compile time
embed("specificRes"):
  "another/file.txt"
  # use triple quoted string to retain full path
  """other/stuff.png"""  

# Access embedded resources
specificRes["file.txt]
specificRes["other/stuff.png]

# Fetch remote resources at runtime. 3 infix operators
# are available for saving data and/or rewriting keys.

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
