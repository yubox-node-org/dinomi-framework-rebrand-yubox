var canvas = document.querySelector("#loginanimation");
var context = canvas.getContext("2d"),
    width = canvas.width,
    height = canvas.height;

var isocontext = isometric(context);
isocontext.scale3d(30, 30, 30);

d3_timer.timer(function(elapsed) {
  context.save();
  context.clearRect(0, 0, width, height);
  context.fillStyle = "#fff";
  context.strokeStyle = "#eaeaea";
  context.translate(width / 2, height * 0.6);
  for (var x = 10, d, t = (elapsed / 3500) % 1; x >= -10; --x) {
    for (var y = 10; y >= -10; --y) {
      if ((d = distanceManhattan(x, y)) > 10) continue;
      var te = d3_ease.easeCubic(Math.max(0, Math.min(1, t * 3.3 - distanceCartesian(x, y) / 4)));
      drawCube((d & 1 ? -1 : +1) * (Math.PI / 4 - te * Math.PI / 2), x * 2, y * 2, 2 * te);
    }
  }
  context.restore();
});

function distanceCartesian(x, y) {
  return Math.sqrt(x * x + y * y);
}

function distanceManhattan(x, y) {
  return Math.abs(x) + Math.abs(y);
}

function drawCube(angle, x, y, z) {
  if ((angle %= Math.PI / 2) < 0) angle += Math.PI / 2;
  isocontext.save();
  isocontext.translate3d(x, y, z);
  isocontext.rotateZ(angle - Math.PI / 4);

  context.beginPath();
  isocontext.moveTo(+0.5, -0.5, +0.5);
  isocontext.lineTo(+0.5, +0.5, +0.5);
  isocontext.lineTo(-0.5, +0.5, +0.5);
  isocontext.lineTo(-0.5, +0.5, -0.5);
  isocontext.lineTo(-0.5, -0.5, -0.5);
  isocontext.lineTo(+0.5, -0.5, -0.5);
  isocontext.closePath();
  context.fill();
  context.lineWidth = 1.5;
  context.stroke();

  context.beginPath();
  isocontext.moveTo(-0.5, -0.5, +0.5);
  isocontext.lineTo(+0.5, -0.5, +0.5);
  isocontext.moveTo(-0.5, -0.5, +0.5);
  isocontext.lineTo(-0.5, +0.5, +0.5);
  isocontext.moveTo(-0.5, -0.5, +0.5);
  isocontext.lineTo(-0.5, -0.5, -0.5);
  context.lineWidth = 0.75;
  context.stroke();

  isocontext.restore();
}
