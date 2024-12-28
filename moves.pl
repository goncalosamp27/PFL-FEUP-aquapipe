% moves.pl
% Handles generating valid moves, executing moves, and updating the game state;

% Generate all valid moves for the current player;
valid_moves(state(Board, _, CurrentPlayer, _), Moves) :-
    % Generate all valid "place" moves (placing a new piece on the board); 
    findall([place, X, Y, Size],
            (member(cell(X, Y, Slots), Board),         % Iterate through the cells;
             member(slot(Size, empty), Slots),         % Check if the slot is empty;
             player_color(CurrentPlayer, PlayerColor), % Get the players color;
             valid_place(Size, PlayerColor)),          % Validate the piece (e.g., slot(small, blue));
            PlaceMoves),

    % Generate all valid "move" moves if the player can move pieces;
    (can_move_pieces(CurrentPlayer, Board) ->
        findall([move, X1, Y1, Size, X2, Y2],
                (member(cell(X1, Y1, Slots1), Board),     % Source cell;
                 member(slot(Size, PlayerColor), Slots1), % Check if the slot contains the players piece;
                 member(cell(X2, Y2, Slots2), Board),     % Target cell;
                 member(slot(Size, empty), Slots2)),      % Ensure the target slot is empty;
                MoveMoves)
    ; MoveMoves = []),

    % Combine both types of moves;
    append(PlaceMoves, MoveMoves, Moves).

% move(+GameState, +Move, -NewGameState)
move(GameState, Move, NewGameState) :-
    (   Move = [place, X, Y, Size] ->
        execute_place_move(GameState, X, Y, Size, NewGameState)
    ;   
		Move = [move, X1, Y1, Size, X2, Y2] ->
        execute_move_piece(GameState, X1, Y1, Size, X2, Y2, NewGameState)
    ).

% execute_place_move(+GameState, +X, +Y, +Size, -NewGameState)
execute_place_move(state(Board, Config, CurrentPlayer, PlayerProgress),X, Y, Size, state(NewBoard, Config, NextPlayer, NewProgress)) :-
    replace_cell(Board, X, Y, Size, CurrentPlayer, NewBoard), 				% Place the piece;
    update_progress(CurrentPlayer, Size, PlayerProgress, NewProgress), 		% Update progress;
    next_player(CurrentPlayer, NextPlayer). 								% Switch to the next player;

% replace_cell(+Board, +X, +Y, +Size, +Player, -NewBoard)
replace_cell(Board, X, Y, Size, Player, NewBoard) :-
    player_color(Player, Color),                              % Get the player color;
    maplist(update_cell(X, Y, Size, Color), Board, NewBoard). % Reconstruct the board;

% update_cell(+TargetX, +TargetY, +Size, +Color, +Cell, -UpdatedCell)
% Update the cell at (TargetX, TargetY) by modifying its slots, if it matches;
update_cell(TargetX, TargetY, Size, Color, cell(TargetX, TargetY, Slots), cell(TargetX, TargetY, UpdatedSlots)) :-
    update_slot_list(Slots, Size, Color, UpdatedSlots). % Update the slots for the matching cell;
% keep other cells untouched;
update_cell(_, _, _, _, Cell, Cell).

% update_slot_list(+Slots, +Size, +PlayerColor, -UpdatedSlots)
% Update the slot with the given Size, replacing its state with the PlayerColor;
update_slot_list([slot(Size, _)|Rest], Size, PlayerColor, [slot(Size, PlayerColor)|Rest]). % Update the matching slot;
update_slot_list([Slot|Rest], Size, PlayerColor, [Slot|UpdatedRest]) :-
    update_slot_list(Rest, Size, PlayerColor, UpdatedRest). 							   % Leave other slots unchanged;
update_slot_list([], _, _, []). 														   % Base case: Empty list;

% execute_move_piece(+GameState, +X1, +Y1, +Size, +X2, +Y2, -NewGameState)
execute_move_piece(state(Board, Config, CurrentPlayer, PlayerProgress),
                   X1, Y1, Size, X2, Y2,
                   state(NewBoard, Config, NextPlayer, PlayerProgress)) :-
    move_piece(Board, X1, Y1, X2, Y2, Size, NewBoard), 						 % Move the piece;
    next_player(CurrentPlayer, NextPlayer).            						 % Switch to the next player;

% move_piece(+Board, +X1, +Y1, +X2, +Y2, +Size, -NewBoard)
move_piece(Board, X1, Y1, X2, Y2, Size, NewBoard) :-
    select(cell(X1, Y1, Slots1), Board, TempBoard1),       					 % Find the source cell
    select(slot(Size, PlayerColor), Slots1, NewSlots1),    					 % Remove the piece from source
    select(cell(X2, Y2, Slots2), TempBoard1, TempBoard2),  					 % Find the target cell
    select(slot(Size, empty), Slots2, NewSlots2),          					 % Ensure the target slot is empty
    UpdatedSource = cell(X1, Y1, NewSlots1),               					 % Update source cell
    UpdatedTarget = cell(X2, Y2, [slot(Size, PlayerColor) | NewSlots2]),     % Update target cell
    append(TempBoard2, [UpdatedSource, UpdatedTarget], NewBoard). 			 % Replace the updated cells

% update_progress(+Player, +Size, +PlayerProgress, -NewProgress)
update_progress(player1, Size, progress(Player1Progress, Player2Progress), 
                progress(NewPlayer1Progress, Player2Progress)) :-
    (member(Size, Player1Progress) ->
        NewPlayer1Progress = Player1Progress
    ;
        NewPlayer1Progress = [Size | Player1Progress]
    ).

update_progress(player2, Size, progress(Player1Progress, Player2Progress), 
                progress(Player1Progress, NewPlayer2Progress)) :-
    (member(Size, Player2Progress) ->
        NewPlayer2Progress = Player2Progress
    ;
        NewPlayer2Progress = [Size | Player2Progress]
    ).

