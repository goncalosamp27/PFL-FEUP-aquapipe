% display.pl

group_rows([], _, []).                    % Base case: If the board is empty, there are no rows;
group_rows(Board, RowSize, [Row|Rows]) :-
    length(Row, RowSize),                 % Take the first RowSize elements;
    append(Row, Rest, Board),             % Split the board into the current row and the rest;
    group_rows(Rest, RowSize, Rows).      % Recur for the remaining cells;

% Display the entire game state
display_game(state(Board, _, CurrentPlayer, _)) :-
    write(''), nl,
    write('Current Game Board:'), nl,
    display_board(Board),
    format('Player: ~w~n', [CurrentPlayer]),
    write(''), nl.

% Display the board as a grid
display_board(Board) :-
    write('Game Board:'), nl,
    write('+--------------------+--------------------+--------------------+--------------------+'), nl,
    group_rows(Board, 4, Rows), % Group cells into rows of 4;
    process_rows(Rows).

% process each row (adding a separator);
process_rows([]).                                                   % Base case: No more rows to process;
process_rows([Row|Rest]) :-
    display_row(Row),                                               % Display the current row;
    write('+--------------------+--------------------+--------------------+--------------------+'), nl, % Print separator;
    process_rows(Rest).                                             % Recur for the remaining rows;

% Display a single row with all slots.
display_row([]) :-                                           % End the row with a closing | and a newline (base case);
    write('|'), nl. 
display_row([cell(_, _, Slots)|Rest]) :-
    cell_content(Slots, [S, M, L]),                          % Get the content of the slots;
    format('| [~w, ~w, ~w, ~w, ~w, ~w] ', [L, M, S, S, M, L]),                    % Display the slots;
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

% Display all valid moves for the current player;
display_moves(Moves) :-
    display_moves(Moves, 1).  
% Base case: No more moves to display;
display_moves([], _) :- 
    write(''), nl.
% Recursive case: Display a move with its index;
display_moves([Move | Rest], Index) :-
    format("~w: ~w~n", [Index, Move]),  % Display the index and move;
    NextIndex is Index + 1,             % Increment the index;
    display_moves(Rest, NextIndex).     % Recur for the remaining moves;
