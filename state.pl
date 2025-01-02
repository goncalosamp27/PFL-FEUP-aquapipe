% state.pl
% defines the game state including board, configuration, player playing and the progress of both players

% Initialize the board as a 3x3 grid with three empty slots in each cell (small, medium, and large slots)
% generates all cells from (1,1) to (3,3) with 3 empty slots in each
initialize_board(Board) :-
    findall( % All instances where Goal is satisfied and Template is instantiated aggregated into a List
        cell(X, Y, [slot(small, empty), slot(medium, empty), slot(large, empty)]), % Template, slot(size, empty) for each of the sizes in each cell
        (between(1, 3, X), between(1, 3, Y)), % All possible combinations of X and Y from 1 to 3
        Board % Instantiated into Board variable
    ).

% Create the initial game state:
% - create the Board where the game will be played
% - create the configuration (e.g., H/H, H/PC, etc.)
% - choose the player for the current turn
% - the progress of both players (tracking sizes placed)

initial_state(game_config(_, _, _, StartingPlayer), state(Board, game_config(_, _, _, StartingPlayer), StartingPlayer, PlayerProgress)) :-
    initialize_board(Board), % Get the board 
    initialize_player_progress(PlayerProgress). % Get the player progress

% Initialize player progress for both players (empty since they have not put any pieces yet)
initialize_player_progress(progress([], [])).