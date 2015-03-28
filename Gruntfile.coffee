module.exports = (grunt) ->
  grunt.registerTask 'build', [
    'coffeelint'
    'coffee'
    'uglify'
  ]

  grunt.registerTask 'default', [
    'coffeelint',
    'coffee',
    'watch'
  ]

  grunt.initConfig
    pkg: grunt.file.readJSON('package.json')
    paths:
      build: 'dist'
      src: 'src'
      coffee: [
        'src/**/*.coffee'
        '!src/**/*.spec.coffee'
      ]
      coffeeunit: [ 'src/**/*.spec.coffee' ]
    coffee: source:
      options: bare: true
      src: '<%= paths.src %>/hue.coffee'
      dest: '<%= paths.build %>/hue-service.js'
    coffeelint:
      src: files: src: [ '<%= paths.coffee %>' ]
      test: files: src: [ '<%= paths.coffeeunit %>' ]
      options: 'max_line_length': 'level': 'ignore'
    uglify:
      options: banner: '/*! <%= pkg.name %> <%= grunt.template.today("dd-mm-yyyy") %> */\n'
      dist: files: '<%= paths.build %>/hue-service.min.js': [ '<%= paths.build %>/hue-service.js' ]
    watch:
      files: [ '<%= paths.coffee %>' ]
      tasks: [
        'coffeelint'
        'coffee'
      ]

  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-coffeelint'
  grunt.loadNpmTasks 'grunt-contrib-uglify'
