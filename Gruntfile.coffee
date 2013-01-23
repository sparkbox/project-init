#global module:false
module.exports = (grunt) ->

  # Project configuration.
  grunt.initConfig
    pkg: grunt.file.readJSON("package.json")

    watch:

      stylesheets:
        files: "scss/*"
        tasks: "compass"

      images:
        files: "images/*"
        tasks: "images"

      templates:
        files: "templates/*"
        tasks: "templates"

      javascript:
        files: ["coffee/*", "js/*"]
        tasks: "javascript"

      jsTesting:
        files: ["src/**/*.js", "specs/**/*.js"]
        tasks: "jasmine"

    compass:
      dist:
        files:
          "dist/css/base.css": "scss/base.scss"

    coffee:
      compile:
        files:
          "js/app.js": "coffee/app.coffee"
      glob_to_multiple:
        files: grunt.file.expandMapping(["specs/*.coffee"], "specs/js/", {
          rename: (destBase, destPath) ->
            destBase + destPath.replace(/\.coffee$/, ".js").replace(/specs\//, "");
        })

    concat:
      templates:
        options:
          process: true
        files:
          # destination as key, sources as value
          "dist/index.html": ["templates/_header.html", "templates/_home-page.html", "templates/_footer.html"]
          "dist/about.html": ["templates/_header.html", "templates/_about-page.html", "templates/_footer.html"]
          "dist/404.html": "templates/404.html"

      js:
        #i.e. src: ["js/libs/mediaCheck.js", "js/app.js"],
        src: ["js/libs/*", "js/app.js"]
        #change this to a site specific name i.e. uwg.js or dty.js
        dest: "dist/js/<%= pkg.name %>.js"

    modernizr:
      devFile: "js/libs/modernizr-dev.js"
      outputFile: "dist/js/libs/modernizr.min.js"
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
      all: "dist/*"
      templates: "dist/*.html"
      stylesheets: "dist/css/*"
      javascript: "dist/js/*"
      images: "dist/images/*"

    styleguide:
      dist:
        files:
          "docs/scss": "scss/*.scss"

    exec:
      docco:
        command: "docco -o docs/js/ js/*.js js/*.coffee"
      copyImages:
        command: "mkdir -p dist/images; cp -R images/ dist/images/"

    jasmine:
      src: "dist/**/*.js"
      options:
        specs: "specs/js/*Spec.js"
        helpers: "specs/js/*Helper.js"
        vendor: ["js/libs/jquery-1.9.0.min.js", "specs/lib/*.js"]

  grunt.loadNpmTasks "grunt-contrib-clean"
  grunt.loadNpmTasks "grunt-contrib-coffee"
  grunt.loadNpmTasks "grunt-contrib-watch"
  grunt.loadNpmTasks "grunt-contrib-compass"
  grunt.loadNpmTasks "grunt-contrib-concat"
  grunt.loadNpmTasks "grunt-contrib-jasmine"
  grunt.loadNpmTasks "grunt-modernizr"
  grunt.loadNpmTasks "grunt-notify"
  grunt.loadNpmTasks "grunt-styleguide"
  grunt.loadNpmTasks "grunt-exec"

  # Clean and concatenate templates
  grunt.registerTask "templates", [ "clean:templates", "concat:templates" ]

  # Clean, compile and concatenate JS
  grunt.registerTask "javascript", [ "clean:javascript", "coffee", "concat:js", "jasmine" ]

  # Clean and compile stylesheets
  grunt.registerTask "stylesheets", ["clean:stylesheets", "compass"]

  # Clean and copy images
  grunt.registerTask "images", [ "clean:images", "exec:copyImages" ]

  # Generate documentation
  grunt.registerTask "docs", [ "styleguide", "exec:docco" ]

  # Production task
  grunt.registerTask "prod", [ "modernizr", "default" ]

  # Default task
  grunt.registerTask "default", [ "templates", "javascript", "stylesheets", "images" ]
