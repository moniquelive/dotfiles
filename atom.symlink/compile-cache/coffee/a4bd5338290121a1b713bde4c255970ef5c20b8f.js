(function() {
  var RangeFinder, sortLines, sortLinesInsensitive, sortLinesReversed, uniqueLines;

  RangeFinder = require('./range-finder');

  module.exports = {
    activate: function() {
      atom.workspaceView.command('sort-lines:sort', '.editor', function() {
        var editor;
        editor = atom.workspace.getActiveEditor();
        return sortLines(editor);
      });
      atom.workspaceView.command('sort-lines:reverse-sort', '.editor', function() {
        var editor;
        editor = atom.workspace.getActiveEditor();
        return sortLinesReversed(editor);
      });
      atom.workspaceView.command('sort-lines:unique', '.editor', function() {
        var editor;
        editor = atom.workspace.getActiveEditor();
        return uniqueLines(editor);
      });
      return atom.workspaceView.command('sort-lines:case-insensitive-sort', '.editor', function() {
        var editor;
        editor = atom.workspaceView.getActivePaneItem();
        return sortLinesInsensitive(editor);
      });
    }
  };

  sortLines = function(editor) {
    var sortableRanges;
    sortableRanges = RangeFinder.rangesFor(editor);
    return sortableRanges.forEach(function(range) {
      var textLines;
      textLines = editor.getTextInBufferRange(range).split("\n");
      textLines.sort(function(a, b) {
        return a.localeCompare(b);
      });
      return editor.setTextInBufferRange(range, textLines.join("\n"));
    });
  };

  sortLinesReversed = function(editor) {
    var sortableRanges;
    sortableRanges = RangeFinder.rangesFor(editor);
    return sortableRanges.forEach(function(range) {
      var textLines;
      textLines = editor.getTextInBufferRange(range).split("\n");
      textLines.sort(function(a, b) {
        return b.localeCompare(a);
      });
      return editor.setTextInBufferRange(range, textLines.join("\n"));
    });
  };

  uniqueLines = function(editor) {
    var sortableRanges;
    sortableRanges = RangeFinder.rangesFor(editor);
    return sortableRanges.forEach(function(range) {
      var textLines, uniqued;
      textLines = editor.getTextInBufferRange(range).split("\n");
      uniqued = textLines.filter(function(value, index, self) {
        return self.indexOf(value) === index;
      });
      return editor.setTextInBufferRange(range, uniqued.join("\n"));
    });
  };

  sortLinesInsensitive = function(editor) {
    var sortableRanges;
    sortableRanges = RangeFinder.rangesFor(editor);
    return sortableRanges.forEach(function(range) {
      var textLines;
      textLines = editor.getTextInBufferRange(range).split("\n");
      textLines.sort(function(a, b) {
        return a.toLowerCase().localeCompare(b.toLowerCase());
      });
      return editor.setTextInBufferRange(range, textLines.join("\n"));
    });
  };

}).call(this);

//# sourceMappingURL=data:application/json;base64,ewogICJ2ZXJzaW9uIjogMywKICAiZmlsZSI6ICIiLAogICJzb3VyY2VSb290IjogIiIsCiAgInNvdXJjZXMiOiBbCiAgICAiIgogIF0sCiAgIm5hbWVzIjogW10sCiAgIm1hcHBpbmdzIjogIkFBQUE7QUFBQSxNQUFBLDRFQUFBOztBQUFBLEVBQUEsV0FBQSxHQUFjLE9BQUEsQ0FBUSxnQkFBUixDQUFkLENBQUE7O0FBQUEsRUFFQSxNQUFNLENBQUMsT0FBUCxHQUNFO0FBQUEsSUFBQSxRQUFBLEVBQVUsU0FBQSxHQUFBO0FBQ1IsTUFBQSxJQUFJLENBQUMsYUFBYSxDQUFDLE9BQW5CLENBQTJCLGlCQUEzQixFQUE4QyxTQUE5QyxFQUF5RCxTQUFBLEdBQUE7QUFDdkQsWUFBQSxNQUFBO0FBQUEsUUFBQSxNQUFBLEdBQVMsSUFBSSxDQUFDLFNBQVMsQ0FBQyxlQUFmLENBQUEsQ0FBVCxDQUFBO2VBQ0EsU0FBQSxDQUFVLE1BQVYsRUFGdUQ7TUFBQSxDQUF6RCxDQUFBLENBQUE7QUFBQSxNQUlBLElBQUksQ0FBQyxhQUFhLENBQUMsT0FBbkIsQ0FBMkIseUJBQTNCLEVBQXNELFNBQXRELEVBQWlFLFNBQUEsR0FBQTtBQUMvRCxZQUFBLE1BQUE7QUFBQSxRQUFBLE1BQUEsR0FBUyxJQUFJLENBQUMsU0FBUyxDQUFDLGVBQWYsQ0FBQSxDQUFULENBQUE7ZUFDQSxpQkFBQSxDQUFrQixNQUFsQixFQUYrRDtNQUFBLENBQWpFLENBSkEsQ0FBQTtBQUFBLE1BUUEsSUFBSSxDQUFDLGFBQWEsQ0FBQyxPQUFuQixDQUEyQixtQkFBM0IsRUFBZ0QsU0FBaEQsRUFBMkQsU0FBQSxHQUFBO0FBQ3pELFlBQUEsTUFBQTtBQUFBLFFBQUEsTUFBQSxHQUFTLElBQUksQ0FBQyxTQUFTLENBQUMsZUFBZixDQUFBLENBQVQsQ0FBQTtlQUNBLFdBQUEsQ0FBWSxNQUFaLEVBRnlEO01BQUEsQ0FBM0QsQ0FSQSxDQUFBO2FBWUEsSUFBSSxDQUFDLGFBQWEsQ0FBQyxPQUFuQixDQUEyQixrQ0FBM0IsRUFBK0QsU0FBL0QsRUFB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
//# sourceURL=/Users/leo/.dotfiles/atom.symlink/packages/sort-lines/lib/sort-lines.coffee