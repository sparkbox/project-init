#global module:false
module.exports = (grunt) ->

  # Project configuration.
  grunt.initConfig
    pkg: grunt.file.readJSON("package.json")

    watch:

      stylesheets:
        files: "scss/*"
        tasks: "compass:dev"

      images:
        files: "images/*"
        tasks: "images"

      partials:
        files: "partials/*"
        tasks: "partials"

      javascript:
        files: ["coffee/*", "js/libs/*.js"]
        tasks: "javascript:dev"

      jsTesting:
        files: "dist/js/*.js"
        tasks: "jasmine"
        
      cukes:
        files: ["features/*.feature", "features/step_definitions/*.coffee"]
        tasks: ["coffee:cucumber_step_definitions", "cucumberjs"]

      rootDirectory:
        files: [ "root-directory/**/*", "root-directory/.*" ]
        tasks: "default"

    compass:
        dev:
          options:
            environment: 'dev'
        dist:
          options:
            environment: 'production'

    coffee:
      compile:
        files:
          "js/app.js": "coffee/app.coffee"
      jasmine_specs:
        files: grunt.file.expandMapping(["specs/*.coffee"], "specs/js/", {
          rename: (destBase, destPath) ->
            destBase + destPath.replace(/\.coffee$/, ".js").replace(/specs\//, "")
        })
      cucumber_step_definitions:
        files: grunt.file.expandMapping(["features/step_definitions/*.coffee"], "features/step_definitions/js/", {
          rename: (destBase, destPath) ->
            destBase + destPath.replace(/\.coffee$/, ".js").replace(/features\/step_definitions\//, "")
        })

    concat:
      partials:
        options:
          process: true
        files:
          # destination as key, sources as value
          "dist/index.html": ["partials/_header.html", "partials/_home-page.html", "partials/_footer.html"]
          "dist/about.html": ["partials/_header.html", "partials/_about-page.html", "partials/_footer.html"]
          "dist/404.html": "partials/404.html"
      js:
        #first concatenate libraries, then our own JS
        src: ["js/concat/*", "js/app.js"]
        #put it in dist/
        dest: "dist/js/<%= pkg.name %>.js"

    modernizr:
      devFile: "js/no-concat/modernizr.js"
      outputFile: "dist/js/modernizr.js"
      extra:
        shiv: true
        printshiv: false
        load: true
        mq: false
        cssclasses: true

      extensibility:
        addtest: false
        prefixed: false
        teststyles: false
        testprops: false
        testallprops: false
        hasevents: false
        prefixes: false
        domprefixes: false

      uglify: true
      parseFiles: true
      matchCommunityTests: false

    clean:
      all:
        src: "dist/*"
        dot: true # clean hidden files as well
      html: "dist/*.html"
      stylesheets: "dist/css/*"
      javascript: "dist/js/*"
      images: "dist/images/*"

    exec:
      copyImages:
        command: "mkdir -p dist/images; cp -R images/ dist/images/"
      copyRootDirectory:
        command: "cp -Rp root-directory/ dist/"
      copyJS:
        #this copies non-concatenated js straight to dist/js
        #(concatenated JS is put into place by concat:js
        command: "mkdir -p dist/js; cp js/no-concat/* dist/js"

    jasmine:
      src: "dist/**/*.js"
      options:
        specs: "specs/js/*Spec.js"
        helpers: "specs/js/*Helper.js"
        vendor: ["js/concat/jquery-1.9.1.min.js", "specs/lib/*.js"]

    cucumberjs: {
      files: 'features',
      options: {
        steps: "features/step_definitions/js"
      }
    }

  grunt.loadNpmTasks "grunt-contrib-clean"
  grunt.loadNpmTasks "grunt-contrib-coffee"
  grunt.loadNpmTasks "grunt-contrib-watch"
  grunt.loadNpmTasks "grunt-contrib-compass"
  grunt.loadNpmTasks "grunt-contrib-concat"
  grunt.loadNpmTasks "grunt-contrib-jasmine"
  grunt.loadNpmTasks "grunt-cucumber"
  grunt.loadNpmTasks "grunt-modernizr"
  grunt.loadNpmTasks "grunt-notify"
  grunt.loadNpmTasks "grunt-exec"

  # Clean dist/ and copy root-directory/
  # NOTE: this has to wipe out everything
  grunt.registerTask "root-canal", [ "clean:all", "exec:copyRootDirectory" ]

  # Clean and concatenate html files
  grunt.registerTask "partials", [ "clean:html", "concat:partials" ]

  # Clean, compile and concatenate JS
  grunt.registerTask "javascript:dev", [ "clean:javascript", "coffee", "concat:js", "exec:copyJS", "jasmine", "cucumberjs" ]
  grunt.registerTask "javascript:dist", [ "clean:javascript", "coffee", "concat:js", "modernizr", "jasmine", "cucumberjs" ]

  # Clean and compile stylesheets
  grunt.registerTask "stylesheets:dev", ["clean:stylesheets", "compass:dev"]
  grunt.registerTask "stylesheets:dist", ["clean:stylesheets", "compass:dist"]

  # Clean and copy images
  grunt.registerTask "images", [ "clean:images", "exec:copyImages" ]

  # Production task
  grunt.registerTask "dev", [ "root-canal", "partials", "javascript:dev", "stylesheets:dev", "images" ]
  grunt.registerTask "dist", [ "root-canal", "partials", "javascript:dist", "stylesheets:dist", "images" ]

  # Default task
  grunt.registerTask "default", "dev"
