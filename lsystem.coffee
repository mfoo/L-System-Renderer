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

    constructor: ->
        @initialiseCanvas()

        @stack = new Stack()
        @stack.push new Turtle()
        @stack.push new Turtle()
        @variables = ['A', 'B']
        @axiom = 'A'
        @rules =
            'A': () -> 'B-A-B'
            'B': () -> 'A+B+A'
            '-': () -> '-'
            '+': () -> '+'
        @renderFunctions =
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

    initialiseCanvas: () ->
        canvas = document.getElementById("canvas")
        ctx = canvas.getContext '2d'
        maxX = canvas.width
        maxY = canvas.height
        ctx.translate maxX / 2, maxY / 2

    step: () ->
        buffer = ''

        for i in [0..@axiom.length - 1]
            char = @axiom.charAt i
            # todo: handle constants that don't have a translation function
            buffer = buffer + @rules[char]()
        
        return buffer


    render: () ->
        for i in [0..@axiom.length - 1]
            @renderFunctions[@axiom.charAt i](@stack)

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

    forward: (length) ->
        @ctx.beginPath()
        @ctx.moveTo 0, 0

        if @drawing
            @ctx.lineTo 0, -length

        @ctx.stroke()

        @ctx.translate 0, -length

    rotate: (degrees) ->
        @ctx.moveTo 0, 0
        @ctx.rotate degrees * Math.PI / 180

window.LSystem = LSystem
window.Stack = Stack

a = new LSystem()
for num in [0..6]
    a.axiom = a.step()
a.render()
