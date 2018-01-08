// Generated by CoffeeScript 1.12.7
var myModel,
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

myModel = (function(superClass) {
  extend(myModel, superClass);

  function myModel() {
    return myModel.__super__.constructor.apply(this, arguments);
  }

  myModel.prototype.add = function(x) {
    console.log(x, 'added');
    return this;
  };

  return myModel;

})(DreamPilot.Model);

//# sourceMappingURL=myModel.js.map
