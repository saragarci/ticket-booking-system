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

    // **** show 1 ****
    // show details
    const show_1 = await ticketBookingSystem.getShow(0)
    assert.equal(show_1[0], 0, 'Error: Invalid show id')
    assert.equal(show_1[1], 'Star wars', 'Error: Invalid show title')
    assert.equal(show_1[2], 3090233503328250, 'Error: Invalid show price')
    assert.equal(show_1[3], 'Scheduled', 'Error: Invalid status')
    assert.equal(show_1[4].length, 2, 'Error: Invalid number of dates')
    
    // room for date 1 details
    const show_1_id = show_1[0]
    const show_1_date_1 = show_1[4][0]
    let roomDetails = await ticketBookingSystem.getRoomForDate(show_1_id, show_1_date_1)
    assert.equal(roomDetails[0], 2, 'Error: Invalid number of rows')
    assert.equal(roomDetails[1], 3, 'Error: Invalid number of columns')
    assert.equal(roomDetails[2], 6, 'Error: Invalid number of remaining seats')
    assert.equal(roomDetails[3].length, 2, 'Error: Invalid number of seat rows')
    assert.equal(roomDetails[3][0].length, 3, 'Error: Invalid number of seat columns')

    // room for date 1 seat details
    const seats = roomDetails[3]
    assert.equal(seats[0][0][0], 0, 'Error: Invalid seat id')
    assert.equal(seats[0][0][1], 0, 'Error: Invalid row')
    assert.equal(seats[0][0][2], 0, 'Error: Invalid column')
    assert.equal(seats[0][0][3], 'https://seatview.no/norwaycinema', 'Error: Invalid seat view link')
    assert.equal(seats[0][0][4], true, 'Error: Invalid isAvailable')

    // room for date 2 details
    const show_1_date_2 = show_1[4][1]
    roomDetails = await ticketBookingSystem.getRoomForDate(show_1_id, show_1_date_2)
    assert.equal(roomDetails[0], 2, 'Error: Invalid number of rows')
    assert.equal(roomDetails[1], 3, 'Error: Invalid number of columns')
    assert.equal(roomDetails[2], 6, 'Error: Invalid number of remaining seats')
    assert.equal(roomDetails[3].length, 2, 'Error: Invalid number of seat rows')
    assert.equal(roomDetails[3][0].length, 3, 'Error: Invalid number of seat columns')

    // **** show 2 ****
    // show details
    const show_2 = await ticketBookingSystem.getShow(1)
    assert.equal(show_2[0], 1, 'Error: Invalid show id')
    assert.equal(show_2[1], 'The Lord of the Rings', 'Error: Invalid show title')
    assert.equal(show_2[2], 3090233503328250, 'Error: Invalid show price')
    assert.equal(show_2[3], 'Scheduled', 'Error: Invalid status')
    assert.equal(show_2[4].length, 2, 'Error: Invalid number of dates')
  })

  // Task 2
  it("Has a function buy that allows B and C to get a ticket each", async() => {
    //const tx = await ticketBookingSystem.buy()
  })
});
