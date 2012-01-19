 # lightbox
 #
 # :copyright: 2011, Marten Klitzke <m.klitze@gmail.com>
 # :license: GPL
 #
$.widget 'ui.lightbox',

  options:
    boxId: 'lightbox'
    closeButtonId: 'hideBox'
    wrapperId: 'lightbox-wrapper'
    bgId: 'lightbox-bg'
    action: false
    drag: true
    data: {}
    method: 'GET'
    beforeLoad: (element, lightbox) ->
    afterLoad: (lightbox) ->
    afterClose: (lightbox) ->

  _create: ->
    #create wrapper if not allready present
    if $('#' + @options.wrapperId).length is 0
      @options.$wrapper = $('<div/>',
        id: @options.wrapperId
      ).appendTo 'body'
    else
      @options.$wrapper = $ '#' + @options.wrapperId

    #create bg if not allready present
    if $('#' + @options.bgId).length is 0
      @options.$bg = $('<div/>',
        id: @options.bgId
      ).appendTo 'body'
    else
      @options.$bg = $ '#' + @options.bgId

  _init: ->
    that = @

    @element.click ->
      #append id to data array
      if $(@).attr('id')
        that.options.data.element_id = $(@).attr('id').split('_')[1]

      #before load callback
      that.options.beforeLoad @, that

      #get action from href if action isn't allready set via options
      if $(@).attr('href').length isnt 0 && !that.options.action
        that.options.action = $(@).attr 'href'

      #load lightbox
      that._load()
      false

  _load: ->
    that = @

    #fade in wrapper and bg
    @options.$wrapper.css('height',$(document).height()+'px').fadeIn 'slow'
    @options.$bg.css('height', $(document).height() + 'px').fadeIn 'slow'

    #if action is set load lightbox data
    if @options.action
      $.ajax
        url: @options.action
        data: @options.data
        complete: (jqXHR, textStatus) ->
          #put response in wrapper
          that.options.$wrapper.html jqXHR.responseText

          #get top position for lightbox orientation
          top = $(window).scrollTop() + ($(window).height()*25/100)

          #fade in lightbox
          $('#' + that.options.boxId).css('top', top + 'px').fadeIn 'slow'

          #after load callback
          that.options.afterLoad that

          #init lightbox
          that._initBox()

        dataType: that.options.method

  _initBox: ->
    that = @

    #draggable box?
    if @options.drag
      $('#' + @options.boxId).draggable { handle: 'header' }

    #init click next to the box
    @options.$wrapper.click ->
      that.close()

    #prevent clicks on the lightbox to close the box
    $('#' + @options.boxId).click (e) ->
      e.stopPropagation()

    #init close button
    $('#' + @options.closeButtonId).click ->
      that.close()
      false

  close: ->
    that = @

    #fade box out
    $('#' + @options.boxId).fadeOut 'slow', ->
      #fade out wrapper
      that.options.$wrapper.fadeOut 'slow'

      #fade out bg
      that.options.$bg.fadeOut 'slow'

      #remove the box
      $(@).remove()

      #unbind wrapper
      that.options.$wrapper.unbind()

      #after close callback
      that.options.afterClose that

  destroy: ->
    #unbind element
    @element.unbind 'click'

    #remove bg
    @options.$bg.remove()

    #remove wrapper
    @options.$wrapper.remove()