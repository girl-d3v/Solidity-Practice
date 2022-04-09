pragma solidity >=0.7.0 <0.9.0;

contract Game {
    uint256 public pot = 0; 
    uint256 public playerCount = 0;

    address public dealer;

    mapping(address => Player) public players;

    Player[] public playersInGame;

    enum Level {
        Beginner,
        Mid,
        Advanced
    }
        struct Player {
        address playerAddress;
        string firstName;
        string lastName;
        Level playerLevel;
        uint256 createdTime;
    }

    constructor() {
        dealer = msg.sender;
    }
     
    function addPlayer(string memory firstName, string memory lastName) private {
        Player memory newPlayer = Player(msg.sender, firstName, lastName, Level.Beginner, block.timestamp);
        players[msg.sender] = newPlayer;
        playersInGame.push(newPlayer);
    }
    function getPlayerLevel(address playerAddress) public view returns(Level) {
        Player storage player = players[playerAddress];
        return player.playerLevel;
    }
    function changePlayerLevel(address playerAddress) public {
        Player storage player = players[playerAddress];
        if (block.timestamp >= player.createdTime + 20) {
            player.playerLevel = Level.Mid;
        }
    }

    function joinGame(string memory firstName, string memory lastName) payable public {
        require(msg.value == 25 ether, "Must pay 25 eth to join :)");
        if (payable(dealer).send(msg.value)) {
            addPlayer(firstName, lastName);
            playerCount += 1; 
            pot += 25;
        }
    }


    function payOutWinners(address loserAddress) payable public {
        require(msg.sender == dealer, "Only dealer can pay out :)");
        require(msg.value == pot * (1 ether));
        uint256 payPerWinner = msg.value / (playerCount - 1);

        for (uint256 i =0; i < playersInGame.length; i++) {
            address currentPlayerAddress = playersInGame[i].playerAddress;
            if (currentPlayerAddress != loserAddress) {
                payable(currentPlayerAddress).transfer(payPerWinner);
            }
        }
    }
}