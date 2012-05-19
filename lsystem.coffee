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
                buffer = buffer + @rules[char]()
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

        #currentSystem = 'Sierpinski Triangle'
currentSystem = 'Wikipedia Example 2'

renderLSystem = () ->
    console.log "rendering"

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
    ctx.save()
    ctx.fillStyle = 'white'
    ctx.fillRect 0, 0, maxX, maxY
    ctx.translate maxX / 2, maxY / 2

    a = new LSystem(lsystems[currentSystem])
    console.log a
    for num in [0..numIterations]
        a.axiom = a.step()
    
    a.render()

    ctx.restore()

initialise = ->
    selectBox = document.getElementById "systemselector"
    selectBox.onchange = (event) ->
        console.log "hi"
        console.log currentSystem
        console.log @value
        currentSystem = @value
        console.log currentSystem
        renderLSystem()

initialise()

lsystems =
    'Sierpinski Triangle':
        axiom: 'A'
        rules:
            'A': () -> 'B-A-B'
            'B': () -> 'A+B+A'
        renderFunctions:
            'A': (stack) ->
                turtle = stack.peek()
                turtle.forward 10
            'B': (stack) ->
                turtle = stack.peek()
                turtle.forward 10
            '-': (stack) ->
                #                turtle = new Turtle()
                #stack.push turtle
                turtle = stack.peek()
                #turtle.ctx.save()
                turtle.rotate -60
            '+': (stack) ->
                turtle = stack.peek()

                #turtle.ctx.restore()
                turtle.rotate 60




a = new LSystem(lsystems['Sierpinski triangle'])
for num in [0..6]
    a.axiom = a.step()
a.render()
