
fs = require 'fs'

list = require './wordlist.json'

config = require './scconfig.json'

space = if config.space? then config.space else ''

isPathGood = (path)->
  if config.skipHidden and path.indexOf('./.') is 0 then return false
  if path.indexOf("node_modules") > -1 then return false
  if path.indexOf("output.csv") > -1 then return false
  if path.indexOf("wordlist.json") > -1 then return false
  if path.indexOf("spellcheck.js") > -1 then return false
  if path.indexOf("scconfig.json") > -1 then return false
  return true

buildWordList = ()->
  for word in list
    if config.skipUpto and word.Wrong.toLowerCase() is "upto" then continue
    if config.skipContractions and word.Correct.indexOf("'") isnt -1 then continue
    word.Single = word.Correct.indexOf('-') is -1
    word.CorrectFull = "#{space}#{word.Correct}#{space}"
    word.WrongFull = "#{space}#{word.Wrong}#{space}"

search = (path)->
  lpath = path.toLowerCase()

  if not isPathGood lpath then return

  data = fs.readFileSync path, config.encoding
  changed = false

  for word in list when word.Single
    if data.indexOf(word.WrongFull) isnt -1
      data = data.replace word.WrongFull, word.CorrectFull
      console.log "#{path} - #{word.Wrong} to #{word.Correct}"
      changed = true
  if changed
    fs.writeFileSync path, data, config.encoding
  return

buildWordList()

index = -1
for path in process.argv
  index += 1
  if index < 2 then continue
  if path.length < 2 then continue
  search "#{path}"
