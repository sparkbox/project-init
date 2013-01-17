/*
 * grunt-targethtml
 * https://github.com/changer/grunt-targethtml
 *
 * Copyright (c) 2012 Ruben Stolk
 * Licensed under the MIT license.
 */

module.exports = function(grunt) {

    // Please see the grunt documentation for more information regarding task and
    // helper creation: https://github.com/cowboy/grunt/blob/master/docs/toc.md

    // ==========================================================================
    // TASKS
    // ==========================================================================

    grunt.registerMultiTask('targethtml', 'Produces html-output depending on grunt release version', function() {
        if (!this.data) { return false; }
        grunt.helper('targethtml', this.target, this.file);
    });

    // ==========================================================================
    // HELPERS
    // ==========================================================================

    grunt.registerHelper('targethtml', function(target, file) {
        var f = grunt.file;
        var contents = f.read(file.src);
        if(contents) {
            contents = contents.replace(new RegExp('<!--[\\[\\(]if target ' + target + '[\\]\\)]>(<!-->)?([\\s\\S]*?)(<!--)?<![\\[\\(]endif[\\]\\)]-->', 'g'), '$2');
            contents = contents.replace(new RegExp('^[\\s\\t]+<!--[\\[\\(]if target .*?[\\]\\)]>(<!-->)?([\\s\\S]*?)(<!--)?<![\\[\\(]endif[\\]\\)]-->[\r\n]*', 'gm'), '');
            contents = contents.replace(new RegExp('<!--[\\[\\(]if target .*?[\\]\\)]>(<!-->)?([\\s\\S]*?)(<!--)?<![\\[\\(]endif[\\]\\)]-->[\r\n]*', 'g'), '');
            f.write(file.dest, contents);
            console.log('Created ' + file.dest, target);
        }
    });

};
