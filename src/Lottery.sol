//SPDX-License-Identifier: MIT 
pragma solidity ^0.8.20;

contract Lottery {
    address public owner;
    address[] public players;

    mapping(address => uint256) public playerEntries; // 각 주소의 참여 횟수
    address[] public winners; // 당첨자 주소 배열

    // 티켓 가격, 당첨자 수, 최대 참여 횟수 constant 변수 선언
    uint256 public constant TICKET_PRICE = 0.001 ether;
    uint256 public constant WINNERS_COUNT = 3;
    uint256 public constant MAX_ENTRIES = 3;

    // 이벤트 선언
    event PlayerEntered(address indexed player, uint256 entryCount);
    event WinnersPicked(address[] winners, uint256 prize);
    event OwnerTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        owner = msg.sender;
    }
    
    function enter() public payable {
        require(msg.value == TICKET_PRICE, "Invalid ticket price");
        require(playerEntries[msg.sender] < MAX_ENTRIES, "Max entries reached");

        playerEntries[msg.sender]++;
        players.push(msg.sender);

        emit PlayerEntered(msg.sender, playerEntries[msg.sender]);
    }
    
    // 랜덤 숫자 생성 encodePacked로 가스량 줄이고, 더 많은 조합으로 랜덤 숫자 생성
    // 검증된 안정성으로는 Chainlink VRF방식을 채택할 필요가 있습니다.
    function random() private view returns(uint) {
        return uint(keccak256(abi.encodePacked(
            block.prevrandao,
            block.timestamp,
            players,
            msg.sender
        )));
    }
    
    // 당첨자 수 3명으로 수정
    function pickWinner() public onlyOwner {
        require(players.length > 0, "No players");
        require(players.length >= WINNERS_COUNT, "Not enough players");

        uint256 prize = address(this).balance / WINNERS_COUNT;
        winners = new address[](WINNERS_COUNT);

        uint index = random() % players.length;

        for (uint i = 0; i < WINNERS_COUNT; i++) {
            uint winnerIndex = (index + i) % players.length;
            payable(players[winnerIndex]).transfer(prize);
            winners[i] = players[winnerIndex];
        }

        emit WinnersPicked(winners, prize);

        // 참여자들의 참여 횟수 초기화
        for (uint i = 0; i < players.length; i++) {
            if (playerEntries[players[i]] > 0) {
                delete playerEntries[players[i]];
            }
        }
        // 플레이어 초기화
        delete players;

    }

    // 당첨자 확인 (이벤트 로그로도 확인 가능)
    function getWinners() public view returns (address[] memory) {
        return winners;
    }
    
    // Q) 혹시 모르는 상황을 위해 구현했지만.. 필요한가?
    // A) 상황마다 다르겠지만 꼭 필요해 보이지는 않습니다. 만약 다양한 상황이 있겠지만 필요하다면 최대한 Lottery 기능에 문제가 되지않게
    //    Require을 활용하고, 함수명을 명확히 하는 방법이 좋을 것 같습니다.
    function emergencyWithdraw() public payable onlyOwner {
        // 조건을 추가하면 좋을 것 같습니다.
        // require(block.timestamp > lastPickWinner + 30 days, "Wait 30 days after last pick");
        // require(players.length == 0, "Game in progress");
	    payable(msg.sender).transfer(address(this).balance);
    }
    
    function transferOwnership(address _newOwner) public onlyOwner {
        emit OwnerTransferred(owner, _newOwner);
        owner = _newOwner;
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }
}