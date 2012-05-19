class Stack

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
    constructor: ->

        @initialiseCanvas()

        @stack = new Stack()
        @stack.push new Turtle(1)
        @variables = ['0', '1']
        @axiom = '0'
        #        @rules =
        #            'A': () -> 'AB'
        #            'B': () -> '[A]'
        #            '[': () -> '['
        #            ']': () -> ']'
        @rules =
            '0': () -> '1[0]0'
            '1': () -> '11'
            '[': () -> '['
            ']': () -> ']'
        @renderFunctions =
            '0': (stack) ->
                turtle = stack.peek()
                #                turtle.penDown()
                turtle.forward 10
            '1': (stack) ->
                turtle = stack.peek()
                #turtle.penUp()
                turtle.forward 10
            '[': (stack) ->
                turtle = new Turtle(2)
                stack.push turtle
                turtle.ctx.save()
                turtle.rotate 45
            ']': (stack) ->
                turtle = stack.pop()
                turtle.ctx.restore()
                turtle.rotate -45


    initialiseCanvas: () ->
        canvas = document.getElementById("canvas")
        ctx = canvas.getContext '2d'
        maxX = canvas.width
        maxY = canvas.height
        ctx.translate maxX / 2, maxY

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
    constructor: (num) ->
        canvas = document.getElementById("canvas")
        @ctx = canvas.getContext '2d'
        @drawing = true
        @num = num

    penDown: ->
        @drawing = true

    penUp: ->
        @drawing = false

    forward: (length) ->
        console.log "Turtle", @num, " moving forward."
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

a = new LSystem()
for num in [0..2]
    a.axiom = a.step()
    console.log a.axiom
a.render()

