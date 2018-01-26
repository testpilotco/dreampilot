// Generated by CoffeeScript 1.12.7
var BasicApp,
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

BasicApp = (function(superClass) {
  extend(BasicApp, superClass);

  function BasicApp() {
    return BasicApp.__super__.constructor.apply(this, arguments);
  }

  BasicApp.prototype.init = function() {
    console.log('I am the {0} app!'.format('basic'));
    this.someVar = 'some value';
    return this.initVariables();
  };

  BasicApp.prototype.initVariables = function() {
    this.someModel = new myModel();
    this.someModel.set('message', 'Hello I am a model');
    this.mm = new myModel;
    this.mm.set({
      title: 'initial title'
    });
    this.getScope().set({
      assignItOut: function() {
        var i, len, x, y;
        console.log('assignItOut called with args: ', arguments);
        x = 0;
        for (i = 0, len = arguments.length; i < len; i++) {
          y = arguments[i];
          x += y;
        }
        return x;
      },
      letItOut: function() {
        return alert('let it out!');
      }
    });
    this.linkToScope('someMethod', 'mm', ['getRequest', 'postRequest', 'putRequest', 'deleteRequest', 'postPayloadRequest', 'putPayloadRequest', 'deletePayloadRequest', 'showVal1', 'showVal2', 'someModel']);
    setTimeout((function(_this) {
      return function() {
        return _this.getScope().set({
          lolo: 11,
          pepe: 8
        });
      };
    })(this), 2000);
    setTimeout((function(_this) {
      return function() {
        return _this.getScope().set({
          lolo: 5,
          pepe: 8
        });
      };
    })(this), 5000);
    setTimeout((function(_this) {
      return function() {
        return _this.getScope().set({
          lolo: 12,
          pepe: 8
        });
      };
    })(this), 7000);
    return this;
  };

  BasicApp.prototype.showVal1 = function() {
    alert(this.someModel.get('val1'));
    return this;
  };

  BasicApp.prototype.showVal2 = function() {
    alert(this.getScope().get('val2'));
    return this;
  };

  BasicApp.prototype.getRequest = function() {
    $dp.transport.get('/api/controller/method/hey/', {
      id: 100500
    }, function(res) {
      return console.log('get', res);
    });
    return this;
  };

  BasicApp.prototype.postRequest = function() {
    var data;
    data = {
      name: 'James',
      band: 'Metallica'
    };
    $dp.transport.post('/api/controller/method/hey/', data, function(res) {
      return console.log('post', res);
    });
    return this;
  };

  BasicApp.prototype.putRequest = function() {
    var data;
    data = {
      name: 'Kirk',
      band: 'Metallica'
    };
    $dp.transport.put('/api/controller/method/hey/', data, function(res) {
      return console.log('put', res);
    });
    return this;
  };

  BasicApp.prototype.deleteRequest = function() {
    var data;
    data = {
      id: 100500
    };
    $dp.transport["delete"]('/api/controller/method/hey/', data, function(res) {
      return console.log('delete', res);
    });
    return this;
  };

  BasicApp.prototype.postPayloadRequest = function() {
    var data;
    data = {
      name: 'James',
      band: 'Metallica'
    };
    $dp.transport.postPayload('/api/controller/method/hey/', data, function(res) {
      return console.log('post', res);
    });
    return this;
  };

  BasicApp.prototype.putPayloadRequest = function() {
    var data;
    data = {
      name: 'Kirk',
      band: 'Metallica'
    };
    $dp.transport.putPayload('/api/controller/method/hey/', data, function(res) {
      return console.log('put', res);
    });
    return this;
  };

  BasicApp.prototype.deletePayloadRequest = function() {
    var data;
    data = {
      id: 100500
    };
    $dp.transport.deletePayload('/api/controller/method/hey/', data, function(res) {
      return console.log('delete', res);
    });
    return this;
  };

  BasicApp.prototype.someMethod = function(var1, var2) {
    return alert(this.someVar + ', ' + var1 + ', ' + var2);
  };

  return BasicApp;

})(DreamPilot.Application);

//# sourceMappingURL=app.js.map
