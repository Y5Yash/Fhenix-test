// SPDX-License-Identifier: BSD-3-Clause-Clear

pragma solidity >=0.8.19 <0.9.0;

import "@fhenixprotocol/contracts/FHE.sol";
// import "@fhenixprotocol/contracts/access/Permission.sol";


contract SealedBidding {
    uint public bidEndTime;
    mapping(address => euint8) internal _bids;
    mapping(euint8 => address) internal _rev;
    address[] public bidders;

    modifier unexpired() {
        require(block.timestamp < bidEndTime, "Bidding time has expired");
        _;
    }

    constructor(uint _biddingPeriod)
    {
        bidEndTime = block.timestamp + _biddingPeriod;
    }

    function bid(inEuint8 memory _bidBytes) public unexpired {
        require(!FHE.isInitialized(_bids[msg.sender]), "Bid received already");
        euint8 encryptedbid = FHE.asEuint8(_bidBytes);
        _bids[msg.sender] = encryptedbid;
        _rev[encryptedbid] = msg.sender;
        bidders.push(msg.sender);
    }

    function finalize() public view returns (address)
    {
        require(block.timestamp > bidEndTime, "Bidding is still on");
        uint256 _winningBidder = 0;
        euint8 _maxBid = _bids[bidders[_winningBidder]];
        for (uint256 i=1; i<bidders.length; ++i)
        {
            euint8 _newMaxBid = FHE.max(_bids[bidders[i]], _maxBid);
            _maxBid = _newMaxBid;
        }
        address _winner = _rev[_maxBid];
        return _winner;
    }
}