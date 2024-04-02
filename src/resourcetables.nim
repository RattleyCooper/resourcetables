## Read files into a Table[string, string] at compile time for easy access.
## 
#

import std/[os, macros, tables, strutils, httpclient]

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

macro remote*(tableName: static[string], x: untyped): untyped =
  ## Create a block of remote filepaths and the files will get 
  ## downloaded into a table that's identified by the name 
  ## that was passed to `remote`.
  ## 
  ## Unlike embed, this is executed at runtime and includes
  ## features to aid with saving the files and 
  ## 
  ## Example:
  ## 
  ##    remote("data"):
  ##      # Store resulting data using the key "gF1bsWr.jpeg"
  ##      "https://i.imgur.com/gF1bsWr.jpeg"
  ## 
  ##      # Save resulting data to "new.jpeg"
  ##      "https://i.imgur.com/gF1bsWr.jpeg" -> "new.jpeg"
  ## 
  ##      # Use "new.jpeg" as the key in the `data` table
  ##      "https://i.imgur.com/gF1bsWr.jpeg" <- "new.jpeg"
  ## 
  ##      # Save data to "new.jpeg" and use "new.jpeg" as 
  ##      # the key in the `data` table.
  ##      "https://i.imgur.com/gF1bsWr.jpeg" <-> "new.jpeg"   
  ## 
  ##    discard data["gF1bsWr.jpeg"]
  ##    discard data["new.jpeg"]
  ## 

  result = newStmtList()
  var tableDef = newStmtList()
  let rdent = ident("r")
  let cdent = ident("c")
  tableDef.add quote do:
    var `cdent` = newHttpClient()
    var `rdent`: ResourceTable

  # Add static reads to table
  for l in x:
    if l.kind == nnkTripleStrLit:   
      tableDef.add quote do:
        `rdent`[`l`] = `cdent`.getContent(`l`)
    elif l.kind == nnkStrLit:
      tableDef.add quote do:
        var n = block:
          if `l`.contains("/"):
            `l`.split("/")[^1]
          else:
            `l`
        `rdent`[n] = `cdent`.getContent(`l`)
    elif l.kind == nnkInfix:
      let id = l[0] # ident ->
      let cl = l[1] # content link
      let mp = l[2] # secondary

      case $id
      of "<->":
        # Get the data and save it to the path, use filepath as key.
        tableDef.add quote do:
          var n = block:
            if `cl`.contains("/"):
              `cl`.split("/")[^1]
            else:
              `cl`
          var success = true
          try:
            `rdent`[`mp`] = `cdent`.getContent(`cl`)
          except:
            echo "Failed to download " & `cl`
            success = false
          if success:
            var f: File
            if not f.open(`mp`, fmWrite):
              echo "Couldn't open file for writing: " & `mp`
            f.write(`rdent`[`mp`])
            f.close()
      of "<-":
        # Get the data and rewrite the key in the table.
        tableDef.add quote do:
          var n = block:
            if `cl`.contains("/"):
              `cl`.split("/")[^1]
            else:
              `cl`
          var success = true
          try:
            `rdent`[`mp`] = `cdent`.getContent(`cl`)
          except:
            echo "Failed to download " & `cl`
            `rdent`[`mp`] = ""
      of "->":
        # Get the data and save it to the path.
        tableDef.add quote do:
          var n = block:
            if `cl`.contains("/"):
              `cl`.split("/")[^1]
            else:
              `cl`
          var success = true
          try:
            `rdent`[n] = `cdent`.getContent(`cl`)
          except:
            echo "Failed to download " & `cl`
            success = false
          if success:
            var f: File
            if not f.open(`mp`, fmWrite):
              echo "Couldn't open file for writing: " & `mp`
            f.write(`rdent`[n])
            f.close()
      else:
        echo $id, " is not a supported infix for `remote`."
        echo "Skipping " & $cl & " " & $id & " " & $mp
        discard

  tableDef.add quote do:  
    `cdent`.close()
  tableDef.add quote do:
    `rdent`

  let blockStmt = nnkBlockStmt.newTree(
    newEmptyNode(), tableDef
  )
  let constDef = nnkIdentDefs.newTree(
    ident(tableName), newEmptyNode(), blockStmt
  )
  result.add nnkVarSection.newTree(constDef)
  when defined(debug):
    echo result.repr

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
