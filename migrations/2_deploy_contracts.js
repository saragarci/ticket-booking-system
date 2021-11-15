const Ticket = artifacts.require("Ticket");
const Poster = artifacts.require("Poster");
const TicketBookingSystem = artifacts.require("TicketBookingSystem");

/*module.exports = async function(deployer) {
  const ticket = await deployer.deploy(Ticket);
  const poster = await deployer.deploy(Poster);
  deployer.deploy(TicketBookingSystem, 
    ["Star wars", "The Lord of the Rings"], // Title per show
    [3090233503328250, 3090233503328250], // Price per show
    [[1640628000, 1640800800], [1640714400, 1640887200]], // Available dates per show
    [[2, 3]], // Available rooms (rows, columns)
    [[0, 0], [0, 0]], // Assignment of room (using index) per date
    "https://seatview.no/norwaycinema", // Link to gather seat views in every room
    ticket,
    poster
  );
};*/

module.exports = function (deployer) {
  deployer.then(async () => {
    await deployer.deploy(Ticket);
    const ticket = await Ticket.deployed();
    
    await deployer.deploy(Poster);
    const poster = await Poster.deployed();
    
    await deployer.deploy(TicketBookingSystem, 
      ["Star wars", "The Lord of the Rings"], // Title per show
      [3090233503328250, 3090233503328250], // Price per show
      [[1640628000, 1640800800], [1640714400, 1640887200]], // Available dates per show
      [[2, 3]], // Available rooms (rows, columns)
      [[0, 0], [0, 0]], // Assignment of room (using index) per date
      "https://seatview.no/norwaycinema", // Link to gather seat views in every room
      Ticket.address,
      Poster.address
    );
    
    await ticket.transferOwnership(TicketBookingSystem.address);
    //await poster.transferOwnership(TicketBookingSystem.address);
  })
};
