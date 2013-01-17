/**
 * An instance of this class is returned on calling `KssStyleguide.section`.
 * Exposes convenience methods for interpreting data.
 *
 * @param {Object} data A part of the data object passed on by `KssStyleguide`.
 */
module.exports = function (/* Object */ options, /**/ argv, /* Function */ callback) {

    options = options || {};

    callback = typeof callback === 'function' ? callback : function () {};

    'use strict';

    var kss = require('./kss.js'),
        util = require('util'),
        less = require('less'),

        wrench = require('wrench'),
        path = require('path'),
        fs = require('fs'),

        handlebars = require('handlebars'),
        marked = require('marked'),
        cleanCss = require('clean-css'),

        template ,
        styleguide,

        generatePage,
        jsonSections,
        jsonModifiers,
        generateIndex,
        saveStylesheet,
        generateStylesheet;

    // defaults
    options.templateDirectory = options.templateDirectory || __dirname + '/template';
    options.sourceDirectory = options.sourceDirectory || __dirname + '/../demo',
    options.destinationDirectory = options.destinationDirectory || process.cwd() + '/styleguide';

    // TEMPLATES
    // Compile the Handlebars template
    template = fs.readFileSync(options.templateDirectory + '/index.html', 'utf8');
    template = handlebars.compile(template);

    // Create a new "styleguide" directory and copy the contents
    // of "public" over.
    try {
        fs.mkdirSync(options.destinationDirectory);
    } catch (e) {}

    wrench.copyDirSyncRecursive(
        options.templateDirectory + '/public',
        options.destinationDirectory + '/public'
    );

    // Generate the static HTML pages in the next tick, i.e. after the other functions have
    // been defined and handlebars helpers set up.
    process.nextTick(function() {

        less.render('@import "' + path.relative(process.cwd(), options.destinationDirectory) + '/public/kss.less";', function(err, css) {
            if (err) {
                console.error(err);
                throw err;
            }

            css = cleanCss.process(css);

            console.log('...compiling LESS');
            // Write the compiled LESS styles from the template.
            fs.writeFileSync(options.destinationDirectory + '/public/kss.css', css, 'utf8');

            console.log('...parsing your styleguide');
            kss.traverse(options.sourceDirectory, {
                multiline : true,
                markdown  : true,
                markup    : true
            }, function(err, sg) {
                styleguide = sg;

                var sections = styleguide.section('*.'),
                    i, sectionCount = sections.length,
                    sectionRoots = [], currentRoot,
                    rootCount, childSections = [],
                    pages = {};

                if (err) {
                    throw err;
                }

                // Accumulate all of the sections' first indexes
                // in case they don't have a root element.
                for (i = 0; i < sectionCount; i += 1) {
                    currentRoot = sections[i].reference().match(/[0-9]*\.?/)[0].replace('.', '');

                    if (!~sectionRoots.indexOf(currentRoot)) {
                        sectionRoots.push(currentRoot);
                    }
                }

                sectionRoots.sort();
                rootCount = sectionRoots.length;

                // Now, group all of the sections by their root
                // reference, and make a page for each.
                for (i = 0; i < rootCount; i += 1) {
                    childSections = styleguide.section(sectionRoots[i]+'.*');

                    generatePage(
                        styleguide, childSections,
                        sectionRoots[i], pages, sectionRoots
                    );
                }

                generateIndex(styleguide, childSections, pages, sectionRoots);
                generateStylesheet(argv);
            });
        });
    });

    // Compile LESS/CSS files into a single "style.css" if required
    generateStylesheet = function(argv) {
        var stylebuffer = '',
            count  =  0,
            type,
            projectStyles = {
                less: argv.less,
                css : argv.css
            };

        console.log('...compiling additional stylesheets');

        for (type in projectStyles) {

            if (typeof projectStyles[type] === 'undefined') {
                continue;
            }

            switch (type) {
                case 'less':
                    count += 1;

                    // Hackish? Sure. But it works.
                    less.render('@import "' + path.relative(process.cwd(), projectStyles[type]) + '";', function(err, css) {
                        if (err) {
                            throw err;
                        }
                        stylebuffer += css;
                        count -= 1;

                        if (count < 1) {
                            saveStylesheet(stylebuffer);
                        }
                    });
                break;
                case 'css':
                    stylebuffer += fs.readFileSync(projectStyles[type]);
                break;
            }
        }

        if (!count) {
            saveStylesheet(stylebuffer);
        }
    };

    // Used by generateStylesheet to minify and then
    // save its final buffer to a single CSS file.
    saveStylesheet = function(buffer) {
        buffer = cleanCss.process(buffer);
        fs.writeFileSync(
            options.destinationDirectory + '/public/style.css',
            buffer, 'utf8'
        );
        callback();
    };

    // Renders the handlebars template for a section and saves it to a file.
    // Needs refactoring for clarity.
    generatePage = function(styleguide, sections, root, pages, sectionRoots) {
        console.log(
            '...generating section '+root+' [',
            styleguide.section(root) ? styleguide.section(root).header() : 'Unnamed',
            ']'
        );
        fs.writeFileSync(options.destinationDirectory + '/section-'+root+'.html',
            template({
                includes: options.includes,
                styleguide: styleguide,
                sections: jsonSections(sections),
                rootNumber: root,
                sectionRoots: sectionRoots,
                overview: false,
                argv: argv || {}
            })
        );
    };

    // Equivalent to generatePage, however will take `styleguide.md` and render it
    // using first Markdown and then Handlebars
    generateIndex = function(styleguide, sections, pages, sectionRoots) {
        try {
            console.log('...generating styleguide overview');
            fs.writeFileSync(options.destinationDirectory + '/index.html',
                template({
                    includes: options.includes,
                    styleguide: styleguide,
                    sectionRoots: sectionRoots,
                    sections: jsonSections(sections),
                    rootNumber: 0,
                    argv: argv || {},
                    overview: marked(fs.readFileSync(options.sourceDirectory + '/styleguide.md', 'utf8'))
                })
            );
        } catch(e) {
            console.log('...no styleguide overview generated:', e.message);
        }
    };

    // Convert an array of `KssSection` instances to a JSON object.
    jsonSections = function(sections) {
        return sections.map(function(section) {
            return {
                header: section.header(),
                description: section.description(),
                reference: section.reference(),
                depth: section.data.refDepth,
                deprecated: section.deprecated(),
                experimental: section.experimental(),
                modifiers: jsonModifiers(section.modifiers())
            };
        });
    };

    // Convert an array of `KssModifier` instances to a JSON object.
    jsonModifiers = function(modifiers) {
        return modifiers.map(function(modifier) {
            return {
                name: modifier.name(),
                description: modifier.description(),
                className: modifier.className()
            };
        });
    };

    /**
     * Equivalent to the {#if} block helper with multiple arguments.
     */
    handlebars.registerHelper('ifAny', function() {
        var argLength = arguments.length - 2,
            content = arguments[argLength + 1],
            success = true;

        for (var i = 0; i < argLength; i += 1) {
            if (!arguments[i]) {
                success = false;
                break;
            }
        }

        return success ? content(this) : content.inverse(this);
    });

    /**
     * Returns a single section, found by its reference number
     * @param  {String|Number} reference The reference number to search for.
     */
    handlebars.registerHelper('section', function(reference) {

        var section = styleguide.section(reference);

        if (!section) {
            return false;
        }

        return arguments[arguments.length-1](section.data);

    });

    /**
     * Loop over a section query. If a number is supplied, will convert into
     * a query for all children and descendants of that reference.
     * @param  {Mixed} query The section query
     */
    handlebars.registerHelper('eachSection', function(query) {
        var sections,
            i, l, buffer = '';

        if (!query.match(/x|\*/g)) {
            query = new RegExp(query + '.*');
        }
        sections = styleguide.section(query);
        if (!sections) {
            return '';
        }

        l = sections.length;
        for (i = 0; i < l; i += 1) {
            buffer += arguments[arguments.length-1](sections[i].data);
        }

        return buffer;
    });

    /**
     * Loop over each section root, i.e. each section only one level deep.
     */
    handlebars.registerHelper('eachRoot', function() {
        var sections,
            i, l, buffer = '';

        sections = styleguide.section('x');
        if (!sections) {
            return '';
        }

        l = sections.length;
        for (i = 0; i < l; i += 1) {
            buffer += arguments[arguments.length-1](sections[i].data);
        }

        return buffer;
    });

    /**
     * Equivalent to "if the current section is X levels deep". e.g:
     *
     * {{#refDepth 1}}
     *   ROOT ELEMENTS ONLY
     *  {{else}}
     *   ANYTHING ELSE
     * {{/refDepth}}
     */
    handlebars.registerHelper('whenDepth', function(depth, context) {
        if (!(context && this.refDepth)) {
            return '';
        }
        if (depth === this.refDepth) {
            return context(this);
        }
        if (context.inverse) {
            return context.inverse(this);
        }
    });

    /**
     * Similar to the {#eachSection} helper, however will loop over each modifier
     * @param  {Object} section Supply a section object to loop over it's modifiers. Defaults to the current section.
     */
    handlebars.registerHelper('eachModifier', function(section) {
        var modifiers, i, l, buffer = '';

        // Default to current modifiers, but allow supplying a custom section
        if (section.data) {
            modifiers = section.data.modifiers;
        }

        modifiers = modifiers || this.modifiers || false;

        if (!modifiers) {
            return {};
        }

        l = modifiers.length;
        for (i = 0; i < l; i++) {
            buffer += arguments[arguments.length-1](modifiers[i].data || '');
        }
        return buffer;
    });

    /**
     * Outputs a modifier's markup, if possible.
     * @param  {Object} modifier Specify a particular modifier object. Defaults to the current modifier.
     */
    handlebars.registerHelper('modifierMarkup', function(modifier) {
        modifier = arguments.length < 2 ? this : modifier || this || false;

        if (!modifier) {
            return false;
        }

        // Maybe it's actually a section?
        if (modifier.modifiers) {
            return new handlebars.SafeString(
                modifier.markup
            );
        }

        // Otherwise return the modifier markup
        return new handlebars.SafeString(
            new kss.KssModifier(modifier).markup()
        );
    });

    /**
     * Quickly avoid escaping strings
     * @param  {String} arg The unescaped HTML
     */
    handlebars.registerHelper('html', function(arg) {
        return new handlebars.SafeString(arg || '');
    });

};
