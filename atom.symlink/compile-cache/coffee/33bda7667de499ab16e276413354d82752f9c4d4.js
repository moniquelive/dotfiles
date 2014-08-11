(function() {
  var Range, RangeFinder;

  Range = require('atom').Range;

  module.exports = RangeFinder = (function() {
    RangeFinder.rangesFor = function(editor) {
      return new RangeFinder(editor).ranges();
    };

    function RangeFinder(editor) {
      this.editor = editor;
    }

    RangeFinder.prototype.ranges = function() {
      var selectionRanges;
      selectionRanges = this.selectionRanges();
      if (selectionRanges.length === 0) {
        return [this.sortableRangeFrom(this.sortableRangeForEntireBuffer())];
      } else {
        return selectionRanges.map((function(_this) {
          return function(selectionRange) {
            return _this.sortableRangeFrom(selectionRange);
          };
        })(this));
      }
    };

    RangeFinder.prototype.selectionRanges = function() {
      return this.editor.getSelectedBufferRanges().filter(function(range) {
        return !range.isEmpty();
      });
    };

    RangeFinder.prototype.sortableRangeForEntireBuffer = function() {
      return this.editor.getBuffer().getRange();
    };

    RangeFinder.prototype.sortableRangeFrom = function(selectionRange) {
      var endCol, endRow, startCol, startRow;
      startRow = selectionRange.start.row;
      startCol = 0;
      endRow = selectionRange.end.column === 0 ? selectionRange.end.row - 1 : selectionRange.end.row;
      endCol = this.editor.lineLengthForBufferRow(endRow);
      return new Range([startRow, startCol], [endRow, endCol]);
    };

    return RangeFinder;

  })();

}).call(this);

//# sourceMappingURL=data:application/json;base64,ewogICJ2ZXJzaW9uIjogMywKICAiZmlsZSI6ICIiLAogICJzb3VyY2VSb290IjogIiIsCiAgInNvdXJjZXMiOiBbCiAgICAiIgogIF0sCiAgIm5hbWVzIjogW10sCiAgIm1hcHBpbmdzIjogIkFBQUE7QUFBQSxNQUFBLGtCQUFBOztBQUFBLEVBQUMsUUFBUyxPQUFBLENBQVEsTUFBUixFQUFULEtBQUQsQ0FBQTs7QUFBQSxFQUVBLE1BQU0sQ0FBQyxPQUFQLEdBQ007QUFFSixJQUFBLFdBQUMsQ0FBQSxTQUFELEdBQVksU0FBQyxNQUFELEdBQUE7YUFDTixJQUFBLFdBQUEsQ0FBWSxNQUFaLENBQW1CLENBQUMsTUFBcEIsQ0FBQSxFQURNO0lBQUEsQ0FBWixDQUFBOztBQUlhLElBQUEscUJBQUUsTUFBRixHQUFBO0FBQVcsTUFBVixJQUFDLENBQUEsU0FBQSxNQUFTLENBQVg7SUFBQSxDQUpiOztBQUFBLDBCQU9BLE1BQUEsR0FBUSxTQUFBLEdBQUE7QUFDTixVQUFBLGVBQUE7QUFBQSxNQUFBLGVBQUEsR0FBa0IsSUFBQyxDQUFBLGVBQUQsQ0FBQSxDQUFsQixDQUFBO0FBQ0EsTUFBQSxJQUFHLGVBQWUsQ0FBQyxNQUFoQixLQUEwQixDQUE3QjtlQUNFLENBQUMsSUFBQyxDQUFBLGlCQUFELENBQW1CLElBQUMsQ0FBQSw0QkFBRCxDQUFBLENBQW5CLENBQUQsRUFERjtPQUFBLE1BQUE7ZUFHRSxlQUFlLENBQUMsR0FBaEIsQ0FBb0IsQ0FBQSxTQUFBLEtBQUEsR0FBQTtpQkFBQSxTQUFDLGNBQUQsR0FBQTttQkFDbEIsS0FBQyxDQUFBLGlCQUFELENBQW1CLGNBQW5CLEVBRGtCO1VBQUEsRUFBQTtRQUFBLENBQUEsQ0FBQSxDQUFBLElBQUEsQ0FBcEIsRUFIRjtPQUZNO0lBQUEsQ0FQUixDQUFBOztBQUFBLDBCQWdCQSxlQUFBLEdBQWlCLFNBQUEsR0FBQTthQUNmLElBQUMsQ0FBQSxNQUFNLENBQUMsdUJBQVIsQ0FBQSxDQUFpQyxDQUFDLE1BQWxDLENBQXlDLFNBQUMsS0FBRCxHQUFBO2VBQ3ZDLENBQUEsS0FBUyxDQUFDLE9BQU4sQ0FBQSxFQURtQztNQUFBLENBQXpDLEVBRGU7SUFBQSxDQWhCakIsQ0FBQTs7QUFBQSwwQkFxQkEsNEJBQUEsR0FBOEIsU0FBQSxHQUFBO2FBQzVCLElBQUMsQ0FBQSxNQUFNLENBQUMsU0FBUixDQUFBLENBQW1CLENBQUMsUUFBcEIsQ0FBQSxFQUQ0QjtJQUFBLENBckI5QixDQUFBOztBQUFBLDBCQXlCQSxpQkFBQSxHQUFtQixTQUFDLGNBQUQsR0FBQTtBQUNqQixVQUFBLGtDQUFBO0FBQUEsTUFBQSxRQUFBLEdBQVcsY0FBYyxDQUFDLEtBQUssQ0FBQyxHQUFoQyxDQUFBO0FBQUEsTUFDQSxRQUFBLEdBQVcsQ0FEWCxDQUFBO0FBQUEsTUFFQSxNQUFBLEdBQVksY0FBYyxDQUFDLEdBQUcsQ0FBQyxNQUFuQixLQUE2QixDQUFoQyxHQUNQLGNBQWMsQ0FBQyxHQUFHLENBQUMsR0FBbkIsR0FBeUIsQ0FEbEIsR0FHUCxjQUFjLENBQUMsR0FBRyxDQUFDLEdBTHJCLENBQUE7QUFBQSxNQU1BLE1BQUEsR0FBUyxJQUFDLENBQUEsTUFBTSxDQUFDLHNCQUFSLENBQStCLE1BQS9CLENBTlQsQ0FBQTthQVFJLElBQUEsS0FBQSxDQUFNLENBQUMsUUFBRCxFQUFXLFFBQVgsQ0FBTixFQUE0QixDQUFDLE1BQUQsRUFBUyxNQUFULENBQTVCLEVBVGE7SUFBQSxDQXpCbkIsQ0FBQTs7dUJBQUE7O01BTEYsQ0FBQTtBQUFBIgp9
//# sourceURL=/Users/leo/.dotfiles/atom.symlink/packages/sort-lines/lib/range-finder.coffee