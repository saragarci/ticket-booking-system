const Ticket = artifacts.require("Ticket");
const Poster = artifacts.require("Poster");
const TicketBookingSystem = artifacts.require("TicketBookingSystem");

module.exports = function(deployer) {
  deployer.deploy(Ticket);
  deployer.deploy(Poster);
  deployer.deploy(TicketBookingSystem, 
    2, // Number of shows
    ["Star wars", "The Lord of the Rings"], // Show title
    [3090233503328250, 3090233503328250], // Price per show
    [[1640628000, 1640800800], [1640714400, 1640887200]], // Available dates per show
    1, // Number of rooms
    [[2, 3]], // Available rooms (rows, columns)
    [[0, 0], [0, 0]], // room index per date
    "https://seatview.no/norwaycinema" // Link to gather seat views in every room
  );
};
