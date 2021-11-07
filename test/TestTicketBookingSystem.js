var TicketBookingSystem = artifacts.require('TicketBookingSystem')
const truffleAssert = require('truffle-assertions')

contract('TicketBookingSystem', function(accounts) {   
  let ticketBookingSystem

  // Roles
  const salesManager_A = accounts[0]
  const customer_B = accounts[1]
  const customer_C = accounts[2]
  const customer_D = accounts[3]

  it("Allows...", async() => {
    ticketBookingSystem = await TicketBookingSystem.deployed()
    // ...
  })
});
