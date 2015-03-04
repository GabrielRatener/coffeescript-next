
GLOBAL.Promise = require('./test/promise');

var await = function(promise){
  this.promise = promise;
  this.constructor = await;
}

var async = function (fn) {
  return function () {
    function resolved(res) { return next(gen.next(res)); }
    function rejected(err) { return next(gen.throw(err)); }
    function next(ret){
      var val = ret.value;
      if (ret.done) {
        return Promise.resolve(val);
      } else try {
        return val.promise.then(resolved, rejected);
      } catch (_) {
        throw new Error('Expected Promise/A+');
      }
    }
    
    var gen = fn.apply(this, arguments);
    try {
      return resolved();
    } catch (e) {
      return Promise.reject(e);
    }
  };
}

var afunc = async(function*(a, b){
  var c = yield new await(Promise.resolve(a));
  var d = yield new await(Promise.resolve(b));
  return [c, d];
});

var a;
async(function*(){
  a = yield new await(afunc(2, 3));
})();
console.log(a);
