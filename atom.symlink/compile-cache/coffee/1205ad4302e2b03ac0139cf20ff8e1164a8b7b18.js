(function() {
  var concatPattern, isClosingTagLikePattern, isOpeningTagLikePattern, isTagLikePattern,
    __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  concatPattern = /\s*[\s,|]+\s*/g;

  isTagLikePattern = /<(?![\!\/])([a-z]{1}[^>\s]*)/i;

  isOpeningTagLikePattern = /<(?![\!\/])([a-z]{1}[^>\s]*)/i;

  isClosingTagLikePattern = /<\/([a-z]{1}[^>\s]*)/i;

  module.exports = {
    neverClose: [],
    forceInline: [],
    forceBlock: [],
    makeNeverCLoseSelfClosing: false,
    ignoreGrammar: false,
    configDefaults: {
      closeOnEndOfOpeningTag: false,
      neverClose: 'br, hr, img, input, link, meta, area, base, col, command, embed, keygen, param, source, track, wbr',
      makeNeverCloseElementsSelfClosing: false,
      forceInline: 'title, h1, h2, h3, h4, h5, h6',
      forceBlock: '',
      ignoreGrammar: false
    },
    activate: function() {
      atom.config.observe('autoclose-html.neverClose', {
        callNow: true
      }, (function(_this) {
        return function(value) {
          return _this.neverClose = value.split(concatPattern);
        };
      })(this));
      atom.config.observe('autoclose-html.forceInline', {
        callNow: true
      }, (function(_this) {
        return function(value) {
          return _this.forceInline = value.split(concatPattern);
        };
      })(this));
      atom.config.observe('autoclose-html.forceBlock', {
        callNow: true
      }, (function(_this) {
        return function(value) {
          return _this.forceBlock = value.split(concatPattern);
        };
      })(this));
      atom.config.observe('autoclose-html.makeNeverCloseElementsSelfClosing', {
        callNow: true
      }, (function(_this) {
        return function(value) {
          return _this.makeNeverCLoseSelfClosing = value;
        };
      })(this));
      atom.config.observe('autoclose-html.ignoreGrammar', {
        callNow: true
      }, (function(_this) {
        return function(value) {
          _this.ignoreGrammar = value;
          return atom.workspaceView.eachEditorView(function(editorView) {
            return editorView.trigger('editor:grammar-changed');
          });
        };
      })(this));
      return this._events();
    },
    isInline: function(eleTag) {
      var ele, ret, _ref, _ref1, _ref2;
      ele = document.createElement(eleTag);
      if (_ref = eleTag.toLowerCase(), __indexOf.call(this.forceBlock, _ref) >= 0) {
        return false;
      } else if (_ref1 = eleTag.toLowerCase(), __indexOf.call(this.forceInline, _ref1) >= 0) {
        return true;
      }
      document.body.appendChild(ele);
      ret = (_ref2 = window.getComputedStyle(ele).getPropertyValue('display')) === 'inline' || _ref2 === 'inline-block' || _ref2 === 'none';
      document.body.appendChild(ele);
      return ret;
    },
    isNeverClosed: function(eleTag) {
      var _ref;
      return _ref = eleTag.toLowerCase(), __indexOf.call(this.neverClose, _ref) >= 0;
    },
    execAutoclose: function(changedEvent) {
      var eleTag, isInline, line, matches, partial;
      if (changedEvent.newText === '>') {
        line = atom.workspaceView.getActiveView().editor.buffer.getLines()[changedEvent.newRange.end.row];
        partial = line.substr(0, changedEvent.newRange.start.column);
        if (partial.substr(partial.length - 1, 1) === '/') {
          return;
        }
        if ((matches = partial.substr(partial.lastIndexOf('<')).match(isOpeningTagLikePattern)) == null) {
          return;
        }
        eleTag = matches[matches.length - 1];
        if (this.isNeverClosed(eleTag)) {
          if (this.makeNeverCLoseSelfClosing) {
            setTimeout(function() {
              var tag;
              tag = '/>';
              if (partial.substr(partial.length - 1, 1 !== ' ')) {
                tag = ' ' + tag;
              }
              atom.workspace.activePaneItem.backspace();
              return atom.workspace.activePaneItem.insertText(tag);
            });
          }
          return;
        }
        isInline = this.isInline(eleTag);
        return setTimeout(function() {
          if (!isInline) {
            atom.workspace.activePaneItem.insertNewline();
            atom.workspace.activePaneItem.insertNewline();
          }
          atom.workspace.activePaneItem.insertText('</' + eleTag + '>');
          if (isInline) {
            return atom.workspace.activePaneItem.setCursorBufferPosition(changedEvent.newRange.end);
          } else {
            atom.workspace.activePaneItem.autoIndentBufferRow(changedEvent.newRange.end.row + 1);
            return atom.workspace.activePaneItem.setCursorBufferPosition([changedEvent.newRange.end.row + 1, atom.workspace.activePaneItem.getTabText().length * atom.workspace.activePaneItem.indentationForBufferRow(changedEvent.newRange.end.row + 1)]);
          }
        });
      }
    },
    _events: function() {
      var fcn;
      fcn = (function(_this) {
        return function(e) {
          if ((e != null ? e.newText : void 0) === '>') {
            return _this.execAutoclose(e);
          }
        };
      })(this);
      return atom.workspaceView.eachEditorView((function(_this) {
        return function(editorView) {
          editorView.command('editor:grammar-changed', {}, function() {
            var grammar, _ref;
            grammar = editorView.editor.getGrammar();
            if (((_ref = grammar.name) != null ? _ref.length : void 0) > 0 && (_this.ignoreGrammar || grammar.name === 'HTML')) {
              editorView.editor.buffer.off('changed', fcn);
              return editorView.editor.buffer.on('changed', fcn);
            } else {
              return editorView.editor.buffer.off('changed', fcn);
            }
          });
          return editorView.trigger('editor:grammar-changed');
        };
      })(this));
    }
  };

}).call(this);

//# sourceMappingURL=data:application/json;base64,ewogICJ2ZXJzaW9uIjogMywKICAiZmlsZSI6ICIiLAogICJzb3VyY2VSb290IjogIiIsCiAgInNvdXJjZXMiOiBbCiAgICAiIgogIF0sCiAgIm5hbWVzIjogW10sCiAgIm1hcHBpbmdzIjogIkFBQ0E7QUFBQSxNQUFBLGlGQUFBO0lBQUEscUpBQUE7O0FBQUEsRUFBQSxhQUFBLEdBQWdCLGdCQUFoQixDQUFBOztBQUFBLEVBQ0EsZ0JBQUEsR0FBbUIsK0JBRG5CLENBQUE7O0FBQUEsRUFFQSx1QkFBQSxHQUEwQiwrQkFGMUIsQ0FBQTs7QUFBQSxFQUdBLHVCQUFBLEdBQTBCLHVCQUgxQixDQUFBOztBQUFBLEVBS0EsTUFBTSxDQUFDLE9BQVAsR0FFSTtBQUFBLElBQUEsVUFBQSxFQUFXLEVBQVg7QUFBQSxJQUNBLFdBQUEsRUFBYSxFQURiO0FBQUEsSUFFQSxVQUFBLEVBQVksRUFGWjtBQUFBLElBR0EseUJBQUEsRUFBMkIsS0FIM0I7QUFBQSxJQUlBLGFBQUEsRUFBZSxLQUpmO0FBQUEsSUFLQSxjQUFBLEVBRUk7QUFBQSxNQUFBLHNCQUFBLEVBQXdCLEtBQXhCO0FBQUEsTUFDQSxVQUFBLEVBQVksb0dBRFo7QUFBQSxNQUVBLGlDQUFBLEVBQW1DLEtBRm5DO0FBQUEsTUFHQSxXQUFBLEVBQWEsK0JBSGI7QUFBQSxNQUlBLFVBQUEsRUFBWSxFQUpaO0FBQUEsTUFLQSxhQUFBLEVBQWUsS0FMZjtLQVBKO0FBQUEsSUFjQSxRQUFBLEVBQVUsU0FBQSxHQUFBO0FBRU4sTUFBQSxJQUFJLENBQUMsTUFBTSxDQUFDLE9BQVosQ0FBb0IsMkJBQXBCLEVBQWlEO0FBQUEsUUFBQSxPQUFBLEVBQVEsSUFBUjtPQUFqRCxFQUErRCxDQUFBLFNBQUEsS0FBQSxHQUFBO2VBQUEsU0FBQyxLQUFELEdBQUE7aUJBQzNELEtBQUMsQ0FBQSxVQUFELEdBQWMsS0FBSyxDQUFDLEtBQU4sQ0FBWSxhQUFaLEVBRDZDO1FBQUEsRUFBQTtNQUFBLENBQUEsQ0FBQSxDQUFBLElBQUEsQ0FBL0QsQ0FBQSxDQUFBO0FBQUEsTUFH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
//# sourceURL=/Users/leo/.dotfiles/atom.symlink/packages/autoclose-html/lib/autoclose-html.coffee