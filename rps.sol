pragma solidity ^0.4.25;

contract RockPaperScissors 
{
    uint constant gameCost = 1 ether; // цена игры
    
    address player1;             // игрок 1
    address player2;             // игрок 2
    
    int player1Choice = 0;           //not public!!! test // выбор 1 игрока
    int player2Choice = 0;
    
    bytes32 player1ChoiceHash; //not public!!! test // выбор 1 игрока
    bytes32 player2ChoiceHash; //not public!!! test // выбор 2 игрока
    
    mapping (int => mapping(int => int)) combination;
    
    uint public firstRevealTime;
    
    modifier costs(uint _amount) {
        require(
            msg.value >= _amount,
            "Not enough Ether provided. Need 1 Ether"
        );
        _;
        if (msg.value > _amount)
            msg.sender.transfer(msg.value - _amount); // отправить излишки обратно
    }
    
    modifier isPlayersJoinGame() {
		require(msg.sender==player1 || msg.sender==player2,
		"Player not in Game. Please, join Game");
		_;
	}
    
	modifier choicePattern(string choice){
		require(keccak256(choice) == keccak256("rock") || keccak256(choice) == keccak256("paper") || keccak256(choice) == keccak256("scissors"),
		"Choice not in values: rock, paper or scissors");
		_;
	}
	
	modifier bothMakeChoice(){
		require(player1Choice != 0 && player2Choice != 0);
		_;
	}

    constructor() public {
        // 1 - rock, 2 - paper, 3 - scissors | [player1Choice][player2Choice] - winner
        combination[1][1] = 0; // winner - null
        combination[2][2] = 0; // winner - null
        combination[3][3] = 0; // winner - null
        combination[3][1] = 2; // winner - player2
        combination[1][3] = 1; // winner - player1
        combination[1][2] = 2; // winner - player2
        combination[2][1] = 1; // winner - player1
        combination[2][3] = 2; // winner - player2
        combination[3][2] = 1; // winner - player1
    }
    
    function joinGame() public payable costs(gameCost) { 
        if (player1 == address(0))
            player1 = msg.sender;
        else if (player2 == address(0))   
            player2 = msg.sender;
    }

    function playGame(string choice) public choicePattern(choice) isPlayersJoinGame() returns (bool) {
        if (msg.sender == player1)
            player1ChoiceHash = keccak256(choice);
        else if (msg.sender == player2)
            player2ChoiceHash = keccak256(choice);
        if(msg.sender == player1) {
            if (keccak256(choice) == keccak256("rock")) {
                player1Choice = 1;
                if (firstRevealTime == 0)       // счетчик времени
                    firstRevealTime = now;
                if (player2Choice != 0)
                    setWinner();
                return true;
            }
            if (keccak256(choice) == keccak256("paper")) {
                player1Choice = 2;
                if (firstRevealTime == 0)       // счетчик времени
                    firstRevealTime = now;
                if (player2Choice != 0)
                    setWinner();
                return true;
            }
            if (keccak256(choice) == keccak256("scissors")) {
                player1Choice = 3;
                if (firstRevealTime == 0)       // счетчик времени
                    firstRevealTime = now;
                if (player2Choice != 0)
                    setWinner();
                return true;
            }
        }
        if(msg.sender == player2) {
            if (keccak256(choice) == keccak256("rock")) {
                player2Choice = 1;
                if (firstRevealTime == 0)       // счетчик времени
                    firstRevealTime = now;
                if (player1Choice != 0)
                    setWinner();
                return true;
            }
            if (keccak256(choice) == keccak256("paper")) {
                player2Choice = 2;
                if (firstRevealTime == 0)       // счетчик времени
                    firstRevealTime = now;
                if (player1Choice != 0)
                    setWinner();
                return true;
            }
            if (keccak256(choice) == keccak256("scissors")) {
                player2Choice = 3;
                if (firstRevealTime == 0)       // счетчик времени
                    firstRevealTime = now;
                if (player1Choice != 0)
                    setWinner();
                return true;
            }
        }
        return false;
    }
    
    function setWinner() bothMakeChoice payable returns (int) {
            if (now > firstRevealTime + 60) {               // проверка таймера певрым игроком, если второй игрок не отвечает
                player1.transfer(this.balance/2);
                player2.transfer(this.balance);
                resetParams();
                return -1;
            }
            else if (player1Choice != 0 && player2Choice != 0) {
                int winner = combination[player1Choice][player2Choice];
                if (winner == 1) {                    // 1 игрок победил
                    player1.transfer(this.balance);
                    resetParams();
                    return 1;
                }
                else if (winner == 2) {              // 2 игрок победил
                    player2.transfer(this.balance);
                    resetParams();
                    return 2;
                }
                else {
                    player1.transfer(this.balance/2);
                    player2.transfer(this.balance);
                    resetParams();
                    return 0;
                }
            }
    }
    
    function checkTimer() public payable isPlayersJoinGame() returns (bool) {
        if (now > firstRevealTime + 60) {               // проверка таймера певрым игроком, если второй игрок не отвечает | после 1 минуты - возврат
                player1.transfer(this.balance/2);
                player2.transfer(this.balance);
                resetParams();
                return true;
            }
        return false;
    }
    
    function resetParams() private {
        player1Choice = 0;
        player2Choice = 0;
        player1 = address(0);
        player2 = address(0);
        firstRevealTime = 0;
    }
}
