
paper = Raphael('paper', 500, 500)

paper.image("/images/yosemite.png", 0, 0, 500, 500).attr(opacity: 0.5)

img = new Image()
img.src = "/images/yosemite.png"
img.onload = -> contour(this, paper)

contour = (img, paper) ->
  canvas = document.createElement('canvas')
  canvas.width = w = 500
  canvas.height = h = 500

  ctx = canvas.getContext('2d')
  ctx.drawImage(img, 0, 0, w, h)

  data = ctx.getImageData(0, 0, w, h).data
  dx = 10
  dy = 10

  path = ""
  start = new Date().getTime()
  for i in [0...10000]
    x = Math.random_int(dx, w - dx - 1)
    y = Math.random_int(dy, h - dy - 1)
    gx = (data[(x + dx + y * w) * 4] - data[(x - dx + y * w) * 4]) / (2 * dx)
    gy = (data[(x + (y + dy) * w) * 4] - data[(x + (y - dy) * w) * 4]) / (2 * dy)
    cx = -gy
    cy = gx
    path += "M#{[x - dx*cx/2, y - dy*cy/2]}L#{[x + dx*cx/2, y + dy*cy/2]}"
    #paper.circle(x, y, 0.5).attr(fill: 'red', stroke: 'red', opacity: 0.25)
    #paper.path("M#{[x - 5*cx, y - 5*cy]}L#{[x + 5*cx, y + 5*cy]}").attr(fill: 'red', stroke: 'red', opacity: 0.25)

  end = new Date().getTime()
  console.log("elapsed: #{end - start}ms")

  paper.path(path).attr(fill: 'red', stroke: 'red', opacity: 0.25)
