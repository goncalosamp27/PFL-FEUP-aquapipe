% moves.pl
% Handles generating valid moves, executing moves, and updating the game state

% Check if a player has already placed 3 pieces of a given size
has_max_pieces(Size, Progress) :-
    findall(Size, member(Size, Progress), PlacedPieces),
    length(PlacedPieces, 3).

% Generate all valid moves for the current player
valid_moves(state(Board, _, CurrentPlayer, progress(Player1Progress, Player2Progress)), Moves) :-
    % Unify the current player and his progress with the appropriate turn
    (CurrentPlayer = player1 -> CurrentProgress = Player1Progress
    ; CurrentProgress = Player2Progress),
    
    % Find all place moves
    findall([place, X, Y, Size], % Template for place (place, coordinates, piece size)
            (member(cell(X, Y, Slots), Board), % Must be a cell in the board
             member(slot(Size, empty), Slots), % Must be an empty slot
             player_color(CurrentPlayer, PlayerColor), % Get the color based on player
             valid_place(Size, PlayerColor), % Checks for appropriate size and color
             \+ has_max_pieces(Size, CurrentProgress)), % Ensure the player hasn't reached the maximum number of pieces of this size
            PlaceMoves), % Store in PlaceMoves

    findall([move, X1, Y1, Size, X2, Y2], % Template for move (move, source coordinates, piece size, destination coordinates)
            (member(cell(X1, Y1, Slots1), Board),
             player_color(CurrentPlayer, PlayerColor), % Match the color to player
             member(slot(Size, PlayerColor), Slots1), % Match the slot inside the cell to appropriate color and size
             has_max_pieces(Size, CurrentProgress), % Must have max pieces placed already to move
             member(cell(X2, Y2, Slots2), Board),
             member(slot(Size, empty), Slots2), % Must be an empty cell with matched size
             (X1 \= X2; Y1 \= Y2)), % Can't move to the place where it is in
            MoveMovesWithDuplicates), % Put them all in MoveMoves

    sort(MoveMovesWithDuplicates, MoveMoves), % Remove duplicates using sort

    append(PlaceMoves, MoveMoves, Moves),
    Moves \= []. % Ensure there are valid moves

% Execute move and validate it's legal
move(GameState, Move, NewGameState) :-
    valid_moves(GameState, ValidMoves), % Get the valid moves
    member(Move, ValidMoves), % See if the move is part of the valid moves
    % Depending on place vs move, call the correct predicate
    (Move = [place|_] -> execute_place_move(GameState, Move, NewGameState)
    ; Move = [move|_] -> execute_move_piece(GameState, Move, NewGameState)).

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