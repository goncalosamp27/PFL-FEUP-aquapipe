% moves.pl
% Handles generating valid moves, executing moves, and updating the game state

% Check if a player has already placed 3 pieces of a given size
has_max_pieces(Size, Progress) :-
    findall(Size, member(Size, Progress), PlacedPieces),
    length(PlacedPieces, 3).  % Changed from Count >= 3 to exactly 3

% Generate all valid moves for the current player
valid_moves(state(Board, _, CurrentPlayer, progress(Player1Progress, Player2Progress)), Moves) :-
    % Determine which progress list to use based on current player
    (CurrentPlayer = player1 -> CurrentProgress = Player1Progress
    ; CurrentProgress = Player2Progress),
    
    % Place moves - only if player hasn't used all pieces of that size
    findall([place, X, Y, Size],
            (member(cell(X, Y, Slots), Board),
             member(slot(Size, empty), Slots),
             player_color(CurrentPlayer, PlayerColor),
             valid_place(Size, PlayerColor),
             \+ has_max_pieces(Size, CurrentProgress)),
            PlaceMoves),

    % Move moves - only if player has exactly 3 pieces of a size
    findall([move, X1, Y1, Size, X2, Y2],
            (member(cell(X1, Y1, Slots1), Board),
             player_color(CurrentPlayer, PlayerColor),
             member(slot(Size, PlayerColor), Slots1),  % Find player's piece
             has_max_pieces(Size, CurrentProgress),    % Check for exactly 3 pieces
             member(cell(X2, Y2, Slots2), Board),
             member(slot(Size, empty), Slots2),       % Find empty slot of same size
             (X1 \= X2; Y1 \= Y2)),                   % Different position
            MoveMoves),

    append(PlaceMoves, MoveMoves, Moves).

% === EXECUTE MOVES ===
% move(+GameState, +Move, -NewGameState)
move(GameState, Move, NewGameState) :-
    (   Move = [place, X, Y, Size] ->
        execute_place_move(GameState, X, Y, Size, NewGameState)
    ;   
        Move = [move, X1, Y1, Size, X2, Y2] ->
        execute_move_piece(GameState, X1, Y1, Size, X2, Y2, NewGameState)
    ).


% execute_place_move(+GameState, +X, +Y, +Size, -NewGameState)
execute_place_move(state(Board, Config, CurrentPlayer, PlayerProgress), X, Y, Size, state(NewBoard, Config, NextPlayer, NewProgress)) :-
    replace_cell(Board, X, Y, Size, CurrentPlayer, NewBoard),          % Place the piece
    update_progress(CurrentPlayer, Size, PlayerProgress, NewProgress), % Update progress
    next_player(CurrentPlayer, NextPlayer).                            % Switch to the next player


% replace_cell(+Board, +X, +Y, +Size, +Player, -NewBoard)
replace_cell(Board, X, Y, Size, Player, NewBoard) :-
    player_color(Player, Color), % Get the player color
    maplist(update_cell(X, Y, Size, Color), Board, NewBoard). % Update the board cells

% update_cell(+TargetX, +TargetY, +Size, +Color, +Cell, -UpdatedCell)
update_cell(TargetX, TargetY, Size, Color,
            cell(TargetX, TargetY, Slots),
            cell(TargetX, TargetY, UpdatedSlots)) :-
    update_slot_list(Slots, Size, Color, UpdatedSlots). % Update the matching cell slots
update_cell(_, _, _, _, Cell, Cell). % Keep other cells unchanged


% update_slot_list(+Slots, +Size, +PlayerColor, -UpdatedSlots)
update_slot_list([slot(Size, _)|Rest], Size, PlayerColor, [slot(Size, PlayerColor)|Rest]). % Update matching slot
update_slot_list([Slot|Rest], Size, PlayerColor, [Slot|UpdatedRest]) :-
    update_slot_list(Rest, Size, PlayerColor, UpdatedRest).                                % Keep other slots unchanged
update_slot_list([], _, _, []).                                                            % Base case: Empty list

execute_move_piece(state(Board, Config, CurrentPlayer, PlayerProgress), X1, Y1, Size, X2, Y2, state(NewBoard, Config, NextPlayer, PlayerProgress)) :-
    player_color(CurrentPlayer, Color),
    % First, create intermediate board with source piece removed
    maplist(update_cell_source(X1, Y1, Size), Board, IntermediateBoard),
    % Then, update target cell with the piece
    maplist(update_cell_target(X2, Y2, Size, Color), IntermediateBoard, NewBoard),
    next_player(CurrentPlayer, NextPlayer).

% Update source cell - remove the piece
update_cell_source(X, Y, Size, cell(X, Y, Slots), cell(X, Y, UpdatedSlots)) :-
    % Update the slot list to set the specified size to empty
    update_slot_list(Slots, Size, empty, UpdatedSlots).
update_cell_source(_, _, _, Cell, Cell).  % Keep other cells unchanged

% Update target cell - place the piece
update_cell_target(X, Y, Size, Color, cell(X, Y, Slots), cell(X, Y, UpdatedSlots)) :-
    % Update the slot list to set the specified size to the player's color
    update_slot_list(Slots, Size, Color, UpdatedSlots).
update_cell_target(_, _, _, _, Cell, Cell).  % Keep other cells unchanged

% update_progress(+Player, +Size, +PlayerProgress, -NewProgress)
update_progress(player1, Size, progress(Player1Progress, Player2Progress),
                progress([Size | Player1Progress], Player2Progress)).

update_progress(player2, Size, progress(Player1Progress, Player2Progress),
                progress(Player1Progress, [Size | Player2Progress])).