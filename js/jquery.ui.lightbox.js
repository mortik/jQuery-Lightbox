(function() {

  $.widget('ui.lightbox', {
    options: {
      boxId: 'lightbox',
      closeButtonId: 'hideBox',
      wrapperId: 'lightbox-wrapper',
      bgId: 'lightbox-bg',
      action: false,
      drag: true,
      data: {},
      method: 'GET',
      beforeLoad: function(element, lightbox) {},
      afterLoad: function(lightbox) {},
      afterClose: function(lightbox) {}
    },
    _create: function() {
      if ($('#' + this.options.wrapperId).length === 0) {
        this.options.$wrapper = $('<div/>', {
          id: this.options.wrapperId
        }).appendTo('body');
      } else {
        this.options.$wrapper = $('#' + this.options.wrapperId);
      }
      if ($('#' + this.options.bgId).length === 0) {
        return this.options.$bg = $('<div/>', {
          id: this.options.bgId
        }).appendTo('body');
      } else {
        return this.options.$bg = $('#' + this.options.bgId);
      }
    },
    _init: function() {
      var that;
      that = this;
      return this.element.click(function() {
        if ($(this).attr('id')) {
          that.options.data.element_id = $(this).attr('id').split('_')[1];
        }
        that.options.beforeLoad(this, that);
        if ($(this).attr('href').length !== 0 && !that.options.action) {
          that.options.action = $(this).attr('href');
        }
        that._load();
        return false;
      });
    },
    _load: function() {
      var that;
      that = this;
      this.options.$wrapper.css('height', $(document).height() + 'px').fadeIn('slow');
      this.options.$bg.css('height', $(document).height() + 'px').fadeIn('slow');
      if (this.options.action) {
        return $.ajax({
          url: this.options.action,
          data: this.options.data,
          complete: function(jqXHR, textStatus) {
            var top;
            that.options.$wrapper.html(jqXHR.responseText);
            top = $(window).scrollTop() + ($(window).height() * 25 / 100);
            $('#' + that.options.boxId).css('top', top + 'px').fadeIn('slow');
            that.options.afterLoad(that);
            return that._initBox();
          },
          dataType: "json",
          type: that.options.method
        });
      }
    },
    _initBox: function() {
      var that;
      that = this;
      if (this.options.drag) {
        $('#' + this.options.boxId).draggable({
          handle: 'header'
        });
      }
      this.options.$wrapper.click(function() {
        return that.close();
      });
      $('#' + this.options.boxId).click(function(e) {
        return e.stopPropagation();
      });
      return $('#' + this.options.closeButtonId).click(function() {
        that.close();
        return false;
      });
    },
    close: function() {
      var that;
      that = this;
      return $('#' + this.options.boxId).fadeOut('slow', function() {
        that.options.$wrapper.fadeOut('slow');
        that.options.$bg.fadeOut('slow');
        $(this).remove();
        that.options.$wrapper.unbind();
        return that.options.afterClose(that);
      });
    },
    destroy: function() {
      this.element.unbind('click');
      this.options.$bg.remove();
      return this.options.$wrapper.remove();
    }
  });

}).call(this);
