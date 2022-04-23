# Ticket Booking System

This application implements an Etherem smart contract using Solidity. The goal of this smart contract, `TicketBookingSystem`, is to manage ticket sales for shows in theatre or cinemas, and to maintain a public collection of shows that each user has attended. Two Non-Fungible Tokens (NFTs) `Ticket` and `Poster` are used to achieve this.

## Usage

### Dependencies
* node v14.17.0
* npm 6.14.13
* Truffle v5.3.9
* Ganache CLI v6.12.2

### Installation
First, `cd` into the project and install all the npm dependencies:
```
npm install
```
The same needs to be done for the client. `cd` into `client` and install all the npm dependencies.

### Development of smart contracts
```
truffle develop
```

### Compile and migrate smart contracts
```
compile
migrate
```

### Run tests
Open a new terminal and run ganache setting the time for the first block:
```
// in another terminal (i.e. not in the truffle develop prompt)
ganache-cli --time 2021-12-28T17:00:00
```

Then, back into the first terminal, run the tests using truffle:
```
truffle console
truffle test
```

### Development of react app
First, any smart contract changes must be manually recompiled and migrated.
Then, run the react app:
```
// in another terminal (i.e. not in the truffle develop prompt)
cd client
npm run start
```

## Application functionality

This allows a user to:
* **buy**: Buy a ticket for a specific show, date and seat. Upon completetion of this step, the user receives a `Ticket` token.
* **verify**: Allows anyone with the token ID to check the validity of the ticket and the address it is supposed to be used by.
* **refund**: This function refunds the tickets if the show gets cancelled.
* **validate**: It can be called only in a specific time frame, corresponding to 2h before the beginning of the show. Upon validation, the ticket is destroyed, and a `Poster` is released as a unique proof of purchase.
* **tradeTicket**: Allows two users to safely trade (i.e. exchange for another or sell for ether) a ticket directly between each other.

## Credits

### Used resources

* [React Truffle Box](https://trufflesuite.com/boxes/react/)
* [Open Zeppelin](https://docs.openzeppelin.com/)
* [Solidity](https://docs.soliditylang.org/en/latest/)

### Contributors

* [Sara Garci](s@saragarci.com)

## License

© Copyright 2021 by Sara Garci. All rights reserved.
