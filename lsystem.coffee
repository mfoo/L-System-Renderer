class Stack

    constructor: () ->
        @size = 0
        @grow_size = 10
        @contents = Array(@grow_size)

    push: (item) ->
        if @contents.length > size
            @contents[size++] = item
        else
            @contents.length += @grow_size
            console.log "Growing array to size " + @contents.length
            @contents[size++] = item

    pop: ->
        if size == 0
            return

        elem = @contents[size]
        delete @contents[size--]
        return elem

    peek: ->
        return @contents[size]


class LSystem
    constructor: ->
        @stack = Stack()
        @canvas = document.getElementById "canvas"
        @variables = ['A', 'B']
        @axiom = 'A'
        @rules =
            'A': () -> 'AB'
            'B': () -> 'A'
        @renderFunctions =
            'A': (ctx) ->
                ctx.fillStyle = 'rgb(0,200,0)'
                console.log 'printing a'
            'B': (ctx) ->
                console.log 'printing b'


    step: () ->
        buffer = ''

        for i in [0..@axiom.length - 1]
            char = @axiom.charAt i
            # todo: handle constants that don't have a translation function
            buffer = buffer + @rules[char]()
        
        return buffer


    render: () ->
        ctx = @canvas.getContext '2d'
        ctx.fillStyle = 'rgb(200,0,0)'
        ctx.fillRect 10, 10, 55, 50

        for i in [0..@axiom.length - 1]
            @renderFunctions[@axiom.charAt i](ctx)

class Turtle
    constructor: ->
        canvas = document.getElementById("canvas")
        @ctx = canvas.getContext '2d'
        @x = 0
        @y = 0

a = new LSystem()
for num in [0..6]
    a.axiom = a.step()
    console.log a.axiom
a.render()

