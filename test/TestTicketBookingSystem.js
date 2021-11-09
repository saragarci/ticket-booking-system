var TicketBookingSystem = artifacts.require('TicketBookingSystem')
const truffleAssert = require('truffle-assertions')

contract('TicketBookingSystem', function(accounts) {   
  let ticketBookingSystem

  // Roles
  const salesManager_A = accounts[0]
  const customer_B = accounts[1]
  const customer_C = accounts[2]
  const customer_D = accounts[3]

  // Task 1
  it("Initializes the smart contract with two shows containing all the relevant information", async() => {
    ticketBookingSystem = await TicketBookingSystem.deployed()
    const showsInfo = await ticketBookingSystem.getShows()

    // shows contains 2 shows
    assert(showsInfo.length == 2)
    
    // show 1
    assert.equal(showsInfo[0][0], 0, 'Error: Invalid show id')
    assert.equal(showsInfo[0][1], 'The Nutcracker', 'Error: Invalid show title')
    assert.equal(showsInfo[0][2], 1640714400, 'Error: Invalid show date')
    assert.equal(showsInfo[0][3], 9, 'Error: Invalid number of available seats')
    assert.equal(showsInfo[0][4], 0, 'Error: Invalid order state') // 0: OnSale
    assert.equal(showsInfo[0][5].length, 9, 'Error: Invalid number of seats')

    // show 1 - seat 1 (id: 0)
    // ...

    // show 2
    assert.equal(showsInfo[1][0], 1, 'Error: Invalid show id')
    assert.equal(showsInfo[1][1], 'Mary Poppins', 'Error: Invalid show title')
    assert.equal(showsInfo[1][2], 1640887200, 'Error: Invalid show date')
    assert.equal(showsInfo[1][3], 9, 'Error: Invalid number of available seats')
    assert.equal(showsInfo[1][4], 0, 'Error: Invalid order state') // 0: OnSale
    assert.equal(showsInfo[1][5].length, 9, 'Error: Invalid number of seats')
  })
});
