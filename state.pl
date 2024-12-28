% state.pl;
% defines the game state including board, configuration, player playing and the progress of both players;

% Initialize the board as a 4x4 grid with three empty slots in each cell (small, medium, and large slots);
% generates all cells from (1,1) -> (4,4) with 3 empty slots in each;

initialize_board(Board) :-
    findall(cell(X, Y, [slot(small, empty), slot(medium, empty), slot(large, empty)]),(between(1, 4, X), between(1, 4, Y)), Board).

% Create the initial game state:
% - create the Board where the game will be played;
% - create the configuration (e.g., H/H, H/PC, etc.);
% - choose the player for the current turn (first turn -> player1);
% - the progress of both players (tracking sizes placed);

initial_state(game_config(_, _, _, StartingPlayer), state(Board, game_config(_, _, _, StartingPlayer), StartingPlayer, PlayerProgress)) :-
    initialize_board(Board),
    initialize_player_progress(PlayerProgress).

% Initialize player progress for both players (empty since they have not put any pieces yet);
initialize_player_progress(progress([], [])).