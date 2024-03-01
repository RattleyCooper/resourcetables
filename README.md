# resourcetables
 Super simple compile time embedded resources.  Made for handling assets for my website run with [mummy](https://github.com/guzba/mummy), since it wants resourcse available at compile time.

## Install

Download, unzip, navigate to the src directory and copy the `resourcetables.nim` file into your project.  For some reason the macros can't open files when the script is imported from a different directory.

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

## Example using with Mummy

```nim
import mummy, mummy/routers
import resourcetables

# Embeds all assets located in folder named "assets"
const assets: ResourceTable = embed("assets")

proc assetHandler(request: Request) =
  ## Serve assets for your web page.
  #
  var headers: HttpHeaders

  var fileEnding = request.pathParams["assetName"].split(".")[^1]
  case fileEnding:
  of "png":
    headers["Content-Type"] = "image/png"
  of "jpg", "jpeg":
    headers["Content-Type"] = "image/jpeg"
  of "gif":
    headers["Content-Type"] = "image/gif"

  var aname = "assets/" & request.pathParams["assetName"]
  request.respond(200, headers, assets[aname])

var router: Router
router.get("/assets/@assetName", assetHandler)
# In your HTML you would use src="/assets/someimg.png"
# for an asset named someimg.png located in the assets folder

let server = newServer(router)
echo "Serving on http://127.0.0.1:8080"
server.serve(Port(8080), "127.0.0.1")
```
