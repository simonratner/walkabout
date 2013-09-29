
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
  dx = 8
  dy = 8

  path = paper.set()

  walk = (x, y) ->
    for d in [1..dx]
      if x < d or x >= w - d
        return
      if y < d or y >= h - d
        return
      gx = (data(x + d, y) - data(x - d, y)) / (2 * d)
      gy = (data(x, y + d) - data(x, y - d)) / (2 * d)
      cx = -gy
      cy = gx
      path.push(
        paper.path(
          "M#{[x - d*cx, y - d*cy]}L#{[x + d*cx, y + d*cy]}"
        ).attr(fill: 'red', stroke: 'red', opacity: 0.5)
      )

  paper.canvas.addEventListener 'mousemove', (e) ->
    x = e.offsetX
    y = e.offsetY
    path.forEach (el) -> el.remove()
      #el.remove() if el.node?.tagName.toLowerCase() == 'text'
    path.push(
      paper.text(x, y - 15, data(x, y)).attr(fill: 'red', font: '12px Consolas', opacity: 0.5),
    )
    walk x, y
