proxy = require('proxy-middleware')
serveStatic = require('serve-static')
httpPlease = require('connect-http-please')
url = require('url')

module.exports = (grunt) ->
  pkg = grunt.file.readJSON('package.json')

  accountName = process.env.VTEX_ACCOUNT or pkg.accountName or 'basedevmkp'

  environment = process.env.VTEX_HOST or 'vtexcommercestable'

  verbose = grunt.option('verbose')
  
  errorHandler = (err, req, res, next) ->
    errString = err.code?.red ? err.toString().red
    grunt.log.warn(errString, req.url.yellow)

  imgProxyOptions = url.parse("http://#{accountName}.vteximg.com.br/arquivos")
  imgProxyOptions.route = '/arquivos'

  # portalHost is also used by connect-http-please
  # example: basedevmkp.vtexcommercestable.com.br
  portalHost = "#{accountName}.#{environment}.com.br"
  portalProxyOptions = url.parse("http://#{portalHost}/")
  portalProxyOptions.preserveHost = true

  ignoreReplace = [/\.js(\?.*)?$/, /\.css(\?.*)?$/, /\.svg(\?.*)?$/, /\.ico(\?.*)?$/,
                   /\.woff(\?.*)?$/, /\.png(\?.*)?$/, /\.jpg(\?.*)?$/, /\.jpeg(\?.*)?$/, /\.gif(\?.*)?$/, /\.pdf(\?.*)?$/]

  # Middleware that replaces vtexcommercestable and vteximg for vtexlocal
  # This enables the same proxy to handle both domains and avoid adding rules to /etc/hosts
  replaceHtmlBody = (req, res, next) ->
    # Ignore requests to obvious non-HTML resources
    return next() if ignoreReplace.some (ignore) -> ignore.test(req.url)

    data = ''
    write = res.write
    end = res.end

    res.write = (chunk) ->
      data += chunk

    res.end = (chunk, encoding) ->
      if chunk
        data += chunk

      if data
        data = data.replace(new RegExp(environment, "g"), "vtexlocal")
        data = data.replace(new RegExp("vteximg", "g"), "vtexlocal")

      # Restore res properties
      res.write = write
      res.end = end
      res.end data, encoding

    next()

  disableCompression = (req, res, next) ->
    req.headers['accept-encoding'] = 'identity'
    next()

  config =
    clean:
      main: ['build']

    copy:
      main:
        files: [
          expand: true
          cwd: 'src/'
          src: ['**', '!**/*.coffee', '!**/*.less', '!sprite/**/*']
          dest: "build/"
        ]

    coffee:
      main:
        files: [
          expand: true
          cwd: 'src/'
          src: ['**/*.coffee']
          dest: "build/"
          ext: '.js'
        ]

    less:
      main:
        files: [
          expand: true
          cwd: 'src/'
          src: ['**/*.less']
          dest: "build/"
          ext: '.css'
        ]

    cssmin:
      main:
        expand: true
        cwd: 'build/'
        src: ['*.css', '!*.min.css']
        dest: 'build/'
        ext: '.min.css'

    uglify:
      options:
        mangle: false
      main:
        files: [{
          expand: true
          cwd: 'build/'
          src: ['*.js', '!*.min.js']
          dest: 'build/'
          ext: '.min.js'
        }]

    sprite:
      all: 
        src: 'src/sprite/*.png'
        dest: 'build/spritesheet.png'
        destCss: 'build/sprite.css'

    imagemin:
      main:
        files: [
          expand: true
          cwd: 'build/'
          src: ['**/*.{png,jpg,gif}']
          dest: 'build/'
        ]

    connect:
      http:
        options:
          hostname: "*"
          livereload: true
          port: process.env.PORT || 80
          middleware: [
            disableCompression
            replaceHtmlBody
            httpPlease(host: portalHost, verbose: verbose)
            serveStatic('./build')
            proxy(imgProxyOptions)
            proxy(portalProxyOptions)
            errorHandler
          ]

    watch:
      options:
        livereload: true
      coffee:
        files: ['src/**/*.coffee']
        tasks: ['coffee']
      less:
        options:
          livereload: false
        files: ['src/**/*.less']
        tasks: ['less']
      images:
        files: ['src/**/*.{png,jpg,gif}']
        tasks: ['imagemin']
      css:
        files: ['build/**/*.css']
      main:
        files: ['src/**/*.html', 'src/**/*.js', 'src/**/*.css']
        tasks: ['copy']
      grunt:
        files: ['Gruntfile.coffee']

  tasks =
    # Building block tasks
    build: ['clean', 'copy:main', 'sprite', 'coffee', 'less', 'imagemin']
    min: ['uglify', 'cssmin'] # minifies files
    # Deploy tasks
    dist: ['build', 'min'] # Dist - minifies files
    test: []
    # Development tasks
    default: ['build', 'connect', 'watch']
    devmin: ['build', 'min',
             'connect:http:keepalive'] # Minifies files and serve

  # Project configuration.
  grunt.config.init config
  if grunt.cli.tasks[0] is 'less'
    grunt.loadNpmTasks 'grunt-contrib-less'
  else if grunt.cli.tasks[0] is 'coffee'
    grunt.loadNpmTasks 'grunt-contrib-coffee'
  else
    grunt.loadNpmTasks name for name of pkg.devDependencies when name[0..5] is 'grunt-'
  grunt.registerTask taskName, taskArray for taskName, taskArray of tasks
