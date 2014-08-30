# Coptermanager Simple

Control your quadrocopter with JavaScript.

## Setup instructions

1. Follow the [instructions to build the transmitter station](http://www.instructables.com/id/Easy-Android-controllable-PC-Interfaceable-Relati/step5/Building-the-Arduino-driven-radio/) with a small modification:
  * instead of 3 wire SPI use 4 wire SPI:
  * skip step 10 "Put an additional wire from the 'SDIO' pin of the A7105 to the 'MISO' pin of the due."
  * **instead wire 'gio1' of the A7105 chip to the 'MISO' port of the arduino due**
  * test some resistor values (as written in the tutorial) - mine didn't work with 22K Ohm, but it works with 10K Ohm

2. Clone this repository

3. Open `arduino/arduino.ino` with the arduino IDE and send it to your arduino board

4. Execute `npm install`, `bower install`, `gulp build` and `npm link`

5. Run `node start-repl.js`

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
