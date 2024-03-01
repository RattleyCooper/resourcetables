## Read files into a Table[string, string] at compile time for easy access.
## 
#

import std/[os, macros, tables, strutils]

type 
  ResourceTable* = Table[string, string]

macro resources*(u: untyped): untyped =
  ## Embed resourcs into an executable and make them available in a 
  ## ResourceTable, which is just a Table[string, string]
  ## 
  ## example:
  ##   # This will embed the files at the filepaths in the code block
  ##   const assets: ResourceTable = block:
  ##     resources:
  ##       "assets/someImg.png"
  ##       "assets/icons/user.png"
  ##   
  ##   # Access them the same you would in a Table[string, string]
  ##   echo assets["assets/someImg.png"]
  ## 
  #
  var examine = newStmtList()

  # Create variable name we can reuse
  var pident = ident("pages")
  examine.add quote do:
    var `pident`: ResourceTable

  for l in u:
    var line = quote do:
      `pident`[`l`] = staticRead(`l`)
    examine.add(line)
  examine.add(quote do: `pident`)
  result = examine

proc embed*(directory: string): ResourceTable =
  ## Embed an entire directory into a ResourceTable.
  ## 
  ## example:
  ##   const assets: ResourceTable = embed("assets")
  ##   echo assets["assets/someImg.png"]
  #
  var pages: ResourceTable
  for fd in walkDir(directory):
    if fd.kind == pcFile:
      var p = fd.path.replace("\\", "/")
      pages[p] = staticRead(p)
  pages
