% moves.pl
% Handles generating valid moves, executing moves, and updating the game state

% Check if a player has already placed 3 pieces of a given size
has_max_pieces(Size, Progress) :-
    findall(Size, member(Size, Progress), PlacedPieces),
    length(PlacedPieces, 3).

% Generate all valid moves for the current player
valid_moves(state(Board, _, CurrentPlayer, progress(Player1Progress, Player2Progress)), Moves) :-
    % Determine the current player's progress
    get_current_progress(CurrentPlayer, Player1Progress, Player2Progress, CurrentProgress),

    % Find all possible place moves
    find_place_moves(Board, CurrentPlayer, CurrentProgress, PlaceMoves),

    % Find all possible move moves
    find_move_moves(Board, CurrentPlayer, CurrentProgress, MoveMovesWithDuplicates),

    % Remove duplicate move moves
    sort(MoveMovesWithDuplicates, MoveMoves),

    % Combine place and move moves
    append(PlaceMoves, MoveMoves, CombinedMoves),

    % Ensure there are valid moves
    CombinedMoves \= [],

    % Unify the combined moves with the output variable
    Moves = CombinedMoves.

% Predicate to determine the current player's progress
get_current_progress(player1, Player1Progress, _Player2Progress, Player1Progress).
get_current_progress(player2, _Player1Progress, Player2Progress, Player2Progress).

% Predicate to find all possible place moves
find_place_moves(Board, CurrentPlayer, CurrentProgress, PlaceMoves) :-
    findall(
        [place, X, Y, Size], % Template for place move
        (
            member(cell(X, Y, Slots), Board),                  % Must be a cell in the board
            member(slot(Size, empty), Slots),                  % Must be an empty slot
            player_color(CurrentPlayer, PlayerColor),          % Get the color based on player
            valid_place(Size, PlayerColor),                    % Check for appropriate size and color
            \+ has_max_pieces(Size, CurrentProgress)           % Ensure the player hasn't reached the max pieces of this size
        ),
        PlaceMoves
    ).

% auxiliar function that ensures that either x1 is diff from x2 or y1 is diff from y2
at_least_one_different(X1, Y1, X2, Y2) :- 
    X1 \= X2, !.
at_least_one_different(X1, Y1, X2, Y2) :-
    X1 = X2, Y1 \= Y2.

% Predicate to find all possible move moves
find_move_moves(Board, CurrentPlayer, CurrentProgress, MoveMoves) :-
    findall(
        [move, X1, Y1, Size, X2, Y2], % Template for move
        (
            member(cell(X1, Y1, Slots1), Board),                  % Source cell
            player_color(CurrentPlayer, PlayerColor),             % Get the color based on player
            member(slot(Size, PlayerColor), Slots1),              % Source slot with correct size and color
            has_max_pieces(Size, CurrentProgress),                % Must have max pieces placed to move
            member(cell(X2, Y2, Slots2), Board),                  % Destination cell
            member(slot(Size, empty), Slots2),                    % Destination slot must be empty and same size
            at_least_one_different(X1, Y1, X2, Y2)                % Destination must be different from source
        ),
        MoveMovesWithDuplicates
    ),
    % Remove duplicate move moves
    sort(MoveMovesWithDuplicates, MoveMoves).

% Execute move and validate it's legal
move(GameState, Move, NewGameState) :-
    valid_moves(GameState, ValidMoves),       % Get the valid moves
    member(Move, ValidMoves),                 % See if the move is part of the valid moves
    execute_move_based_on_type(GameState, Move, NewGameState).

% Predicate to execute the move based on its type
execute_move_based_on_type(GameState, [place | PlaceArgs], NewGameState) :-
    execute_place_move(GameState, [place | PlaceArgs], NewGameState).

execute_move_based_on_type(GameState, [move | MoveArgs], NewGameState) :-
    execute_move_piece(GameState, [move | MoveArgs], NewGameState).

% Optional: Handle unexpected move types gracefully
execute_move_based_on_type(_, Move, _) :-
    write('Error: Unknown move type encountered: '), write(Move), nl,
    fail.

% Execute place move, the state after is the last argument of the predicate
execute_place_move(state(Board, Config, CurrentPlayer, PlayerProgress), [place, X, Y, Size], state(NewBoard, Config, NextPlayer, NewProgress)) :-
    player_color(CurrentPlayer, Color), % Get the color based on current player
    replace_cell(Board, X, Y, Size, Color, NewBoard), % Call the predicate to replace the empty cell
    update_progress(CurrentPlayer, Size, PlayerProgress, NewProgress), % Update the Progress list
    next_player(CurrentPlayer, NextPlayer). % Switch player

% Execute move piece, same as place but with different middle argument for a more complex operation
execute_move_piece(state(Board, Config, CurrentPlayer, PlayerProgress), [move, X1, Y1, Size, X2, Y2], state(NewBoard, Config, NextPlayer, PlayerProgress)) :-
    player_color(CurrentPlayer, Color), % Retrieve the color
    maplist(update_cell_source(X1, Y1, Size), Board, TempBoard), 
    % Place piece at destination
    maplist(update_cell_target(X2, Y2, Size, Color), TempBoard, NewBoard),
    next_player(CurrentPlayer, NextPlayer).

% Cell update helpers
replace_cell(Board, X, Y, Size, Color, NewBoard) :-
    maplist(update_cell(X, Y, Size, Color), Board, NewBoard).

update_cell(X, Y, Size, Color, cell(X, Y, Slots), cell(X, Y, UpdatedSlots)) :-
    update_slot_list(Slots, Size, Color, UpdatedSlots), !.
update_cell(_, _, _, _, Cell, Cell).

update_cell_source(X, Y, Size, cell(X, Y, Slots), cell(X, Y, UpdatedSlots)) :-
    update_slot_list(Slots, Size, empty, UpdatedSlots), !.
update_cell_source(_, _, _, Cell, Cell).

update_cell_target(X, Y, Size, Color, cell(X, Y, Slots), cell(X, Y, UpdatedSlots)) :-
    update_slot_list(Slots, Size, Color, UpdatedSlots), !.
update_cell_target(_, _, _, _, Cell, Cell).

% Update slots in a cell
update_slot_list([slot(Size, _)|Rest], Size, NewState, [slot(Size, NewState)|Rest]) :- !.
update_slot_list([Slot|Rest], Size, NewState, [Slot|UpdatedRest]) :-
    update_slot_list(Rest, Size, NewState, UpdatedRest).
update_slot_list([], _, _, []).

% Update player progress
update_progress(player1, Size, progress(P1Progress, P2Progress),
               progress([Size|P1Progress], P2Progress)).
update_progress(player2, Size, progress(P1Progress, P2Progress),
               progress(P1Progress, [Size|P2Progress])).