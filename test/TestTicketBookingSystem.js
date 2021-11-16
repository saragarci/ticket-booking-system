var TicketBookingSystem = artifacts.require('TicketBookingSystem')
const truffleAssert = require('truffle-assertions')

contract('TicketBookingSystem', function(accounts) {   
  let ticketBookingSystem
  let ticketIdCounter = 1
  let err

  // Actors
  const salesManager_A = accounts[0]
  const customer_B = accounts[1]
  const customer_C = accounts[2]
  const customer_D = accounts[3]
  
  // Tickets
  let ticket_1_customer_B
  let ticket_2_customer_C
  
  // Initialization data for both shows
  // Show 1
  const show_1_id = 0
  const show_1_title = "Star wars"
  const show_1_price = 3090233503328250
  const show_1_date_1 = 1640628000
  const show_1_date_2 = 1640800800
  const show_1_dates_count = 2
  let show_1_status = "Scheduled"
  
  // Show 2
  const show_2_id = 1
  const show_2_title = "The Lord of the Rings"
  const show_2_price = 3090233503328250
  const show_2_date_1 = 1640714400
  const show_2_date_2 = 1640887200
  const show_2_dates_count = 2
  let show_2_status = "Scheduled"
  
  // Room details
  const room_1_rows_count = 2
  const room_1_columns_count = 3
  let room_1_remaining_seats = room_1_rows_count*room_1_columns_count
  const link_seat_view = "https://seatview.no/norwaycinema"

  /*
   * A = Available, B = Booked
   *
   * (1, 0, A) (1, 1, A) (1, 2, A)
   * (0, 0, A) (0, 1, A) (0, 2, A)
   *  
   * ---------- SCREEN -----------
   */

  // Task 1
  it("Initializes the smart contract with two shows containing all the relevant information", async() => {
    ticketBookingSystem = await TicketBookingSystem.deployed({from: salesManager_A})

    // **** show 1 ****
    // show details
    const show_1 = await ticketBookingSystem.getShow(show_1_id)
    assert.equal(show_1[0], show_1_id, 'Error: Invalid show id')
    assert.equal(show_1[1], show_1_title, 'Error: Invalid show title')
    assert.equal(show_1[2], show_1_price, 'Error: Invalid show price')
    assert.equal(show_1[3], show_1_status, 'Error: Invalid status')
    assert.equal(show_1[4].length, show_1_dates_count, 'Error: Invalid number of dates')
    
    // room for date 1 details
    let roomDetails = await ticketBookingSystem.getRoomForDate(show_1_id, show_1_date_1)
    assert.equal(roomDetails[0], room_1_rows_count, 'Error: Invalid number of rows')
    assert.equal(roomDetails[1], room_1_columns_count, 'Error: Invalid number of columns')
    assert.equal(roomDetails[2], room_1_remaining_seats, 'Error: Invalid number of remaining seats')
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
    const show_2 = await ticketBookingSystem.getShow(show_2_id)
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
    let row = 1
    let col = 1
    let tx = await ticketBookingSystem.buy(show_1_id, show_1_date_1, row, col,
      {from: customer_B, value: show_1_price})

    truffleAssert.eventEmitted(tx, 'TicketCreated', (ev) => {
      ticket_1_customer_B = ev.ticketId.toNumber()
      return ticket_1_customer_B === ticketIdCounter
    });

    let roomDetails = await ticketBookingSystem.getRoomForDate(show_1_id, show_1_date_1)
    
    // remaining seats is 1 less
    let remainingSeats = roomDetails[2]
    room_1_remaining_seats -= 1
    assert.equal(remainingSeats, room_1_remaining_seats, 'Error: Invalid number of remaining seats')
    
    // seat not available
    let seats = roomDetails[3]
    assert.equal(seats[row][col][4], false, 'Error: Invalid isAvailable')

    // B owns ticket
    expect(await ticketBookingSystem.getOwnerOfTicket(ticketIdCounter)).to.equal(customer_B)
    ticketIdCounter += 1

    // customer C *tries* to buy ticket for show 1, date 1, row: 1, col: 1
    try {
      tx = await ticketBookingSystem.buy(show_1_id, show_1_date_1, row, col,
        {from: customer_C, value: show_1_price})
    } catch (error) {
      err = error
    }
    assert.ok(err instanceof Error) // But seat is not available

    // customer C buys ticket for show 1, date 1, row: 0, col: 1
    row = 0
    tx = await ticketBookingSystem.buy(show_1_id, show_1_date_1, row, col,
      {from: customer_C, value: show_1_price})

    truffleAssert.eventEmitted(tx, 'TicketCreated', (ev) => {
      ticket_2_customer_C = ev.ticketId.toNumber()
      return ticket_2_customer_C === ticketIdCounter
    });

    roomDetails = await ticketBookingSystem.getRoomForDate(show_1_id, show_1_date_1)
  
    // remaining seats is 1 less
    remainingSeats = roomDetails[2]
    room_1_remaining_seats -= 1
    assert.equal(remainingSeats, room_1_remaining_seats, 'Error: Invalid number of remaining seats')
    
    // seat not available
    seats = roomDetails[3]
    assert.equal(seats[row][col][4], false, 'Error: Invalid isAvailable')

    // C owns ticket
    expect(await ticketBookingSystem.getOwnerOfTicket(ticketIdCounter)).to.equal(customer_C)
    ticketIdCounter += 1

    /*
     * (1, 0, A) (1, 1, B) (1, 2, A)
     * (0, 0, A) (0, 1, B) (0, 2, A)
     *  
     * ---------- SCREEN -----------
     */
  })

  // Task 3
  it("Has a function verify that allows anyone with the token ID to validate the ticket and the address", async() => {
    // Check ticket 1
    let tx = await ticketBookingSystem.verify(ticket_1_customer_B)
    assert.equal(tx[0], true, 'Error: Ticket should be valid')
    assert.equal(tx[1], customer_B, 'Error: Ticket owner should be customer B')

    // Check ticket 2
    tx = await ticketBookingSystem.verify(ticket_2_customer_C)
    assert.equal(tx[0], true, 'Error: Ticket should be valid')
    assert.equal(tx[1], customer_C, 'Error: Ticket owner should be customer C')

    // Check non existent ticket
    try {
      tx = await ticketBookingSystem.verify(12345)
    } catch (error) {
      err = error
    }
    assert.ok(err instanceof Error) // Ticket doesn't exist
  })

  // Task 4
  it("Has a function refund to refund tickets if a show gets cancelled", async() => {
    // balance customer B before refund
    const balance_customerB_before = web3.utils.toBN(await web3.eth.getBalance(customer_B))
    
    // balance customer C before refund
    const balance_customerC_before = web3.utils.toBN(await web3.eth.getBalance(customer_C))

    // status of show 1 before cancelling
    let show_1 = await ticketBookingSystem.getShow(show_1_id)
    assert.equal(show_1[3], show_1_status, 'Error: Status should be Scheduled')

    // cancel show 1
    let tx = await ticketBookingSystem.cancelShow(show_1_id, {from: salesManager_A})

    //truffleAssert.eventEmitted(tx, 'ShowCancelled', (ev) => {
    //  return ev.showId.toNumber() === show_1_id
    //});
    /*show_1_status = "Cancelled"

    // balance customer B after refund
    const balance_customerB_after = web3.utils.toBN(await web3.eth.getBalance(customer_B))
    expect(balance_customerB_after.sub(balance_customerB_before).toString()).to.equal(web3.utils.toBN(show_1_price).toString())
    
    // balance customer C after refund
    const balance_customerC_after = web3.utils.toBN(await web3.eth.getBalance(customer_C))
    expect(balance_customerC_after.sub(balance_customerC_before).toString()).to.equal(web3.utils.toBN(show_1_price).toString())
    
    // status of show 1 after cancelling
    show_1 = await ticketBookingSystem.getShow(show_1_id)
    assert.equal(show_1[3], show_1_status, 'Error: Status should be Cancelled')
    
    // ticket doesn't exist anymore*/
  })

  // Task 5
  it("Has a function validate to validate a ticket and a function releasePoster that releases a poster ID", async() => {

  })

  // Task 6
  it("Has a function tradeTicket that allows C and D to safely trade", async() => {

  })
});
