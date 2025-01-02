% display.pl

group_rows([], _, []).                    % Base case: If the board is empty, there are no rows;
group_rows(Board, RowSize, [Row|Rows]) :-
    length(Row, RowSize),                 % Get the row size;
    append(Row, Rest, Board),             % Split the board into the current row and the rest;
    group_rows(Rest, RowSize, Rows).      % Recur for the remaining cells;

% Display the entire game state
display_game(state(Board, _, CurrentPlayer, _)) :-
    write(''), nl,
    write('Current Game Board:'), nl,
    display_board(Board),
    format('Player: ~w~n', [CurrentPlayer]), nl.

% Display the board as a grid
display_board(Board) :-
    write('Game Board:'), nl,
    write('+-----------+-----------+-----------+'), nl,
    group_rows(Board, 3, Rows), % Group cells into rows of 3
    process_rows(Rows).

% process each row (adding a separator);
process_rows([]).                                                   % Base case: No more rows to process;
process_rows([Row|Rest]) :-
    display_row(Row),                                               % Display the current row;
    write('+-----------+-----------+-----------+'), nl, % Print separator;
    process_rows(Rest).                                             % Recur for the remaining rows;

% Display a single row with all slots.
display_row([]) :-                                           % End the row with a closing | and a newline (base case);
    write('|'), nl. 
display_row([cell(_, _, Slots)|Rest]) :-
    cell_content(Slots, [S, M, L]),                          % Get the content of the slots;
    format('| [~w, ~w, ~w] ', [S, M, L]),                    % Display the slots;
    display_row(Rest).                                       % Recur for the remaining cells;

% Map the slots to their visual representation;
cell_content([slot(small, State), slot(medium, State2), slot(large, State3)], [S, M, L]) :-
    slot_visual(State, S),   % Map the state of the small slot;
    slot_visual(State2, M),  % Map the state of the medium slot;
    slot_visual(State3, L).  % Map the state of the large slot;

% Map slot states to display characters;
slot_visual(empty, 'E').   % Empty slots are displayed as 'E';
slot_visual(blue, 'B').    % Player 1 pieces are displayed as 'B';
slot_visual(red, 'R').     % Player 2 pieces are displayed as 'R';

% Display all valid moves, separating "place" and "move" moves;
display_moves([]) :-
    write('No moves are available.'), nl.

% Main predicate to display all moves
display_moves(Moves) :-
    % Separate the moves into "place" and "move" categories
    include(is_place_move, Moves, PlaceMoves),
    include(is_move_move, Moves, MoveMoves),

    % Display "place" moves
    display_place_moves(PlaceMoves, 1, NextIndex),

    write(''), nl,

    % Display "move" moves
    display_move_moves(MoveMoves, NextIndex).

% Predicate to display place moves
display_place_moves(PlaceMoves, CurrentIndex, NextIndex) :-
    PlaceMoves \= [],
    write('Place a New Piece - Moves:'), nl,
    display_moves_list(PlaceMoves, CurrentIndex, NextIndex).

display_place_moves([], 1, 1) :-
    write('You can not place any more pieces.'), nl.

% Predicate to display move moves
display_move_moves(MoveMoves, CurrentIndex) :-
    MoveMoves \= [],
    write('Move an existing Piece - Moves:'), nl,
    display_moves_list(MoveMoves, CurrentIndex, _).

display_move_moves([], _) :-
    write('You can not move any pieces.'), nl.

% Check if a move is a "place" move
is_place_move([place, _, _, _]).

% Check if a move is a "move" move
is_move_move([move, _, _, _, _, _]).

% Base case: No more moves to display
display_moves_list([], Index, Index).

% Recursive case: Display a move with its index;
display_moves_list([Move | Rest], Index, FinalIndex) :-
    format("~w: ~w~n", [Index, Move]),
    NextIndex is Index + 1,
    display_moves_list(Rest, NextIndex, FinalIndex).


