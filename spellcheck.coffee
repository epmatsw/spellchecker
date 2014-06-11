fs = require 'fs'

list = require './wordlist.json'

config = require './scconfig.json'

profiler = require 'v8-profiler'

dir = '.'

space = if config.space is 'no' then '' else ' '
output = false
write = true

for word in list
  word.Regex = new RegExp "#{space}#{word.Wrong}#{space}", 'g'
  word.Output = "Found '#{word.Wrong}'. Should be '#{word.Correct}'"
  word.Single = word.Correct.indexOf('-') is -1
  word.CorrectFull = "#{space}#{word.Correct}#{space}"

process.argv.forEach (val, index, array)->

  path = "#{val}"
  if index < 2 then done = true
  if path.indexOf('./.') is 0 then done = true
  if path.indexOf("node_modules") > -1 then done = true
  if path.indexOf("output.csv") > -1 then done = true
  if path.indexOf("wordlist.json") > -1 then done = true
  if path.indexOf("spellcheck.js") > -1 then done = true
  if not done
    fs.readFile path, (err, data)->
      if err then throw err
      sdata = data.toString()
      sNewData = sdata

      added = 0
      count = 0
      changed = false
      for word in list
        added = (sdata.match(word.Regex) or []).length
        if word.Single and write
          sNewData = sNewData.replace word.Regex, word.CorrectFull
          changed = true
        if added > 0
          count += added
          if output
            console.log word.Output
      if count then console.log "#{path},#{count},#{count/sdata.length}"
      if write and changed then fs.writeFile(path, sNewData)
