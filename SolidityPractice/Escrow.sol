pragma solidity >=0.7.0 <0.9.0;

contract Escrow {
    // Variables 
    enum State { NOT_INITIATED, AWAITING_PAYMENT, AWAITING_DELIVERY, COMPLETE }

    State public currentState;

    bool public isBuyerIn;
    bool public isSellerIn;

    uint256 public price;

    address public buyer;
    address payable public seller;

    // Modifiers
    modifier onlyBuyer() {
        require(msg.sender == buyer, "Only buyer can call this function :)");
        _;
    }

    modifier escrowNotStarted() {
        require(currentState == State.NOT_INITIATED);
        _;
    }

    // Constructor
    constructor(address _buyer, address payable _seller, uint256 _price) {
        buyer = _buyer;
        seller = _seller;
        price = _price * (1 ether);
    }

    // Functions
    function initContract() escrowNotStarted public {
        if(msg.sender == buyer) {
            isBuyerIn = true;
        }
        if(msg.sender == seller) {
            isSellerIn = true;
        }
        if(isBuyerIn && isSellerIn) {
            currentState = State.NOT_INITIATED;
        }
    }

    function deposit() onlyBuyer public payable {
        require(currentState == State.AWAITING_DELIVERY, "Already paid :)");
        require(msg.value == price, "Wrong deposit amount :)");
        currentState = State.AWAITING_DELIVERY;
    }

    function confirmDelivery() onlyBuyer public payable {
        require(currentState == State.AWAITING_DELIVERY, "Cannot confirm delivery :)");
        seller.transfer(price);
        currentState = State.COMPLETE;
    }

    function withdraw() onlyBuyer public payable {
        require(currentState == State.AWAITING_DELIVERY, "Cannot withdraw at this stage :)");
        payable(msg.sender).transfer(price);
        currentState = State.COMPLETE;


    }



}