const Ticket = artifacts.require("Ticket");
const Poster = artifacts.require("Poster");
const TicketBookingSystem = artifacts.require("TicketBookingSystem");

module.exports = function(deployer) {
  deployer.deploy(Ticket);
  deployer.deploy(Poster);
  deployer.deploy(TicketBookingSystem);
};
