fs = require 'fs'

list = require './wordlist.json'

dir = '.'


path = "#{dir}/#{process.argv[2]}"

if process.argv[2].indexOf('./.')==0 then return
if process.argv[2].indexOf("node_modules")>-1 then return
if process.argv[2].indexOf("output.csv")>-1 then return
if process.argv[2].indexOf("wordlist.json")>-1 then return

space = if (process.argv[5] is 'no') then ' ' else ''

fs.readFile path, (err, data)->
  if err then throw err
  sdata = data.toString()
  wcRegex1 = /['";:,.?¿\-!¡]+/g
  wcRegex2 = /\S+/g
  sNewData = sdata

  for word in list
    word.Regex = new RegExp "#{space}#{word.Wrong}#{space}", 'g'
  count = 0
  added = 0
  wc = (sdata.replace(wcRegex1, '').match(wcRegex2) or []).length
  for word in list
    added = (sdata.match(word.Regex) or []).length
    correct = word.Correct.split('-')
    willOverlap = added and word.Correct.match(new RegExp word.Wrong, 'g')
    if willOverlap
      for i in [0..correct.length-1]
        c = correct[i]
        creg = new RegExp(c, 'g')
        overlap = (sdata.match(creg) or []).length
        added -= overlap
    else if correct.length is 1 and space is ' '
      sNewData = sNewData.replace word.Regex, " #{word.Correct} "
    if added < 0 then added = 0
    if process.argv[4] is 't' and added > 0
      console.log "Found '#{word.Wrong}' #{added} times. Should be '#{word.Correct}'"
    count += added
#  console.log("#{path} has #{count} misspellings at a #{count / wc} ratio")
  if count > 0 then console.log "#{path},#{count},#{count/wc}"
  if process.argv[3] is 'write' and space is ' ' and (sNewData isnt sdata) then fs.writeFile(path, sNewData)
