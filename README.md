## tictactoe
# Requirements:
 * There are 3 main actors: 2 players and 1 deployer.
 * Deployer sends to smart contract x nfts, that will be reward for winners.
 * If there are not reward for winners, the game doesn't start.
 * Each player has a certain amount of time to make his move. If the move isn't take in that amount of time, he lose his turn and the other player can move.
 * If both players lose their turn, the result of the game will be a draw, and new players can start a new game.
 * If a move is the winning one, the smart contract will send the reward to the winner in the same transaction, and new players can start a new game.
