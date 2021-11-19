# Ticket Booking System

### Required programs
* node
* npm
* truffle
* ganache-cli

### Run tests
First, `cd` into the project and install all the npm dependencies:
`npm install`

In another terminal run ganache setting the time for the first block:
`ganache-cli --time 2021-12-28T17:00:00`

Then, back into the first terminal, run the tests using truffle:
`truffle console`
`truffle test`
