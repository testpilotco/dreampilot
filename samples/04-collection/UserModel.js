// Generated by CoffeeScript 1.12.7
var UserModel,
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

UserModel = (function(superClass) {
  extend(UserModel, superClass);

  function UserModel() {
    return UserModel.__super__.constructor.apply(this, arguments);
  }

  UserModel.prototype.getName = function() {
    return this.get('name');
  };

  return UserModel;

})(DreamPilot.Model);

//# sourceMappingURL=UserModel.js.map
