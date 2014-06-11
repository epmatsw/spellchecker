gfs = require 'graceful-fs'
fs = require 'fs'

list = require './wordlist.json'

config = require './scconfig.json'

space = if config.space then ' ' else ''
output = config.output
write = config.write
localeRegex = if config.skipLocaleRegex then new RegExp('[a-z][a-z]-[A-Z][A-Z]', 'g') else null

for word in list
  word.Regex = new RegExp "#{space}#{word.Wrong}#{space}", 'g'
  word.Output = "'#{word.Wrong}' should be '#{word.Correct}'"
  word.Single = word.Correct.indexOf('-') is -1
  word.CorrectFull = "#{space}#{word.Correct}#{space}"

process.argv.forEach (val, index, array)->

  path = "#{val}"
  lpath = path.toLowerCase()
  if index < 2 then done = true
  if config.skipHidden and lpath.indexOf('./.') is 0 then done = true
  if lpath.indexOf("node_modules") > -1 then done = true
  if lpath.indexOf("output.csv") > -1 then done = true
  if lpath.indexOf("wordlist.json") > -1 then done = true
  if lpath.indexOf("spellcheck.js") > -1 then done = true
  if lpath.indexOf("scconfig.json") > -1 then done = true
  if config.skipLocale
    if lpath.indexOf('local') > -1
      done = true
    else if lpath.indexOf('i18n') > -1
      done = true
    else if lpath.indexOf('national') > -1
      done = true
    else if config.skipLocaleRegex and lpath.indexOf(localeRegex) > -1
      done = true
  if not done
    data = fs.readFileSync path
    sdata = data.toString()
    sNewData = sdata

    count = 0
    changed = false
    for word in list
      added = (sdata.match(word.Regex) or []).length
      count += added
      if added > 0
        if word.Single and write
          sNewData = sNewData.replace word.Regex, word.CorrectFull
          changed = true
        if output
          console.log word.Output
    if count then console.log "#{path},#{count},#{count/sdata.length}"
    if write and changed then fs.writeFileSync(path, sNewData)
