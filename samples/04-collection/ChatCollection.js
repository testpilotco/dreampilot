// Generated by CoffeeScript 1.12.7
var ChatCollection,
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

ChatCollection = (function(superClass) {
  extend(ChatCollection, superClass);

  function ChatCollection() {
    return ChatCollection.__super__.constructor.apply(this, arguments);
  }

  ChatCollection.prototype.defineBasics = function() {
    ChatCollection.__super__.defineBasics.call(this);
    this.modelClassName = 'ChatModel';
    return this;
  };

  ChatCollection.prototype.getLoadUrl = function() {
    return 'data.json';
  };

  ChatCollection.prototype.getKeyForLoadedData = function() {
    return 'chat_cues';
  };

  return ChatCollection;

})(DreamPilot.Collection);

//# sourceMappingURL=ChatCollection.js.map
