Raphael.el.animateAlong = function(params, ms, easing, callback) {
  var element = this,
    paper = element.paper,
    guide = params.guide,
    rotate = params.rotate,
    existing = typeof guide !== 'string';

  element.guide = existing ?
      guide :
      paper.path(guide).attr({'stroke':'rgba(0,0,0,0)', 'stroke-width': 0});
  element.guideLen = element.guide.getTotalLength();
  element.guideRotate = rotate;

  !paper.customAttributes.along && (paper.customAttributes.along = function(v) {
    var point = this.guide.getPointAtLength(v * this.guideLen);
    return {
      transform: "t" + [point.x, point.y] + (this.guideRotate ? "r" + point.alpha : "")
    };
  });

  params.along = 1;
  element.attr({along: 0}).animate(params, ms, easing, function() {
    !existing && element.guide.remove();
    callback && callback.call(element);
  });
};
