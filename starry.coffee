colorsLib = ['#F06292', '#F06292', '#BA68C8', '#64B5F6', '#4FC3F7', '#4DD0E1', '#81C784', '#FFB74D' ]
deg360 = Math.PI * 2

dotsDistance = (dot1, dot2) ->
  x = dot1.x - dot2.x
  y = dot1.y - dot2.y
  x*x + y*y

class Dot
  constructor: (setting) ->
    @next = []
    {@color, @x, @y, @size, @speedX, @speedY} = setting

Dot.random = (width, height) ->
  prop =
    color: colorsLib[parseInt Math.random() * colorsLib.length]
    x: parseInt width * Math.random()
    y: parseInt height * Math.random()
    size: 1 + 2 * Math.random() * (window.devicePixelRatio||1)
    speedX: Math.random()*0.01
    speedY: Math.random()*0.01
  new this prop

class StarryNight
  constructor: (canvas) ->
    @canvas = canvas
    @context = canvas.getContext '2d'
    @resize()
    @dots = (Dot.random @width(), @height() for [0..100])
    _thisContext = this
    @onAnimate = (time, step) ->
      _thisContext._onanimate.call _thisContext, time, step
  width: (w) ->
    if arguments.length
      @canvas.width = w
    @canvas.width
  height: (h) ->
    if arguments.length
      @canvas.height = h
    @canvas.height
  drawDot: (dot) ->
    @context.fillStyle = dot.color
    @context.shadowBlur = dot.size * 2
    @context.shadowColor = "#fff"
    @context.beginPath()
    @context.arc dot.x, dot.y, dot.size, 0, deg360, true
    @context.fill()
    @context.closePath()
    return
  drawDots: (dots, before) ->
    if not before
      @drawDot dot for dot in dots
    else
      for dot in dots
        before(dot)
        @drawDot(dot)
    return
  drawLine: (x1, y1, x2, y2, color) ->
    color = 'rgba(255, 255, 255, 0.1)' if not color
    @context.strokeStyle = color
    @context.shadowBlur = 0
    @context.moveTo x1, y1
    @context.lineTo x2, y2
    @context.stroke()
    @context.closePath()
    return
  clear: () ->
    @context.clearRect 0, 0, @width(), @height()
    return
  relateDots: (callback) ->
    maxDistance = @width() * @width()/160
    _dotsLength = @dots.length
    _nextLength = _nextLengthORG = 2
    for i in [0.._dotsLength-2]
      _nextLength = _nextLength - 1 if i > _dotsLength/2 and _nextLengthORG is _nextLength
      doti = @dots[i]
      doti.next = [] if not doti.next
      doti.next.length = 0
      if i is _dotsLength
        continue
      for j in [(i+1).._dotsLength-1]
        dotj = @dots[j]
        distance = dotsDistance doti, dotj
        if distance < maxDistance
          if not doti.next[_nextLength - 1] or dotsDistance(doti.next[_nextLength - 1], doti) > distance
            doti.next.unshift(dotj)
        doti.next.length = _nextLength if doti.next.length > _nextLength
      callback doti
    return
  resize: () ->
    @width @canvas.clientWidth*(window.devicePixelRatio||1)
    @height @canvas.clientHeight*(window.devicePixelRatio||1)
    return
  play: () ->
    if @_timer
      return
    _this = this
    _start = Date.now()
    @_timer = setInterval () ->
      _temp = Date.now()
      _this._onanimate _temp - _start
      _start = _temp
    , 100
    console.log(@_timer)
  pause: () ->
    clearInterval(@_timer)
    @_timer = null
    return
  _onanimate: (step) ->
    # 页面隐藏时 requestAnimationFrame 会停止
    # 造成 step 积累
    step = 30 if step > 500
    @clear()
    for dot in @dots
      # 更新点的位置
      dot.x = dot.x + dot.speedX*step
      dot.x = 0 if dot.x > @width()
      dot.x = @width() if dot.x < 0
      dot.y = dot.y + dot.speedY*step
      dot.y = 0 if dot.y > @height()
      dot.y = @height() if dot.y < 0
    @relateDots (dot) =>
      @drawDot(dot)
      for next in dot.next
        @drawLine dot.x, dot.y, next.x, next.y