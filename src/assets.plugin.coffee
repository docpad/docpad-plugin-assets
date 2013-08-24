module.exports = (BasePlugin) ->
    pathUtil = require('path')
    fs = require('fs')
    balUtil = require('bal-util')

    class AssetsPlugin extends BasePlugin
        name: 'assets'

        config:
            retainPath: 'yes'
            retainName: 'no'

        assetLocations: null # Object

        constructor: ->
            super
            @assetLocations = {}

        parseAfter: (opts, next) ->
            me = @
            config = @config

            docpad.log 'info', 'in parseAfter'

            next()
            @

        renderBefore: ({templateData}, next) ->
            me = @
            config = @config

            docpad.log 'info', 'in renderBefore'

            templateData.asset = (name) ->
                docpad.log 'info', "Working through file #{name}"
                f = @getFileAtPath(name)
                if f
                    srcPath = f.attributes.fullPath
                    if not (f.attributes.fullPath of me.assetLocations)
                        docpad.log 'info', 'First time seen, creating hash'
                        docpad.log 'info', "Source path is #{srcPath}"
                        docpad.log 'info', "Out path is #{f.attributes.outDirPath}"
                        crypto = require('crypto')
                        shasum = crypto.createHash('sha1')
                        shasum.update(f.attributes.source)
                        hash = shasum.digest('hex')
                        docpad.log 'info', "Hash is #{hash}"
                        if (config.retainPath == 'yes')
                            relativeOutDirPath = f.attributes.relativeOutDirPath
                        else
                            relativeOutDirPath = ''
                        docpad.log 'info', "relativeOutDirPath is #{relativeOutDirPath}"

                        if (config.retainName == 'yes')
                            outBasename = "#{f.attributes.basename}-#{hash}"
                        else
                            outBasename = hash
                        docpad.log 'info', "outBasename is #{outBasename}"

                        if (relativeOutDirPath == '')
                            relativeOutBase = outBasename
                        else
                            relativeOutBase = "#{relativeOutDirPath}#{pathUtil.sep}#{outBasename}"
                        docpad.log 'info', "relativeOutBase is #{relativeOutBase}"

                        outFilename = "#{outBasename}.#{f.attributes.outExtension}"
                        docpad.log 'info', "outFilename is #{outFilename}"

                        relativeOutPath = "#{relativeOutBase}.#{f.attributes.outExtension}"
                        docpad.log 'info', "relativeOutPath is #{relativeOutPath}"

                        if (relativeOutDirPath == '')
                            outDirPath = docpad.config.outPath
                        else
                            outDirPath = "#{docpad.config.outPath}#{pathUtil.sep}#{relativeOutDirPath}"
                        docpad.log 'info', "outDirPath is #{outDirPath}"

                        outPath = "#{outDirPath}#{pathUtil.sep}#{outFilename}"
                        docpad.log 'info', "outPath is #{outPath}"

                        me.assetLocations[srcPath] = {
                            relativeOutDirPath: relativeOutDirPath
                            outBasename: outBasename
                            relativeOutBase: relativeOutBase
                            outFilename: outFilename
                            relativeOutPath: relativeOutPath
                            outDirPath: outDirPath
                            outPath: outPath
                        }
                    docpad.log 'info', "Returning #{me.assetLocations[srcPath].relativeOutPath}"
                    return me.assetLocations[srcPath].relativeOutPath
                else
                    debug.log 'info', "Asset #{name} not found; ignoring"
                    return name

            next()
            @

        writeBefore: ({collection, templateData}, next)->
            me = @

            collection.forEach (document) ->
                srcPath = document.attributes.fullPath
                if (srcPath of me.assetLocations)
                    docpad.log 'debug', "Changing output path of #{srcPath}"
                    document.attributes.relativeOutDirPath = me.assetLocations[srcPath].relativeOutDirPath
                    document.attributes.outBasename = me.assetLocations[srcPath].outBasename
                    document.attributes.relativeOutBase = me.assetLocations[srcPath].relativeOutBase
                    document.attributes.outFilename = me.assetLocations[srcPath].outFilename
                    document.attributes.relativeOutPath = me.assetLocations[srcPath].relativeOutPath
                    document.attributes.outDirPath = me.assetLocations[srcPath].outDirPath
                    document.attributes.outPath = me.assetLocations[srcPath].outPath

            next()
            @

        generateAfter: ->
            @assetLocations = {}
