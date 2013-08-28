module.exports = (BasePlugin) ->
    pathUtil = require('path')
    fs = require('fs')
    balUtil = require('bal-util')

    class AssetsPlugin extends BasePlugin
        name: 'assets'

        config:
            retainPath: 'yes'
            retainName: 'no'
            minifyJS: 'yes'

        assetLocations: null # Object

        constructor: ->
            super
            @assetLocations = {}

        renderBefore: ({templateData}, next) ->
            me = @
            config = @config

            docpad.log 'debug', 'in renderBefore'

            templateData.asset = (name) ->
                docpad.log 'debug', "Working through file #{name}"
                f = @getFileAtPath(name)
                if f
                    srcPath = f.attributes.fullPath
                    if not (f.attributes.fullPath of me.assetLocations)
                        docpad.log 'debug', 'First time seen, creating hash'
                        docpad.log 'debug', "Source path is #{srcPath}"
                        docpad.log 'debug', "Out path is #{f.attributes.outDirPath}"
                        crypto = require('crypto')
                        shasum = crypto.createHash('sha1')
                        shasum.update(f.attributes.source)
                        hash = shasum.digest('hex')
                        docpad.log 'debug', "Hash is #{hash}"
                        if (config.retainPath == 'yes')
                            relativeOutDirPath = f.attributes.relativeOutDirPath
                        else
                            relativeOutDirPath = ''
                        docpad.log 'debug', "relativeOutDirPath is #{relativeOutDirPath}"

                        if (config.retainName == 'yes')
                            outBasename = "#{f.attributes.basename}-#{hash}"
                        else
                            outBasename = hash
                        docpad.log 'debug', "outBasename is #{outBasename}"

                        if (relativeOutDirPath == '')
                            relativeOutBase = outBasename
                        else
                            relativeOutBase = "#{relativeOutDirPath}#{pathUtil.sep}#{outBasename}"
                        docpad.log 'debug', "relativeOutBase is #{relativeOutBase}"

                        outFilename = "#{outBasename}.#{f.attributes.outExtension}"
                        docpad.log 'debug', "outFilename is #{outFilename}"

                        relativeOutPath = "#{relativeOutBase}.#{f.attributes.outExtension}"
                        docpad.log 'debug', "relativeOutPath is #{relativeOutPath}"

                        if (relativeOutDirPath == '')
                            outDirPath = docpad.config.outPath
                        else
                            outDirPath = "#{docpad.config.outPath}#{pathUtil.sep}#{relativeOutDirPath}"
                        docpad.log 'debug', "outDirPath is #{outDirPath}"

                        outPath = "#{outDirPath}#{pathUtil.sep}#{outFilename}"
                        docpad.log 'debug', "outPath is #{outPath}"

                        me.assetLocations[srcPath] = {
                            relativeOutDirPath: relativeOutDirPath
                            outBasename: outBasename
                            relativeOutBase: relativeOutBase
                            outFilename: outFilename
                            relativeOutPath: relativeOutPath
                            outDirPath: outDirPath
                            outPath: outPath
                        }
                    docpad.log 'debug', "Returning #{pathUtil.sep}#{me.assetLocations[srcPath].relativeOutPath}"
                    return "#{pathUtil.sep}#{me.assetLocations[srcPath].relativeOutPath}"
                else
                    debug.log 'debug', "Asset #{name} not found; ignoring"
                    return name

            next()
            @

        writeBefore: ({collection, templateData}, next)->
            me = @
            config = @config

            collection.forEach (document) ->
                srcPath = document.attributes.fullPath
                if (srcPath of me.assetLocations)
                    if (document.attributes.outExtension == 'js' && config.minifyJS == 'yes')
                        docpad.log 'debug', "Considering #{srcPath} for minification"
                        if (/[-\.]min\.js$/.test(document.attributes.filename))
                            docpad.log 'debug', 'Filename suggests already minified; skipping'
                        else
                            docpad.log 'debug', "Minifying #{srcPath}"
                            UglifyJS = require("uglify-js")
                            document.attributes.content = UglifyJS.minify(document.attributes.content, {fromString: true}).code
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
