Responsive = {

  xs: 480
  sm: 768
  md: 960  

  setRanges: ->
    @ranges = 
      xs: '(max-width:'+@xs+'px)'
      sm: '(min-width:'+@xs+'px) and (max-width:'+(@sm - 1)+'px)'
      md: '(min-width:'+@sm+'px) and (max-width:'+(@md - 1)+'px)'
      lg: '(min-width:'+@md+'px)'
    return this

}.setRanges()


$html = $('html')

for key, val of Responsive.ranges
  fn = (key, val) ->
    enquire.register 'screen and ' + val,
      match: ->
        $html.addClass '' + key

      unmatch: ->
        $html.removeClass '' + key
  fn key, val
