$ = require 'jquery'
_ = require 'underscore'
Backbone = require 'backbone'

utils = require './utils.coffee'

template = _.template '''
<div class="options">
  <div>
  <button class="link">a</button>
  <button class="bold">b</button>
  <button class="italic">i</button>
  <button class="underline">u</button>
  <button class="header">h</button>
  <button class="quote">“</button>
  <button class="comment">c</button>
  </div>
</div>
'''

PopupView = Backbone.View.extend
  template: template
  tagName: 'div'
  className: 'white-popup hidden'
  initialize: ->
    @render()
  render: _.once ->
    @$el.html(@template())
    $(document.body).append(@el)
  moveTo: (x, y) ->
    y -= @$el.height() + 5
    @$el.offset {left:x, top:y}
  toggleDisplay: utils.debounce 300, (show, x, y) ->
    if show and @$el.hasClass('hidden')
      @moveTo x, y
      @$el.removeClass('hidden')
    else
      @$el.addClass('hidden')
      utils.delay 250, =>
        @toggleDisplay(show, x, y) if show
        @moveTo -999, -999
  showAtPoint: (x, y) ->
    @toggleDisplay true, x, y
  hide: ->
    @toggleDisplay false

module.exports = PopupView
