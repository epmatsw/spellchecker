
fs = require 'fs'

list = require './wordlist.json'

config = require './scconfig.json'

exec = require('child_process').exec

space = if config.space then ' ' else ''
localeRegex = if config.skipLocaleRegex then new RegExp('[a-z][a-z]-[A-Z][A-Z]', 'g') else null

isPathGood = (path)->
  if config.skipHidden and path.indexOf('./.') is 0 then return false
  if path.indexOf("node_modules") > -1 then return false
  if path.indexOf("output.csv") > -1 then return false
  if path.indexOf("wordlist.json") > -1 then return false
  if path.indexOf("spellcheck.js") > -1 then return false
  if path.indexOf("scconfig.json") > -1 then return false
  return true

passesLocaleChecks = (path)->
  if not config.skipLocale then return true

  if path.indexOf('local') > -1 then return false
  if path.indexOf('i18n') > -1 then return false
  if path.indexOf('national') > -1 then return false
  if config.skipLocaleRegex and path.indexOf(localeRegex) > -1 then return false
  return true

buildWordList = ()->
  for word in list
    if config.skipUpto and word.Wrong.toLowerCase() is "upto" then continue
    if config.skipContractions and word.Correct.indexOf("'") isnt -1 then continue
    if not config.lightMode then word.Regex = new RegExp "#{space}#{word.Wrong}#{space}", 'g'
    word.Output = "'#{word.Wrong}' should be '#{word.Correct}'"
    word.Single = word.Correct.indexOf('-') is -1
    word.CorrectFull = "#{space}#{word.Correct}#{space}"
    word.WrongFull = "#{space}#{word.Wrong}#{space}"

search = (path)->

  lpath = path.toLowerCase()

  if not isPathGood lpath then return
  if not passesLocaleChecks lpath then return

  data = fs.readFileSync path, config.encoding

  count = 0
  changed = false
  for word in list
    if word.Regex is undefined then continue
    added = (sdata.match(word.Regex) or []).length
    count += added
    if added > 0
      if word.Single and config.write
        data = data.replace word.Regex, word.CorrectFull
        changed = true
      if config.output
        console.log word.Output
  if count then console.log "#{path},#{count},#{count/sdata.length}"
  if config.write and changed then fs.writeFileSync path, data, config.encoding
  return

quickSearch = (path)->
  lpath = path.toLowerCase()

  if not isPathGood lpath then return
  if not passesLocaleChecks lpath then return

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
  if config.lightMode then quickSearch "#{path}" else search "#{path}"
