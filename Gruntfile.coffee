proxy = require('proxy-middleware')
serveStatic = require('serve-static')
httpPlease = require('connect-http-please')
url = require('url')
middlewares = require('./speed-middleware')
sass = require('node-sass')

module.exports = (grunt) ->
  pkg = grunt.file.readJSON('package.json')

  accountName = process.env.VTEX_ACCOUNT or pkg.accountName or 'basedevmkp'

  environment = process.env.VTEX_ENV or 'vtexcommercestable'
  
  secureUrl = process.env.VTEX_SECURE_URL or pkg.secureUrl

  port = process.env.PORT || 80
  
  verbose = grunt.option('verbose')

  if secureUrl
    imgProxyOptions = url.parse("https://#{accountName}.vteximg.com.br/arquivos")
  else 
    imgProxyOptions = url.parse("http://#{accountName}.vteximg.com.br/arquivos")

  imgProxyOptions.route = '/arquivos'

  # portalHost is also used by connect-http-please
  # example: basedevmkp.vtexcommercestable.com.br
  portalHost = "#{accountName}.#{environment}.com.br"
  localHost = "#{accountName}.vtexlocal.com.br"
  if port != 80
    localHost = "#{localHost}:#{port}"
  
  if secureUrl
    portalProxyOptions = url.parse("https://#{portalHost}/")
  else
    portalProxyOptions = url.parse("http://#{portalHost}/")
  portalProxyOptions.preserveHost = true
  portalProxyOptions.cookieRewrite = "#{accountName}.vtexlocal.com.br"

  rewriteReferer = (referer = '') ->
    if secureUrl
      referer = referer.replace('http:', 'https:')
    return referer.replace(localHost, portalHost)


  rewriteLocation = (location) ->
    return location
      .replace('https:', 'http:')
      .replace(portalHost, localHost)

  config =
    clean:
      main: ['build']
  
    copy:
      main:
        files: [
          expand: true
          cwd: 'src/arquivos'
          src: ['**/*']
          dest: 'build/arquivos/'
        ]
      js:
        files: [
          expand: true
          cwd: 'src/Scripts/js'
          src: ['**/*.js']
          dest: 'build/arquivos/'
        ]
      css:
        files: [
          expand: true
          cwd: 'src/css'
          src: ['**/*.css']
          dest: 'build/arquivos/'
        ]

    coffee:
      main:
        files: [
          expand: true
          cwd: 'src/Scripts/coffee/'
          src: ['**/*.coffee']
          dest: 'build/arquivos/'
          ext: '.js'
        ]

    sass:
      compile:
        options:
          implementation: sass
          sourceMap: false
          includePaths: [
            'node_modules'
          ]
        files: [
          expand: true
          cwd: 'src/sass/'
          src: ['*.scss']
          dest: 'build/arquivos/'
          ext: '.css'
        ]
      min:
        options:
          implementation: sass
          sourceMap: true
          includePaths: [
            'node_modules'
          ]
          outputStyle: 'compressed'
          sourceMapRoot: '../src/sass/'
        files: [
          expand: true
          cwd: 'src/sass/'
          src: ['*.scss']
          dest: 'build/arquivos/'
          ext: '.min.css'
        ]
  
    cssmin:
      main:
        expand: true
        cwd: 'src/css'
        src: ['**/*.css', '!**/*.min.css']
        dest: 'build/arquivos'
        ext: '.min.css'

    uglify:
      options:
        sourceMap: 
          root: '../../src/Scripts/js/'
        mangle: 
          reserved: [
            'jQuery'
          ]
        compress:
          drop_console: true
      main:
        files: [{
          expand: true
          cwd: 'build/arquivos/'
          src: ['*.js', '!*.min.js']
          dest: 'build/arquivos/'
          ext: '.min.js'
        }]

    sprite:
      all: 
        src: 'src/sprite/*.png'
        dest: 'build/arquivos/spritesheet.png'
        destCss: 'build/arquivos/sprite.css'

    imagemin:
      main:
        files: [
          expand: true
          cwd: 'src/img/'
          src: ['**/*.{png,jpg,gif}']
          dest: 'build/arquivos/'
        ]

    connect:
      http:
        options:
          hostname: "*"
          livereload: true
          port: process.env.PORT || 80
          middleware: [
            middlewares.disableCompression
            middlewares.rewriteLocationHeader(rewriteLocation)
            middlewares.replaceHost(portalHost)
            middlewares.replaceReferer(rewriteReferer)
            middlewares.replaceHtmlBody(environment, accountName, secureUrl)
            httpPlease(host: portalHost, verbose: verbose)
            serveStatic('./build')
            proxy(imgProxyOptions)
            proxy(portalProxyOptions)
            middlewares.errorHandler
          ]

    watch:
      options:
        livereload: true
      coffee:
        files: ['src/coffee/**/*.coffee']
        tasks: ['coffee']
      sass:
        files: ['src/sass/**/*.scss']
        tasks: ['sass:compile']
      images:
        options:
          livereload: false
        files: ['src/**/*.{png,jpg,gif}']
        tasks: ['imagemin']
      css:
        files: ['src/css/**/*.css']
        tasks: ['copy:css']
      js:
        files: ['src/Scripts/js/**/*.js']
        tasks: ['copy:js']
      main:
        options:
          livereload: false
        files: ['src/arquivos/**/*']
        tasks: ['copy:main']
      grunt:
        files: ['Gruntfile.coffee']

  tasks =
    # Building block tasks
    build: ['clean', 'copy:main', 'copy:js', 'copy:css', 'sprite', 'coffee', 'sass:compile', 'imagemin']
    min: ['uglify', 'sass:min', 'cssmin'] # minifies files
    # Deploy tasks
    dist: ['build', 'min'] # Dist - minifies files
    test: []
    # Development tasks
    default: ['build', 'connect', 'watch']
    devmin: ['build', 'min',
             'connect:http:keepalive'] # Minifies files and serve

  # Project configuration.
  grunt.config.init config
  if grunt.cli.tasks[0] is 'coffee'
    grunt.loadNpmTasks 'grunt-contrib-coffee'
  else
    grunt.loadNpmTasks name for name of pkg.devDependencies when name[0..5] is 'grunt-'
  grunt.registerTask taskName, taskArray for taskName, taskArray of tasks
