tryfiles = require 'connect-tryfiles'
lr = require 'connect-livereload'
connect = require 'connect'
LR_URL = "//' + (location.hostname || 'localhost') + '/livereload.js"
module.exports = (grunt) ->
  pkg = grunt.file.readJSON('package.json')

  host = process.env.VTEX_HOST or 'vtexcommerce'

  verbose = grunt.option('verbose')
  
  open = if pkg.accountName then "http://#{pkg.accountName}.vtexlocal.com.br" else undefined

  errorHandler = (err, req, res, next) -> grunt.log.warn(err.code.red, req.url.yellow)

  config =
    clean:
      main: ['build']

    copy:
      main:
        files: [
          expand: true
          cwd: 'src/'
          src: ['**', '!**/*.coffee', '!**/*.less']
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

    imagemin:
      main:
        files: [
          expand: true
          cwd: 'src/'
          src: ['**/*.{png,jpg,gif}']
          dest: 'build/'
        ]

    connect:
      http:
        options:
          hostname: "*"
          open: open
          port: 80
          middleware: [
            lr({disableAcceptEncoding: true, src: LR_URL})
            tryfiles '**', "http://portal.#{host}.com.br:80", {cwd: 'build/', verbose: verbose}
            connect.static './build/'
            errorHandler
          ]
      https:
        options:
          hostname: "*"
          https: true
          protocol: 'https'
          port: 443
          middleware: [
            lr({disableAcceptEncoding: true, src: LR_URL})
            tryfiles('**',
              {target: "https://portal.#{host}.com.br:443",
              secure: false},
              {cwd: 'build/', verbose: verbose})
            connect.static './build/'
            errorHandler
          ]

    watch:
      options:
        livereload: true
        spawn: false
      coffee:
        files: ['src/**/*.coffee']
        tasks: ['coffee']
      less:
        files: ['src/**/*.less']
        tasks: ['less']
      images:
        files: ['src/**/*.{png,jpg,gif}']
        tasks: ['imagemin']
      main:
        files: ['src/**/*.*']
        tasks: ['copy']
      grunt:
        files: ['Gruntfile.coffee']

  tasks =
    # Building block tasks
    build: ['clean', 'copy:main', 'coffee', 'less', 'imagemin']
    min: ['uglify', 'cssmin'] # minifies files
    # Deploy tasks
    dist: ['build', 'min'] # Dist - minifies files
    test: []
    # Development tasks
    default: ['build', 'connect', 'watch']
    devmin: ['build', 'min', 'connect:https',
             'connect:http:keepalive'] # Minifies files and serve

  # Project configuration.
  grunt.initConfig config
  grunt.loadNpmTasks name for name of pkg.devDependencies when name[0..5] is 'grunt-'
  grunt.registerTask taskName, taskArray for taskName, taskArray of tasks
