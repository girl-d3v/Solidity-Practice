pragma solidity >=0.7.0 <0.9.0;

contract BlindAuction {

    // Variables
    struct Bid {
        bytes32 blindedBid;
        uint256 deposit;
    }

    address payable public beneficiary;
    uint256 public biddingEnd;
    uint256 public revealEnd;
    bool public ended;

    mapping(address => Bid[]) public bids;

    address public highestBidder;
    uint256 public highestBid;

    mapping(address => uint256) pendingReturns;

    // Events
    event AuctionEnded(address winner, uint256 highestBidder);

    // Modifiers
    modifier onlyBefore(uint256 _time) {
        require(block.timestamp < _time);
        _;
    }
    modifier onlyAfter(uint256 _time) {
        require(block.timestamp > _time);
        _; 
    }

    // Constructor
    constructor(uint256 _biddingTime, uint256 _revealTime, address payable _beneficiary) {
        beneficiary = _beneficiary;
        biddingEnd = block.timestamp + _biddingTime;
        revealEnd = biddingEnd + _revealTime;

    }

    // Functions
    function generateBlindedBidBytes32(uint256 value, bool fake) public view returns(bytes32) {
        return keccak256(abi.encodePacked(value, fake));
    }

    function bid(bytes32 _blindedBid) public payable onlyBefore(biddingEnd){
        bids[msg.sender].push(Bid({
            blindedBid: _blindedBid, deposit: msg.value
        }));
    }
    function reveal(uint256[] memory _values, bool[] memory _fake) public onlyAfter(biddingEnd) onlyBefore(revealEnd) {
        uint256 length = bids[msg.sender].length;
        require(_values.length == length);
        require(_fake.length == length);

      //  uint256 refund; 
        for (uint256 i = 0; i < length; i++) {
            Bid storage bidToCheck = bids[msg.sender][i];
            (uint256 value, bool fake) = (_values[i], _fake[i]);
            if (bidToCheck.blindedBid != keccak256(abi.encodePacked(value, fake))) {
                continue;
            }
           // refund += bidToCheck.deposit;
            if (!fake && bidToCheck.deposit >= value) {
               if (!placeBid(msg.sender, value)) {
                   payable(msg.sender).transfer(bidToCheck.deposit * (1 ether));
          //         refund -= value;
               }
            }
            bidToCheck.blindedBid = bytes32(0);
        }
        // payable(msg.sender).transfer(refund);



    }
    function auctionEnd() public payable onlyAfter(revealEnd) {
        require(!ended);
        emit AuctionEnded(highestBidder, highestBid);
        ended = true;
        beneficiary.transfer(highestBid * (1 ether));


    }
    function withdraw() public {
        uint256 amount = pendingReturns[msg.sender];
        if (amount > 0) { 
            pendingReturns[msg.sender] = 0;

            payable(msg.sender).transfer(amount);
        }
        

    }
    function placeBid(address bidder, uint256 value) internal returns(bool success) {
        if (value <= highestBid) {
            return false;
        }
        if (highestBidder != address(0)) {
            pendingReturns[highestBidder] += highestBid;
        }
        highestBid = value;
        highestBidder = bidder;
        return true;

    }
}