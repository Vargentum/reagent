class Slider 
  constructor: (@node, @config, @reloadBp) ->
    @init()


  reloadAtBp: =>
    enquire.register "screen and (max-width: #{@reloadBp}px)",
    match: =>
      @slider.reloadSlider @sliderConfig
    unmatch: =>
      @slider.reloadSlider @sliderConfig


  init: =>
    if @node.length
      @slider = @node.bxSlider @config or {}

    # if @reloadBp
    #   @reloadAtBp()


StepsList = new Slider(
  $('.prj-steps-list-sec')
  {
    useCSS: off
    pager: off
    nextText: ""
    prevText: ""
  }
  700
)
