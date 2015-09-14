class Masonry 
  constructor: (@config) ->
    @minBp = @config.breakpoints.min
    @maxBp = @config.breakpoints.max
    @init()

  init: =>

    if @config.node.length

      enquire.register "screen and (max-width: #{@minBp.value}px)",
        match: =>
          @config.node.masonry('destroy')

      enquire.register "screen and (min-width: #{@minBp.value}px) and (max-width: #{@maxBp.value}px)",
        match: =>
          @config.node.masonry(
            $.extend {},
            @config.options
            columnWidth: @minBp.colWidth
          )

      enquire.register "screen and (min-width: #{@maxBp.value}px)",
        match: =>
          @config.node.masonry(
            $.extend {},
            @config.options
            columnWidth: @maxBp.colWidth
          )




CategoriesList = new Masonry(
  node: $('.prj-categories-list')
  breakpoints:
    min:
      value: 481
      colWidth: 235
    max:
      value: 769
      colWidth: 300
  options:
    gutter: 20
    itemSelector: '.prj-categories-list__unit'
    isFitWidth: on

)
