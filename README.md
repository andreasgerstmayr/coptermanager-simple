# Coptermanager Simple

Control your quadrocopter with JavaScript.

## Requirements

* Arduino board (tested with Arduino Due) and A7105 chip
* [node.js and npm](http://nodejs.org)
* [bower](http://bower.io) (install with `npm install -g bower`)
* [gulp](http://gulpjs.com) (install with `npm install -g gulp`)

## Setup instructions

1. Follow the [instructions to build the transmitter station](http://www.instructables.com/id/Easy-Android-controllable-PC-Interfaceable-Relati/step5/Building-the-Arduino-driven-radio/) with a small modification:
  * instead of 3 wire SPI use 4 wire SPI:
  * skip step 10 "Put an additional wire from the 'SDIO' pin of the A7105 to the 'MISO' pin of the due."
  * **instead wire 'gio1' of the A7105 chip to the 'MISO' port of the arduino due**
  * test some resistor values (as written in the tutorial) - mine didn't work with 22K Ohm, but it works with 10K Ohm

2. Clone this repository

3. Open `arduino/arduino.ino` with the arduino IDE and send it to your arduino board

4. Execute `bower install`, `npm install`, `npm link` and `npm link coptermanager-simple`

5. Run `node start-repl.js`

## Usage

There are 4 ways to interact with the drone:

1. Issue commands in the node.js REPL: start the REPL with `node start-repl.js` and then execute commands like `client.takeoff()`, `client.throttle(30)`, ...
2. Control the drone with your keyboard: open the webapp at [http://localhost:3000/copter/keyboard](http://localhost:3000/copter/keyboard)
3. Upload code in the webapp: open [http://localhost:3000/copter/code](http://localhost:3000/copter/code) in your browser
4. Execute autonomous scripts: see [the examples directory](https://github.com/andihit/coptermanager-simple/tree/master/examples)

## Code example

```js
var coptermanager = require('coptermanager-simple');
var client = new coptermanager.Client({serialport: '/dev/tty.usbmodem1411'});

client.bind(function() {

  client.takeoff()
  .after(5000, function() {
    this.elevator(112);
  })
  .after(1000, function() {
    this.ledOff();
  })
  .after(1000, function() {
    this.land();
  })
  .after(1000, function() {
    this.disconnect();
  });

});
```

[More examples](https://github.com/andihit/coptermanager-simple/tree/master/examples)
