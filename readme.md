Reagent (boilerplate system)
=============


## From the beginning

Install Node.js, NPM.

Install `grunt-cli` globally: `npm install grunt-cli -g`

Run `npm install` to install local dependencies.


## Build

Run `grunt` to build the project. Distribution files are
located in `app` folder. `src` folder contains soruce files.


## Develop

Run `grunt server` to fire development server. It watches for changes
in files in `src` folder and runs compilation.



## Flex tools
I've created the bunch of usefull classes to use Flexbox power. All of them has `f-` prefix.

###Initalizing

`f-box` - enables flexbox. Outer container works as block.

`f-line` - enables flexbox. Outer container works as inline-block.


###Aligning

`f-align--X-Y` - state of of align. First number is the vertical align control, second - controls the horisontal.
Here is the cheatsheet:
```
1-1       1-2       1-3


2-1       2-2       2-3


3-1       3-2       3-3
``` 

Each matrix value describes the square part, where content will be aligned to.
For example, if you want to align content right and bottom, use 'f-align--3-3'

Also exists justify aliginng states. They described as `13 (from 1 to 3)`. 
So if you want justify (at X) and centering (at Y), use `f-align--2-13`.

###Grid

`f-grid--N` - where N - grid width in units,

Grid controlled by settings values: 
`$grid-gutter` - gutter between columns
`$grid-columns` - set column counts

By default we have 10px gutter and 24 column. Enjoy!

###Gaps
You can set up and control gaps inside flexbox container. 
By default there are 3 different gaps. Base (set up at settings.styl), base*0.5 and base*1.5.

###Options
`f-option--reverse` - change flexbox model from `row` to `column`
`f-option--fill` - fills all available space
`f-option--wrap` - enable multirow items.
`f-option--nogap` - enable multirow items.
