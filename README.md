# resourcetables
 Super simple compile time embedded resources.  Made for handling assets for my website run with [mummy](https://github.com/guzba/mummy), since it wants resourcse available at compile time.

## Install

Download, unzip, navigate to the directory and run `nimble install`

## Examples

```nim
import resourcetables

# Embed an entire directory
const assets = embed("asset-folder")
echo assets["some-file.txt"]

# Embed specific files
const specificAssets = block:
  resources:
    "another/file.txt"
    "other/stuff.png"

specificAssets["another/file.txt]
```