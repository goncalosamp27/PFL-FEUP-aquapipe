% state.pl
% Defines the initial game state including board, configuration, player playing and the progress of both players

% initialize_board(-Board)
% Initialize the board as a 3x3 grid with three empty slots in each cell (small, medium, and large slots)
% Generates all cells from (1,1) to (3,3) with 3 empty slots in each
initialize_board(Board) :-
    findall(
        cell(X, Y, [slot(small, empty), slot(medium, empty), slot(large, empty)]), % Template, slot(size, empty) for each of the sizes in each cell
        (between(1, 3, X), between(1, 3, Y)), % All possible combinations of X and Y from 1 to 3
        Board % Instantiated into Board variable
    ).

% initialize_player_progress(-Progress)
% Initialize player progress for both players (empty since they have not put any pieces yet)
initialize_player_progress(progress([], [])).

% initialize_state(+GameConfig, -GameState)
% Create the initial game state:
% - create the configuration (e.g., H/H, H/PC, etc.)
% - choose the player for the current turn
% - the progress of both players (tracking sizes placed)
initial_state(game_config(Player1Type, Player2Type, StartingPlayer), state(Board, game_config(Player1Type, Player2Type, StartingPlayer), StartingPlayer, PlayerProgress)) :-
    initialize_board(Board), % Get the board 
    initialize_player_progress(PlayerProgress). % Get the player progress