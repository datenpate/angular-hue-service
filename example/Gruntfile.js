module.exports = function ( grunt ) {
  grunt.loadNpmTasks('grunt-contrib-watch');
  grunt.loadNpmTasks('grunt-contrib-coffee');
  grunt.loadNpmTasks('grunt-coffeelint');

  grunt.initConfig({
    pkg: grunt.file.readJSON('package.json'),

    coffee: {
      source: {
        options: {
          bare: true
        },
        src: 'app/app.coffee',
        dest: 'app/app.js'
      }
    },

    coffeelint: {
      src: {
        files: {
          src: [ 'app/app.coffee' ]
        }
      },
      options: {
        'max_line_length': {
          'level': 'ignore'
        }
      }
    },

    watch: {
      files: [ 'app/app.coffee' ],
      tasks: [ 'coffee' ]
    }
  });

  grunt.registerTask('build', [ 'coffee' ]);

};