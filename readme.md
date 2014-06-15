#Reagent: front-end workflow system.

##Based on Fireshell framework.

#Features

##Organic stylesheet dividing system.
Instead of SMACSS, I use static-dynamic approach:
- file for variables;
- one file for don't changing code, like libraries of mixins or extends;
- another file for code which changed from project to project, like dependencies or typography;
- core file for all other styles.

##Partials support
You can include partials to you core html file.

##Compass support
Original Fireshell framework supports only sass/scss. I've added compass framework support.

#Important
I'm developing this system only for my own needs.

#Credits
Fireshell and its authors, Grunt, Sass, Compass, Node.js