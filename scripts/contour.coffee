
paper = Raphael('paper', 500, 500)
paper.image("/images/yosemite.png", 0, 0, 500, 500).attr(opacity: 0.75)
data = undefined

img = new Image()
img.src = "/images/yosemite.png"
img.onload = -> contour(this, paper)

bands = (x, y) ->
  level = data(x, y)
  b_min = Math.floor(level / 20) * 20
  b_max = Math.ceil(level / 20) * 20
  endpoints = []
  for i in [x...0]
    unless b_min < data(i, y) < b_max
      endpoints.push [i, y]
      break
  for i in [x..500]
    unless b_min < data(i, y) < b_max
      endpoints.push [i, y]
      break
  for i in [y...0]
    unless b_min < data(x, i) < b_max
      endpoints.push [x, i]
      break
  for i in [y..500]
    unless b_min < data(x, i) < b_max
      endpoints.push [x, i]
      break
  endpoints

contour = (img, paper) ->
  canvas = document.createElement('canvas')
  canvas.width = w = 500
  canvas.height = h = 500

  ctx = canvas.getContext('2d')
  ctx.drawImage(img, 0, 0, w, h)

  imgdata = ctx.getImageData(0, 0, w, h).data
  data = (x, y) -> imgdata[(x + y * w) * 4]
  dx = 4
  dy = 4

  path = []
  start = new Date().getTime()
  for i in [0...2500]
    x = Math.random_int(dx, w - dx - 1)
    y = Math.random_int(dy, h - dy - 1)
    for [x, y] in bands(x, y)
      gx = (data(x + dx, y) - data(x - dx, y)) / (2 * dx)
      gy = (data(x, y + dy) - data(x, y - dy)) / (2 * dy)
      cx = -gy
      cy = gx
      path.push "M#{[x - dx*cx/2, y - dy*cy/2]}L#{[x + dx*cx/2, y + dy*cy/2]}"
    #paper.circle(x, y, 0.5).attr(fill: 'red', stroke: 'red', opacity: 0.25)
    #paper.path("M#{[x - 5*cx, y - 5*cy]}L#{[x + 5*cx, y + 5*cy]}").attr(fill: 'red', stroke: 'red', opacity: 0.25)

  end = new Date().getTime()
  console.log("elapsed: #{end - start}ms")

  paper.path(path.join('')).attr(fill: 'black', stroke: 'black', opacity: 0.25)
