% moves.pl
% Handles generating valid moves, executing moves, and updating the game state;

% Generate all valid moves for the current player;
valid_moves(state(Board, _, CurrentPlayer, _), Moves) :-
    % Place moves
    findall([place, X, Y, Size],
            (member(cell(X, Y, Slots), Board),
             member(slot(Size, empty), Slots),
             player_color(CurrentPlayer, PlayerColor)),
            PlaceMoves),

    % Move moves
    (can_move_pieces(CurrentPlayer, Board) ->
        findall([move, X1, Y1, Size, X2, Y2],
                (member(cell(X1, Y1, Slots1), Board),
                 member(slot(Size, PlayerColor), Slots1),
                 player_color(CurrentPlayer, PlayerColor),
                 member(cell(X2, Y2, Slots2), Board),
                 (X1 \= X2; Y1 \= Y2),
                 member(slot(Size, empty), Slots2)),
                MoveMoves)
    ; MoveMoves = []),

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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%execute_move_piece(+GameState, +X1, +Y1, +Size, +X2, +Y2, -NewGameState)
%execute_move_piece(state(Board, Config, CurrentPlayer, PlayerProgress), X1, Y1, Size, X2, Y2, state(NewBoard, Config, NextPlayer, PlayerProgress)) :-
%    move_piece(Board, X1, Y1, X2, Y2, Size, NewBoard), % Move the piece
%    next_player(CurrentPlayer, NextPlayer).           % Switch to the next player
%
%% move_piece(+Board, +X1, +Y1, +X2, +Y2, +Size, -NewBoard)
%move_piece(Board, X1, Y1, X2, Y2, Size, NewBoard) :-
%    maplist(update_source_and_target(X1, Y1, X2, Y2, Size), Board, NewBoard).
%
%% update_source_and_target(+SourceX, +SourceY, +TargetX, +TargetY, +Size, +PlayerColor, +Cell, -UpdatedCell)
%
%% Case: Source cell - empty the specified slot
%update_source_and_target(SourceX, SourceY, TargetX, TargetY, Size, PlayerColor,cell(SourceX, SourceY, Slots),cell(SourceX, SourceY, UpdatedSlots)) :-
%    write('Emptying Source: '), write(SourceX), write(','), write(SourceY), nl,
%    write('Before: '), write(Slots), nl,
%    update_slot_list(Slots, Size, empty, UpdatedSlots),
%    write('After: '), write(UpdatedSlots), nl.
%
%% Case: Target cell - fill the specified slot with player's color
%update_source_and_target(SourceX, SourceY, TargetX, TargetY, Size, PlayerColor,cell(TargetX, TargetY, Slots), cell(TargetX, TargetY, UpdatedSlots)) :-
%    write('Filling Target: '), write(TargetX), write(','), write(TargetY), nl,
%    write('Before: '), write(Slots), nl,
%    update_slot_list(Slots, Size, PlayerColor, UpdatedSlots),
%    write('After: '), write(UpdatedSlots), nl.
%
%% Case: Leave all other cells unchanged
%update_source_and_target(_, _, _, _, _, _, Cell, Cell).
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% update_progress(+Player, +Size, +PlayerProgress, -NewProgress)
update_progress(player1, Size, progress(Player1Progress, Player2Progress),
                progress(NewPlayer1Progress, Player2Progress)) :-
    (member(Size, Player1Progress) -> % If size is already in progress, no update
        NewPlayer1Progress = Player1Progress
    ;
        NewPlayer1Progress = [Size | Player1Progress]).

update_progress(player2, Size, progress(Player1Progress, Player2Progress),
                progress(Player1Progress, NewPlayer2Progress)) :-
    (member(Size, Player2Progress) -> % If size is already in progress, no update
        NewPlayer2Progress = Player2Progress
    ;
        NewPlayer2Progress = [Size | Player2Progress]).
