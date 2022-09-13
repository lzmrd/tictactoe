// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import './erc721.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/token/ERC721/IERC721.sol';
import '@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol';

contract Tris is Ownable {
    IERC721 TRR;
    address _owner;
    address private playerA;
    address private playerB;
    address public winner;
    uint256 private moveTaken;
    uint256 public session;
    uint256[] public reward;

    constructor(address _trr) {
        session = 15 seconds;
        _owner = msg.sender;
        TRR = IERC721(_trr);
    }

    struct Game {
        address lastPlayer;
        uint8[] gameBoard;
        address[9] moves; //->uint8
        uint256 lastMoveTimestamp;
        bool gameOver;
    }
    Game public game;

    event GameStarted(address playerA, address playerB);
    event MoveTaken(address player, uint8 move);
    event GameWon(address player, uint8 tokenId);
    event GameDraw();

    function addReward() external onlyOwner {
        for (uint256 i; i < TRR.balanceOf(_owner); i++) {
            TRR.transferFrom(_owner, address(this), i);
            reward.push(i);
        }
    }

    function newGame(address _player1, address _player2) external {
        require(
            _player1 != _owner && _player2 != _owner,
            'Owner is not allowed'
        );
        require(TRR.balanceOf(address(this)) >= 1, 'no reward');
        require(
            moveTaken == 0 ||
                block.timestamp > game.lastMoveTimestamp + (session * 2) ||
                isWinner() == true,
            'you are already playing'
        );

        delete game;
        playerA = _player1;
        playerB = _player2;
        moveTaken = 0;

        emit GameStarted(playerA, playerB);
    }

    function yourMove(uint8 _move) external turnsLogic {
        require(!game.gameOver, 'the game is over, start a new game');
        require(_move >= 0 && _move <= 8, 'move invalid');
        require(
            msg.sender == playerA || msg.sender == playerB,
            "this player isn't playing"
        );
        require(moveTaken < 10, 'game over');

        for (uint8 i; i < game.gameBoard.length; i++) {
            if (game.gameBoard[i] == _move) {
                revert('move already taken');
            }
        }

        game.moves[_move] = msg.sender;
        game.lastPlayer = game.moves[_move];
        game.lastMoveTimestamp = block.timestamp;

        Game storage _game = game;
        _game.gameBoard.push(_move);
        moveTaken++;

        if (moveTaken >= 3) {
            if (isWinner() == true) {
                winner = msg.sender;
                TRR.transferFrom(address(this), winner, reward[0]);
            } else if (moveTaken == 9 && isWinner() != true) {
                delete moveTaken;
            }
        }

        emit MoveTaken(msg.sender, _move);
    }

    function isWinner() internal view returns (bool) {
        if (
            (game.moves[0] == msg.sender &&
                game.moves[1] == msg.sender &&
                game.moves[2] == msg.sender) ||
            (game.moves[3] == msg.sender &&
                game.moves[4] == msg.sender &&
                game.moves[5] == msg.sender) ||
            (game.moves[6] == msg.sender &&
                game.moves[7] == msg.sender &&
                game.moves[8] == msg.sender) ||
            (game.moves[0] == msg.sender &&
                game.moves[3] == msg.sender &&
                game.moves[6] == msg.sender) ||
            (game.moves[1] == msg.sender &&
                game.moves[4] == msg.sender &&
                game.moves[7] == msg.sender) ||
            (game.moves[2] == msg.sender &&
                game.moves[5] == msg.sender &&
                game.moves[8] == msg.sender) ||
            (game.moves[0] == msg.sender &&
                game.moves[4] == msg.sender &&
                game.moves[8] == msg.sender) ||
            (game.moves[2] == msg.sender &&
                game.moves[4] == msg.sender &&
                game.moves[6] == msg.sender)
        ) {
            return true;
        } else {
            return false;
        }
    }

    modifier turnsLogic() {
        if (moveTaken == 0) {
            game.lastMoveTimestamp = block.timestamp;
        }

        if (block.timestamp > game.lastMoveTimestamp + (session * 2)) {
            game.gameOver == true;
        } else if (block.timestamp > game.lastMoveTimestamp + session) {
            require(msg.sender == game.lastPlayer, 'you missed your turn');
        } else if (block.timestamp <= game.lastMoveTimestamp + session) {
            require(msg.sender != game.lastPlayer, 'not your turn');
        }
        _;
    }
}
