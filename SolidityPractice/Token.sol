contract Token {
    address public minter;
    mapping(address => uint256) public balances;

    event Sent(address from, address to, uint256 amount);

    modifier onlyMinter {
        require(msg.sender == minter, "Only Minter can call this function!");
        _;
    }

    modifier greaterThanAmount(uint256 amount) {
        require(amount < 1e60);
        _;
    }

    modifier balanceGreaterThan(uint256 amount) { 
        require(amount <= balances[msg.sender], "Insufficient balance");
        _;
    }

    constructor() {
        minter = msg.sender;
    }

    function mint(address receiver, uint256 amount) public onlyMinter greaterThanAmount(amount) {
        balances[receiver] += amount;
    }

    function send(address receiver, uint256 amount) public balanceGreaterThan(amount) {
        balances[msg.sender] -= amount;
        balances[receiver] += amount;
        emit Sent(msg.sender, receiver, amount);
    }

}
