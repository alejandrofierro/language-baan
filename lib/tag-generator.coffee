{BufferedProcess, Point} = require 'atom'
Q = require 'q'
path = require 'path'

module.exports =
  class TagGenerator
    constructor: (@path, @scopeName) ->

    parseTagLine: (line) ->
      console.log(line)
      sections = line.split('\t')
      console.log(sections)
      if sections.length > 3
        tag = {
          position: new Point(parseInt(sections[2]) - 1)
          name: sections[0]
          type: sections[3]
          parent: null
        }

        if sections.length > 4 and sections[4].search('signature:') == -1
          tag.parent = sections[4]
        return tag
      else
        return null

    getLanguage: ->
      return 'Cson' if path.extname(@path) in ['.cson', '.gyp']

      {
        'source.cln'            : 'BaaN'
        'source.bc'             : 'BaaN'
      }[@scopeName]

    generate: ->
      deferred = Q.defer()
      tags = []
      command = path.resolve(__dirname, '..', 'vendor', "universal-ctags-#{process.platform}")
      defaultCtagsFile = require.resolve('./.ctags')
      args = ["--options=#{defaultCtagsFile}", '--fields=KsS']

      args.push('-nf', '-', @path)

      stdout = (lines) =>
        for line in lines.split('\n')
          if tag = @parseTagLine(line.trim())
            tags.push(tag)
      stderr = (lines) ->
      exit = ->
        deferred.resolve(tags)

      new BufferedProcess({command, args, stdout, stderr, exit})

      deferred.promise
