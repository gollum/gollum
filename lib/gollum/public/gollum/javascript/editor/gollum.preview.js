/**
 *  gollum.preview.js
 *  A jQuery plugin that creates the Gollum Preview.
 *
 *  Usage:
 *  $.GollumPreview(); on DOM ready.
 */
(function($) {

  // Editor options
  var DefaultOptions = {
    MarkupType: 'markdown',
    EditorMode: 'code',
    Debug: false,
    NoDefinitionsFor: [],
    MarkupSource: null,
    PreviewWrapper: null,
    PreviewTargetSelector: null,
    PreviewToggle: null
  };
  var ActiveOptions = {};
  var rendererDefinitions = {};

	$.GollumPreview = function(IncomingOptions) {
    ActiveOptions = $.extend(DefaultOptions, IncomingOptions);

    var renderTimeout, prevTime, elapsedTime, oldContent, formatSelector;

    // --- Get all preview targets

    var previewTarget = function(){
      return $(ActiveOptions.PreviewTargetSelector);
    };

    // --- Link to the format selector

    var formatSelectorInstance = new FormatSelector(
      $,
      $('#gollum-editor-format-selector select'),
      function(newValue){
        ActiveOptions.MarkupType = newValue;
        Renderer.build(true);
      }
    );

    // --- Apply a timeout before rendering

    var applyTimeout = function() {
      if (renderTimeout) {
        clearTimeout(renderTimeout);
        renderTimeout = undefined;
      }

      // 3 second max delay
      if (elapsedTime > 3000) {
        elapsedTime = 3000;
      }

      renderTimeout = setTimeout(Renderer.build, elapsedTime);
    };

    // --- Preview pane

    var PreviewPane = {
      width: '50%',
      side: 'right',
      open: false,

      name: function(){
        return 'gollum-preview-sidr';
      },

      direction: function(){
        return "left";
      },

      setWidth: function(width) {
        this.width = width;
      },

      adjustPaneWidth: function(){
        $('#' + this.name()).width(this.width);
      },

      adjustBodyWidth: function(){
        if (this.open) {
          if (PreviewPane.side == 'right') {
            $('#wiki-wrapper').css({
              marginLeft: 0,
              marginRight: this.width
            });
          }
          if (PreviewPane.side == 'left') {
            $('#wiki-wrapper').css({
              marginLeft: this.width,
              marginRight: 0
            });
          }
        }
        else {
          $('#wiki-wrapper').css({
            marginLeft: 'auto',
            marginRight: 'auto'
          });
        }
      },

      setup: function(){
        ActiveOptions.PreviewToggle.sidr({
          name: PreviewPane.name(),
          side: PreviewPane.side,
          source: '#' + ActiveOptions.PreviewWrapper.attr('id'),
          displace: false,
          renaming: false,

          onOpen: function(){
            PreviewPane.open = true;
            PreviewPane.adjustPaneWidth();
            PreviewPane.adjustBodyWidth();
            Renderer.build(true);
          },

          onClose: function(){
            PreviewPane.open = false;
            PreviewPane.adjustPaneWidth();
            PreviewPane.adjustBodyWidth();
          }
        });

        PreviewPane.adjustPaneWidth();
      }
    };

    // --- Syntax highlighting

    var Highlight = {
    };

    // --- Fragments

    var Fragments = {
      cache: {},

      inject: function(text) {
        var result = this.replace(text);
        var newText = result[0];
        var uncachedFragments = result[1];

        if (uncachedFragments.length > 0) {
          // Async fetch fragments from the server, and when they're cached,
          // re-render the entire preview.
          this.renderRemote(uncachedFragments, function(){
            Renderer.build(true);
          });
        }

        return newText;
      },

      identify: function(text){
        var fragments = [];

        // Gollum links
        var linkMatches = text.match(/\[\[.+\]\]/g);
        if (!!linkMatches && linkMatches.length > 0 && linkMatches[0] != null) {
          fragments = fragments.concat(linkMatches);
        }

        // Custom macros
        var macroMatches = text.match(/<<.+>>/g);
        if (!!macroMatches && macroMatches.length > 0 && macroMatches[0] != null) {
          fragments = fragments.concat(macroMatches);
        }

        return fragments;
      },

      replace: function(text) {
        var fragments = this.identify(text);

        var uncachedFragments = [];

        for (var i = 0; i < fragments.length; i++) {
          var frag = fragments[i];
          if (Fragments.cache[frag]) {
            text = text.replace(frag, Fragments.cache[frag], "g");
          }
          else {
            uncachedFragments.push(frag);
          }
        }

        return [text, uncachedFragments];
      },

      renderRemote: function(fragments, callback) {
        $.ajax({
          url: "../fragments",
          type: "POST",
          accepts: "json",
          data: {
            fragments: fragments,
            page: "Preview",
            format: ActiveOptions.MarkupType
          }
        }).done(function(data, textStatus, jqXhr){
          var rendered = "";

          for (var i = 0; i < data.length; i++) {
            var source = data[i].source;
            Fragments.cache[source] = data[i].destination;
          }

          callback();
        });
      }
    };

    // --- HTML renderer

    var Renderer = {
      getContent: function(){
        var content = "";
        if (!!ActiveOptions.MarkupSource) {
          content = ActiveOptions.MarkupSource.val();
        }
        return content;
      },

      build: function(forceRender){
        if (!forceRender) forceRender = false;

        var text = Renderer.getContent();

        if (!forceRender) {
          if (text == undefined || text == '') {
            // Render empty preview pane.
            Displayer.setPreview('');
            return;
          }

          if (text && text == oldContent) {
            // No need to re-render, just return.
            return;
          }
          else {
            oldContent = text;
          }
        }

        prevTime = (new Date().getTime());

        // Perform our conversion and display here.
        Renderer.render(text);
      },

      hasLocalRenderer: function(){
        return !!rendererDefinitions[ActiveOptions.MarkupType];
      },

      // Run after the markup is rendered.
      // Handles anything that we need to inject into the rendered HTML,
      // like fragments or syntax highlighting.
      preProcess: function(rendered){
        var withFragments = Fragments.inject(rendered);

        return withFragments;
      },

      render: function(markup){
        var callback = function(rendered){
          var finalRendered = Renderer.preProcess(rendered);
          Displayer.setPreview(finalRendered);

          // Calculate the processing time of the HTML creation.
          // It's used as the delay time in the event listener.
          elapsedTime = (new Date().getTime()) - prevTime;
        };

        if (this.hasLocalRenderer()) {
          this.renderLocal(markup, callback);
        }
        else {
          this.renderRemote(markup, callback);
        }
      },

      renderLocal: function(markup, callback) {
        var currentRenderDef = rendererDefinitions[ActiveOptions.MarkupType];

        require([currentRenderDef.path()], function(rendererObj){
          var html = currentRenderDef.render(rendererObj, markup);
          callback(html);
        });
      },

      renderRemote: function(markup, callback) {
        $.ajax({
          url: "../fragments",
          type: "POST",
          accepts: "json",
          data: {
            fragments: [markup],
            page: "Preview",
            format: ActiveOptions.MarkupType
          }
        }).done(function(data, textStatus, jqXhr){

          var rendered = "";
          for (var i = 0; i < data.length; i++) {
            rendered = data[i].destination;
          }

          callback(rendered);

        });
      }
    };

    // --- HTML displaying in preview pane

    var Displayer = {
      chosenPreview: null,
      setPreview: function(markup) {
        if (this.chosenPreview) {
          this.chosenPreview(markup);
          return;
        }

        try {
          this.optimalPreview(markup);
          chosenPreview = this.optimalPreview;
        } catch ( e ) {
          this.fallbackPreview(markup);
          chosenPreview = this.fallbackPreview;
        }
      },

      optimalPreview: function(markup) {
        var targets = $(previewTarget());
        for (var i = 0; i < targets.length; i++) {
          targets[i].innerHTML = markup;
        }
      },

      fallbackPreview: function(markup) {
        // IE doesn't let you use innerHTML if the element is contained somewhere in a table
        // (which is the case for inline editing) -- in that case, detach the element, set the
        // value, and reattach. Yes, that *is* ridiculous.

        var targets = $(previewTarget());
        for (var i = 0; i < targets.length; i++) {
          var content = targets[i];

          var parent = content.parentNode;
          var sibling = content.nextSibling;

          parent.removeChild(content);
          content.innerHTML = markup;

          if (!sibling) {
            parent.appendChild(content);
          }
          else {
            parent.insertBefore(content, sibling);
          }
        }
      }
    };

    // --- Init stuff

    // Bind editor and set up default content
    ActiveOptions.MarkupSource.bind('change keyup', applyTimeout);
    $(document).ready(function(){
      PreviewPane.setup();
      Renderer.build();
    });
  };

  // --- Define a renderer

  $.GollumPreview.defineRenderer = function(language, options){
    rendererDefinitions[language] = options;

    rendererDefinitions[language].path = function(){
      return '../javascript/editor/parsers/' + language + '/' + this.source;
    };

    rendererDefinitions[language].render = function(container, markup){
      if (!container) {
        container = window
      };

      var runSplit = this.runner.split(".");
      var func = container;
      var referencePoint = null;

      for (var i = 0; i < runSplit.length; i++) {
        func = func[runSplit[i]];
        if (i == 0) {
          var referencePoint = func;
        }
      }

      return func.call(referencePoint, markup);
    };
  };

})(jQuery);
