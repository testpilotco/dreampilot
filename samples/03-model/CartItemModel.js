// Generated by CoffeeScript 1.12.7
var CartItemModel,
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

CartItemModel = (function(superClass) {
  extend(CartItemModel, superClass);

  function CartItemModel() {
    return CartItemModel.__super__.constructor.apply(this, arguments);
  }

  CartItemModel.prototype.shout = function(prefix, element) {
    alert(prefix + ' [' + this.get('count') + ']');
    return console.log(element);
  };

  CartItemModel.prototype.getDeleteUrl = function() {
    return '/api/cart/item/' + this.get('id') + '/';
  };

  return CartItemModel;

})(DreamPilot.Model);

//# sourceMappingURL=CartItemModel.js.map
