## Read files into a Table[string, string] at compile time for easy access.
## 
#

import std/[os, macros, tables, strutils]

type 
  ResourceTable* = Table[string, string]

macro embed*(tableName: static[string], x: untyped): untyped =
  ## Create a block of filepaths and the files will get embedded 
  ## into the executable in a table that's identified by the name 
  ## that was passed to `embed`. Use triple quoted strings to
  ## retain the full path in the resulting ResourceTable.
  ## 
  ## Example:
  ## 
  ##    embed("data"):
  ##      "C:/somefile.txt"
  ##      """C:/otherfile.txt"""
  ##    
  ##    discard data["somefile.txt"]
  ##    discard data["C:/otherfile.txt"]
  ## 

  result = newStmtList()
  var tableDef = newStmtList()
  let rdent = ident("r")
  tableDef.add quote do:
    var `rdent`: ResourceTable

  # Add static reads to table
  for l in x:
    if l.kind == nnkTripleStrLit:   
      tableDef.add quote do:
        `rdent`[`l`] = staticRead(`l`)
    elif l.kind == nnkStrLit:
      tableDef.add quote do:
        var n = block:
          if `l`.contains("/"):
            `l`.split("/")[^1]
          elif `l`.contains("\\"):
            `l`.split("\\")[^1]
          else:
            `l`
        `rdent`[n] = staticRead(`l`)
  tableDef.add quote do:
    `rdent`

  let blockStmt = nnkBlockStmt.newTree(
    newEmptyNode(), tableDef
  )
  let constDef = nnkConstDef.newTree(
    ident(tableName), newEmptyNode(), blockStmt
  )
  result.add nnkConstSection.newTree(constDef)
  when defined(debug):
    echo result.repr

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
  when defined(debug):
    echo pages.repr      
  pages


macro resources*(u: untyped): untyped =
  ## Deprecated. Use embed(tableName):
  ## 
  ## Embed resources into an executable and make them available in a 
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
  when defined(debug):
    echo examine.repr
  examine
