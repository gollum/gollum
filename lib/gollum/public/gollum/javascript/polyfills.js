// Polyfill to support Internet Explorer
if (!Array.prototype.includes) {
  Array.prototype.includes = function (x) {
    return 0 <= this.indexOf(x)
  };
}
