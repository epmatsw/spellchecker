fs = require 'fs'

list = require './wordlist.json'

config = require './scconfig.json'

space = if config.space then ' ' else ''
output = config.output
write = config.write
localeRegex = if config.skipLocaleRegex then new RegExp('[a-z][a-z]-[A-Z][A-Z]', 'g') else null
skipUpto = config.skipUpto
skipContractions = config.skipContractions

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
    if skipUpto and word.Wrong.toLowerCase() is "upto" then continue
    if skipContractions and word.Correct.indexOf("'") isnt -1 then continue
    word.Regex = new RegExp "#{space}#{word.Wrong}#{space}", 'g'
    word.Output = "'#{word.Wrong}' should be '#{word.Correct}'"
    word.Single = word.Correct.indexOf('-') is -1
    word.CorrectFull = "#{space}#{word.Correct}#{space}"

search = (path)->

  lpath = path.toLowerCase()

  if not isPathGood lpath then return
  if not passesLocaleChecks lpath then return

  data = fs.readFileSync path
  sdata = data.toString()
  sNewData = sdata

  count = 0
  changed = false
  for word in list
    if word.Regex is undefined then continue
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


buildWordList()

index = -1
for path in process.argv
  index += 1
  if index < 2 then continue
  search "#{path}"
