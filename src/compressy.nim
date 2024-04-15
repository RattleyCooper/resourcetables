import zippy
import parseopt


proc validateValue(value: string, msg: string) =
  if value == "":
    echo msg
    quit QuitFailure


var p = initOptParser()
while true:
  p.next()
  case p.kind
  of cmdEnd: break
  of cmdShortOption, cmdLongOption:
    case p.key:
    of "compress", "c":
      p.val.validateValue("Supply a file to compress with --compress:/path/to/file")
      var f: File
      if not f.open(p.val, fmRead):
        echo "Could not read ", p.val
        quit QuitFailure
      stdout.writeLine f.readAll().compress()
    of "uncompress", "u":
      p.val.validateValue("Supply a file to uncompress with --uncompress:/path/to/file")
      var f: File
      if not f.open(p.val, fmRead):
        echo "Could not read ", p.val
        quit QuitFailure
      stdout.writeLine f.readAll().compress()
    else:
      echo """Compressy can compress/uncompress files.
      """
  else: discard
