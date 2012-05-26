(function() {
  var LSystem, Stack, Turtle, currentSystem, initialise, lsystems, renderLSystem, transformState;

  Stack = (function() {

    function Stack() {
      this.size = 0;
      this.grow_size = 10;
      this.contents = Array(this.grow_size);
    }

    Stack.prototype.push = function(item) {
      if (this.contents.length > this.size) {
        return this.contents[this.size++] = item;
      } else {
        this.contents.length += this.grow_size;
        return this.contents[this.size++] = item;
      }
    };

    Stack.prototype.pop = function() {
      var elem;
      if (this.size === 0) return;
      elem = this.contents[this.size - 1];
      delete this.contents[this.size - 1];
      this.size--;
      return elem;
    };

    Stack.prototype.peek = function() {
      if (this.size > 0) return this.contents[this.size - 1];
    };

    return Stack;

  })();

  LSystem = (function() {

    function LSystem(hash) {
      this.axiom = hash.axiom;
      this.rules = hash.rules;
      this.renderFunctions = hash.renderFunctions;
      this.stack = new Stack(this.axiom, this.rules, this.renderFunctions);
      this.stack.push(new Turtle());
      this.variables = ['A', 'B'];
    }

    LSystem.prototype.step = function() {
      var buffer, char, generationFunc, i, _ref;
      buffer = '';
      for (i = 0, _ref = this.axiom.length - 1; 0 <= _ref ? i <= _ref : i >= _ref; 0 <= _ref ? i++ : i--) {
        char = this.axiom.charAt(i);
        generationFunc = this.rules[char];
        if (generationFunc) {
          buffer = buffer + generationFunc;
        } else {
          buffer = buffer + char;
        }
      }
      return buffer;
    };

    LSystem.prototype.render = function() {
      var i, renderFunc, _ref, _results;
      _results = [];
      for (i = 0, _ref = this.axiom.length - 1; 0 <= _ref ? i <= _ref : i >= _ref; 0 <= _ref ? i++ : i--) {
        renderFunc = this.renderFunctions[this.axiom.charAt(i)];
        if (renderFunc) {
          _results.push(renderFunc(this.stack));
        } else {
          _results.push(void 0);
        }
      }
      return _results;
    };

    return LSystem;

  })();

  Turtle = (function() {

    function Turtle() {
      var canvas;
      canvas = document.getElementById("canvas");
      this.ctx = canvas.getContext('2d');
      this.drawing = true;
    }

    Turtle.prototype.penDown = function() {
      return this.drawing = true;
    };

    Turtle.prototype.penUp = function() {
      return this.drawing = false;
    };

    Turtle.prototype.rotate = function(degrees) {
      this.ctx.moveTo(0, 0);
      return this.ctx.rotate(degrees * Math.PI / 180);
    };

    Turtle.prototype.forward = function(length) {
      this.ctx.beginPath();
      this.ctx.moveTo(0, 0);
      if (this.drawing) this.ctx.lineTo(0, -length);
      this.ctx.stroke();
      return this.ctx.translate(0, -length);
    };

    Turtle.prototype.right = function(degrees) {
      return this.rotate(degrees);
    };

    Turtle.prototype.left = function(degrees) {
      return this.right(-degrees);
    };

    return Turtle;

  })();

  currentSystem = void 0;

  transformState = {
    zoomOut: function(amount) {
      if (this.zoomLevel - amount > 0.1) return this.zoomLevel -= amount;
    },
    xOffset: 0,
    yOffset: 0,
    zoomLevel: 1.0
  };

  renderLSystem = function() {
    var a, canvas, ctx, height, maxX, maxY, num, numIterations, numIterationsInput, topX, topY, width;
    numIterations = 6;
    numIterationsInput = document.getElementById('numIterations');
    if (numIterationsInput.value !== "") numIterations = numIterationsInput.value;
    if (currentSystem === void 0) {
      console.log('Cannot render undefined system.');
      return;
    }
    console.log("Rendering", currentSystem, "for", numIterations, "generations.");
    canvas = document.getElementById("canvas");
    ctx = canvas.getContext('2d');
    maxX = canvas.width;
    maxY = canvas.height;
    topX = -transformState.xOffset / transformState.zoomLevel;
    topY = -transformState.yOffset / transformState.zoomLevel;
    width = maxX / transformState.zoomLevel;
    height = maxY / transformState.zoomLevel;
    ctx.setTransform(transformState.zoomLevel, 0, 0, transformState.zoomLevel, transformState.xOffset, transformState.yOffset);
    ctx.fillStyle = 'white';
    ctx.fillRect(topX, topY, width, height);
    a = new LSystem(lsystems[currentSystem]);
    for (num = 1; 1 <= numIterations ? num <= numIterations : num >= numIterations; 1 <= numIterations ? num++ : num--) {
      a.axiom = a.step();
    }
    console.log("Evolution:", a.axiom);
    return a.render();
  };

  lsystems = {
    'Sierpinski Triangle': {
      axiom: 'A',
      rules: {
        'A': 'B-A-B',
        'B': 'A+B+A'
      },
      renderFunctions: {
        'A': function(stack) {
          var turtle;
          turtle = stack.peek();
          return turtle.forward(10);
        },
        'B': function(stack) {
          var turtle;
          turtle = stack.peek();
          return turtle.forward(10);
        },
        '-': function(stack) {
          var turtle;
          turtle = stack.peek();
          return turtle.left(60);
        },
        '+': function(stack) {
          var turtle;
          turtle = stack.peek();
          return turtle.right(60);
        }
      }
    },
    'Wikipedia Example 2': {
      axiom: '0',
      rules: {
        '1': '11',
        '0': '1[0]0'
      },
      renderFunctions: {
        '0': function(stack) {
          var turtle;
          turtle = stack.peek();
          return turtle.forward(10);
        },
        '1': function(stack) {
          var turtle;
          turtle = stack.peek();
          return turtle.forward(10);
        },
        '[': function(stack) {
          var turtle;
          turtle = new Turtle();
          stack.push(turtle);
          turtle.ctx.save();
          return turtle.left(45);
        },
        ']': function(stack) {
          var turtle;
          turtle = stack.pop();
          turtle.ctx.restore();
          return turtle.right(45);
        }
      }
    },
    'Koch Snowflake': {
      axiom: 'S--S--S',
      rules: {
        'S': 'S+S--S+S'
      },
      renderFunctions: {
        'S': function(stack) {
          var turtle;
          turtle = stack.peek();
          return turtle.forward(10);
        },
        '+': function(stack) {
          var turtle;
          turtle = stack.peek();
          return turtle.left(60);
        },
        '-': function(stack) {
          var turtle;
          turtle = stack.peek();
          return turtle.right(60);
        }
      }
    },
    'Tree': {
      axiom: 'F',
      rules: {
        'F': 'F[+F]F[-F][F]'
      },
      renderFunctions: {
        'F': function(stack) {
          var turtle;
          turtle = stack.peek();
          return turtle.forward(10);
        },
        '[': function(stack) {
          var turtle;
          turtle = new Turtle();
          stack.push(turtle);
          return turtle.ctx.save();
        },
        ']': function(stack) {
          var turtle;
          turtle = stack.pop();
          return turtle.ctx.restore();
        },
        '+': function(stack) {
          var turtle;
          turtle = stack.peek();
          return turtle.left(20);
        },
        '-': function(stack) {
          var turtle;
          turtle = stack.peek();
          return turtle.right(20);
        }
      }
    }
  };

  initialise = function() {
    var canvas, ctx, dragging, key, panDownButton, panLeftButton, panRightButton, panUpButton, previousX, previousY, selectBox, submitButton, zoomInButton, zoomOutButton, _i, _len, _ref;
    selectBox = document.getElementById('systemselector');
    _ref = Object.keys(lsystems);
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      key = _ref[_i];
      selectBox.options[selectBox.options.length] = new Option(key);
    }
    currentSystem = Object.keys(lsystems)[0];
    submitButton = document.getElementById('submitButton');
    submitButton.onclick = function(event) {
      currentSystem = selectBox.value;
      renderLSystem();
      return false;
    };
    canvas = document.getElementById('canvas');
    ctx = canvas.getContext('2d');
    transformState.xOffset = canvas.width / 2;
    transformState.yOffset = canvas.height / 2;
    zoomInButton = document.getElementById('zoomIn');
    zoomInButton.onclick = function(event) {
      transformState.zoomLevel += 0.2;
      ctx.scale(transformState.zoomLevel, transformState.zoomLevel);
      renderLSystem();
      return false;
    };
    zoomOutButton = document.getElementById('zoomOut');
    zoomOutButton.onclick = function(event) {
      transformState.zoomOut(0.2);
      ctx.scale(transformState.zoomLevel, transformState.zoomLevel);
      renderLSystem();
      return false;
    };
    panLeftButton = document.getElementById('panLeft');
    panLeftButton.onclick = function(event) {
      transformState.xOffset -= 20;
      ctx.translate(transformState.xOffset, transformState.yOffset);
      renderLSystem();
      return false;
    };
    panRightButton = document.getElementById('panRight');
    panRightButton.onclick = function(event) {
      transformState.xOffset += 20;
      ctx.translate(transformState.xOffset, transformState.yOffset);
      renderLSystem();
      return false;
    };
    panDownButton = document.getElementById('panDown');
    panDownButton.onclick = function(event) {
      transformState.yOffset -= 20;
      ctx.translate(transformState.xOffset, transformState.yOffset);
      renderLSystem();
      return false;
    };
    panUpButton = document.getElementById('panUp');
    panUpButton.onclick = function(event) {
      transformState.yOffset += 20;
      ctx.translate(transformState.xOffset, transformState.yOffset);
      renderLSystem();
      return false;
    };
    previousX = 0;
    previousY = 0;
    dragging = false;
    canvas.onmousedown = function(event) {
      previousX = event.offsetX;
      previousY = event.offsetY;
      dragging = true;
      return false;
    };
    canvas.onmouseup = function(event) {
      dragging = false;
      return false;
    };
    return canvas.onmousemove = function(event) {
      if (dragging) {
        transformState.xOffset += event.offsetX - previousX;
        transformState.yOffset += event.offsetY - previousY;
        previousX = event.offsetX;
        previousY = event.offsetY;
        renderLSystem();
      }
      return false;
    };
  };

  initialise();

  renderLSystem();

}).call(this);
