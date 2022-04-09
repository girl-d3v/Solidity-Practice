pragma solidity >=0.7.0 <0.9.0;

contract Game {

    uint256 public playerCount = 0;
    mapping(address => Player) public players;
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
    }
    function addPlayer(string memory firstName, string memory lastName) public {
        players[msg.sender] = Players(msg.sender, firstName, lastName, Level.Beginner);
        playerCount++;
    }
    function getPlayerLevel(address playerAddress) public view returns(Level) {
        return players[playerAddress].playerLevel;
    }
}