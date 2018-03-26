// Generated by CoffeeScript 1.12.7
var CollectionApp,
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

CollectionApp = (function(superClass) {
  extend(CollectionApp, superClass);

  function CollectionApp() {
    return CollectionApp.__super__.constructor.apply(this, arguments);
  }

  CollectionApp.prototype.init = function() {
    this.m = new DreamPilot.Model().set({
      id: 100500
    });
    this.users = new UserCollection().setApp(this);
    setTimeout((function(_this) {
      return function() {
        _this.users.addItem({
          id: 1,
          name: 'James',
          nick: 'Papa'
        }).addItem({
          id: 2,
          name: 'Lars',
          nick: 'Danish'
        });
        return _this.col.map(function(cue) {
          return cue.linkUser();
        });
      };
    })(this), 500);
    this.loadChat().linkToScope(['chatClick', 'col', 'm', 'btnClick']);
    this.getScope().set({
      isTiny: true
    });
    this.testModel = new ChatModel().onFetch(function(result) {
      return console.log('fetched', result);
    }).fetch();
    return this;
  };

  CollectionApp.prototype.getUsersCol = function() {
    return this.users;
  };

  CollectionApp.prototype.loadChat = function() {
    this.col = new ChatCollection().setApp(this).onLoad(function(col) {
      var filteredCol;
      col.map(function(model) {
        return model.display().displayEmbraced();
      });
      filteredCol = col.filter(function(model) {
        return model.getName() === 'James';
      });
      return filteredCol.map(function(model) {
        return model.displayFiltered();
      });
    }).load();
    return this;
  };

  CollectionApp.prototype.btnClick = function() {
    var $z;
    $z = $dp.e("<div dp-value-read-from=\"m.id\" style=\"background: yellow; padding: 10px;\"></div>").appendTo(document.body);
    this.embraceDomElement($z);
    console.log(this.col);
    this.col.removeItem('5a6207e9a069b208bc0063b7');
    console.log(this.col);
    return this;
  };

  CollectionApp.prototype.chatClick = function(el, event) {
    console.log('chatClick', el, event, this.col.getItems());
    return this;
  };

  return CollectionApp;

})(DreamPilot.Application);

//# sourceMappingURL=CollectionApp.js.map
