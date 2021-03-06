class Stack
    # A generic stack

    constructor: () ->
        @size = 0
        @grow_size = 10
        @contents = Array(@grow_size)

    push: (item) ->
        if @contents.length > @size
            @contents[@size++] = item
        else
            @contents.length += @grow_size
            @contents[@size++] = item

    pop: ->
        if @size == 0
            return

        elem = @contents[@size - 1]
        delete @contents[@size - 1]
        @size--
        return elem

    peek: ->
        if @size > 0
            return @contents[@size - 1]


class LSystem
    # A representation of a single L system.

    constructor: (hash) ->

        @axiom = hash.axiom
        @rules = hash.rules
        @renderFunctions = hash.renderFunctions
        @stack = new Stack(@axiom, @rules, @renderFunctions)
        @stack.push new Turtle()
        @variables = ['A', 'B']

    step: () ->
        buffer = ''

        for i in [0..@axiom.length - 1]
            char = @axiom.charAt i
            # todo: handle constants that don't have a translation function
            generationFunc = @rules[char]

            if generationFunc
                buffer = buffer + generationFunc
            else
                buffer = buffer + char
        
        return buffer


    render: () ->
        for i in [0..@axiom.length - 1]
            renderFunc = @renderFunctions[@axiom.charAt i]
            if renderFunc
                renderFunc(@stack)


class Turtle
    # A simple implementation of Turtle Graphics.

    constructor: () ->
        canvas = document.getElementById("canvas")
        @ctx = canvas.getContext '2d'
        @drawing = true

    penDown: ->
        @drawing = true

    penUp: ->
        @drawing = false

    rotate: (degrees) ->
        @ctx.moveTo 0, 0
        @ctx.rotate degrees * Math.PI / 180

    forward: (length) ->
        @ctx.beginPath()
        @ctx.moveTo 0, 0

        if @drawing
            @ctx.lineTo 0, -length

        @ctx.stroke()

        @ctx.translate 0, -length

    right: (degrees) ->
        @rotate degrees

    left: (degrees) ->
        @right -degrees

currentSystem = undefined
transformState =
    zoomOut: (amount) ->
        if(@zoomLevel - amount > 0.1)
            @zoomLevel -= amount
    xOffset: 0
    yOffset: 0
    zoomLevel: 1.0

renderLSystem = () ->

    # Default to 6
    numIterations = 6
    
    numIterationsInput = document.getElementById 'numIterations'
    if numIterationsInput.value isnt ""
        numIterations = numIterationsInput.value

    if currentSystem is undefined
        console.log 'Cannot render undefined system.'
        return

    console.log "Rendering", currentSystem, "for", numIterations, "generations."

    canvas = document.getElementById("canvas")
    ctx = canvas.getContext '2d'
    maxX = canvas.width
    maxY = canvas.height

    topX = -transformState.xOffset / transformState.zoomLevel
    topY = -transformState.yOffset / transformState.zoomLevel
    width = maxX / transformState.zoomLevel
    height = maxY / transformState.zoomLevel

    ctx.setTransform(transformState.zoomLevel, 0, 0, transformState.zoomLevel, transformState.xOffset, transformState.yOffset)
    ctx.fillStyle = 'white'
    ctx.fillRect topX, topY, width, height

    a = new LSystem(lsystems[currentSystem])

    for num in [1..numIterations]
        a.axiom = a.step()

    console.log "Evolution:", a.axiom
    
    a.render()


lsystems =
    'Sierpinski Triangle':
        axiom: 'A'
        rules:
            'A': 'B-A-B'
            'B': 'A+B+A'
        renderFunctions:
            'A': (stack) ->
                turtle = stack.peek()
                turtle.forward 10
            'B': (stack) ->
                turtle = stack.peek()
                turtle.forward 10
            '-': (stack) ->
                turtle = stack.peek()
                turtle.left 60
            '+': (stack) ->
                turtle = stack.peek()
                turtle.right 60
    'Wikipedia Example 2':
        axiom: '0'
        rules:
            '1': '11'
            '0': '1[0]0'
        renderFunctions:
            '0': (stack) ->
                turtle = stack.peek()
                turtle.forward 10
            '1': (stack) ->
                turtle = stack.peek()
                turtle.forward 10
            '[': (stack) ->
                turtle = new Turtle()
                stack.push turtle
                turtle.ctx.save()
                turtle.left 45
            ']': (stack) ->
                turtle = stack.pop()
                turtle.ctx.restore()
                turtle.right 45
    'Koch Snowflake':
        axiom: 'S--S--S'
        rules:
            'S': 'S+S--S+S'
        renderFunctions:
            'S': (stack) ->
                turtle = stack.peek()
                turtle.forward 10
            '+': (stack) ->
                turtle = stack.peek()
                turtle.left 60
            '-': (stack) ->
                turtle = stack.peek()
                turtle.right 60
    'Tree':
        axiom: 'F'
        rules:
            'F': 'F[+F]F[-F][F]'
        renderFunctions:
            'F': (stack) ->
                turtle = stack.peek()
                turtle.forward 10
            '[': (stack) ->
                turtle = new Turtle()
                stack.push turtle
                turtle.ctx.save()
            ']': (stack) ->
                turtle = stack.pop()
                turtle.ctx.restore()
            '+': (stack) ->
                turtle = stack.peek()
                turtle.left 20
            '-': (stack) ->
                turtle = stack.peek()
                turtle.right 20

initialise = ->
    selectBox = document.getElementById 'systemselector'
    for key in Object.keys(lsystems)
        selectBox.options[selectBox.options.length] = new Option(key)

    currentSystem = Object.keys(lsystems)[0]

    submitButton = document.getElementById 'submitButton'
    submitButton.onclick = (event) ->
        currentSystem = selectBox.value
        renderLSystem()
        return false

    canvas = document.getElementById 'canvas'
    ctx = canvas.getContext '2d'

    transformState.xOffset = canvas.width / 2
    transformState.yOffset = canvas.height / 2

    zoomInButton = document.getElementById 'zoomIn'
    zoomInButton.onclick = (event) ->
        transformState.zoomLevel += 0.2
        ctx.scale transformState.zoomLevel, transformState.zoomLevel
        renderLSystem()
        return false

    zoomOutButton = document.getElementById 'zoomOut'
    zoomOutButton.onclick = (event) ->
        transformState.zoomOut 0.2
        ctx.scale transformState.zoomLevel, transformState.zoomLevel
        renderLSystem()
        return false

    panLeftButton = document.getElementById 'panLeft'
    panLeftButton.onclick = (event) ->
        transformState.xOffset -= 20
        ctx.translate transformState.xOffset, transformState.yOffset
        renderLSystem()
        return false

    panRightButton = document.getElementById 'panRight'
    panRightButton.onclick = (event) ->
        transformState.xOffset += 20
        ctx.translate transformState.xOffset, transformState.yOffset
        renderLSystem()
        return false

    panDownButton = document.getElementById 'panDown'
    panDownButton.onclick = (event) ->
        transformState.yOffset -= 20
        ctx.translate transformState.xOffset, transformState.yOffset
        renderLSystem()
        return false

    panUpButton = document.getElementById 'panUp'
    panUpButton.onclick = (event) ->
        transformState.yOffset += 20
        ctx.translate transformState.xOffset, transformState.yOffset
        renderLSystem()
        return false

    previousX = 0
    previousY = 0
    dragging = false

    canvas.onmousedown = (event) ->
        previousX = event.offsetX
        previousY = event.offsetY
        dragging = true
        return false

    canvas.onmouseup = (event) ->
        dragging = false
        return false

    canvas.onmousemove = (event) ->
        if dragging
            transformState.xOffset += event.offsetX - previousX
            transformState.yOffset += event.offsetY - previousY

            previousX = event.offsetX
            previousY = event.offsetY
            renderLSystem()

        return false
    
initialise()
renderLSystem()
