var TicketBookingSystem = artifacts.require('TicketBookingSystem')
var Ticket = artifacts.require('Ticket')
const truffleAssert = require('truffle-assertions')

contract('TicketBookingSystem', function(accounts) {   
  let ticketBookingSystem
  let ticket
  let err

  // Actors
  const salesManager_A = accounts[0]
  const customer_B = accounts[1]
  const customer_C = accounts[2]
  const customer_D = accounts[3]

  // Initialization data for both shows
  // Show 1
  const show_1_id = 0
  const show_1_title = "Star wars"
  const show_1_price = 3090233503328250
  const show_1_date_1 = 1640628000
  const show_1_date_2 = 1640800800
  const show_1_dates_count = 2
  const show_1_status = "Scheduled"
  
  // Show 2
  const show_2_id = 1
  const show_2_title = "The Lord of the Rings"
  const show_2_price = 3090233503328250
  const show_2_date_1 = 1640714400
  const show_2_date_2 = 1640887200
  const show_2_dates_count = 2
  const show_2_status = "Scheduled"
  
  // Room details
  const room_1_rows_count = 2
  const room_1_columns_count = 3
  const link_seat_view = "https://seatview.no/norwaycinema"

  /*
   * A = Available, B = Booked
   *
   * (1, 0, A) (1, 1, A) (1, 2, A)
   * (0, 0, A) (0, 1, A) (0, 2, A)
   *  
   * ------ SCREEN ------
   */

  // Task 1
  it("Initializes the smart contract with two shows containing all the relevant information", async() => {
    ticketBookingSystem = await TicketBookingSystem.deployed({from: salesManager_A})
    ticket = await Ticket.deployed({from: salesManager_A})

    // **** show 1 ****
    // show details
    const show_1 = await ticketBookingSystem.getShow(0)
    assert.equal(show_1[0], show_1_id, 'Error: Invalid show id')
    assert.equal(show_1[1], show_1_title, 'Error: Invalid show title')
    assert.equal(show_1[2], show_1_price, 'Error: Invalid show price')
    assert.equal(show_1[3], show_1_status, 'Error: Invalid status')
    assert.equal(show_1[4].length, show_1_dates_count, 'Error: Invalid number of dates')
    
    // room for date 1 details
    let roomDetails = await ticketBookingSystem.getRoomForDate(show_1_id, show_1_date_1)
    assert.equal(roomDetails[0], room_1_rows_count, 'Error: Invalid number of rows')
    assert.equal(roomDetails[1], room_1_columns_count, 'Error: Invalid number of columns')
    assert.equal(roomDetails[2], room_1_rows_count*room_1_columns_count, 'Error: Invalid number of remaining seats')
    assert.equal(roomDetails[3].length, room_1_rows_count, 'Error: Invalid number of seat rows')
    assert.equal(roomDetails[3][0].length, room_1_columns_count, 'Error: Invalid number of seat columns')

    // room for date 1 seat details
    const seats = roomDetails[3]
    assert.equal(seats[0][0][0], 0, 'Error: Invalid seat id')
    assert.equal(seats[0][0][1], 0, 'Error: Invalid row')
    assert.equal(seats[0][0][2], 0, 'Error: Invalid column')
    assert.equal(seats[0][0][3], link_seat_view, 'Error: Invalid seat view link')
    assert.equal(seats[0][0][4], true, 'Error: Invalid isAvailable')

    // room for date 2 details exist
    roomDetails = await ticketBookingSystem.getRoomForDate(show_1_id, show_1_date_2)
    assert(roomDetails)

    // **** show 2 ****
    // show details
    const show_2 = await ticketBookingSystem.getShow(1)
    assert.equal(show_2[0], show_2_id, 'Error: Invalid show id')
    assert.equal(show_2[1], show_2_title, 'Error: Invalid show title')
    assert.equal(show_2[2], show_2_price, 'Error: Invalid show price')
    assert.equal(show_2[3], show_2_status, 'Error: Invalid status')
    assert.equal(show_2[4].length, show_2_dates_count, 'Error: Invalid number of dates')

    // room details for both dates exist
    roomDetails = await ticketBookingSystem.getRoomForDate(show_2_id, show_2_date_1)
    assert(roomDetails)
    roomDetails = await ticketBookingSystem.getRoomForDate(show_2_id, show_2_date_2)
    assert(roomDetails)
  })

  // Task 2
  it("Has a function buy that allows B and C to get a ticket each", async() => {
    // customer B buys ticket for show 1, date 1, row: 1, col: 1
    let tx = await ticketBookingSystem.buy(show_1_id, show_1_date_1, 1, 1,
      {from: customer_B, value: show_1_price})

    // seat not available
    // remaining seats -1
    // B owns token
    //expect(await ticket.ownerOf(1)).to.equal(customer_B)

    // customer C *tries* to buy ticket for show 1, date 1, row: 1, col: 1
    try {
      tx = await ticketBookingSystem.buy(show_1_id, show_1_date_1, 1, 1,
        {from: customer_C, value: show_1_price})
    } catch (error) {
      err = error
    }
    assert.ok(err instanceof Error) // But seat is not available

    // customer C buys ticket for show 1, date 1, row: 0, col: 1
    tx = await ticketBookingSystem.buy(show_1_id, show_1_date_1, 0, 1,
      {from: customer_C, value: show_1_price})

    /*
     * (1, 0, A) (1, 1, B) (1, 2, A)
     * (0, 0, A) (0, 1, B) (0, 2, A)
     *  
     * ------ SCREEN ------
     */
  })
});
