% rules.pl
% defines winning conditions and verifies if some movements are allowed according to the rules of the game.

% Validate a placement
valid_place(small, blue).
valid_place(medium, blue).
valid_place(large, blue).
valid_place(small, red).
valid_place(medium, red).
valid_place(large, red).

% can_move_pieces(+Player, +Board)
can_move_pieces(Player, Board) :-
    player_color(Player, PlayerColor),                % Get the player's color
    findall(Size,
        (member(cell(_, _, Slots), Board),            % Iterate through all cells
         member(slot(Size, PlayerColor), Slots)),     % Check if the slot matches the player's color
        Sizes),
    subset([small, medium, large], Sizes).            % Check if all sizes are present

subset([], _). % An empty list is a subset of any list
subset([H|T], List) :-
    member(H, List), % Check if H is in List
    subset(T, List). % Recursive call for the rest of the elements

% has_piece(+Board, +Piece)
% Check if a specific piece exists on the board
has_piece(Board, Piece) :-
    member(cell(_, _, Slots), Board),   % Iterate through all cells on the board
    member(Piece, Slots).               % Check if the specific piece is in the slots

% game_over(+GameState, -Winner)
% Check if the game is over by determining if any player has won
game_over(state(Board, _, _, _), Winner) :-
    check_win(Board, blue),
    player_color(Winner, blue).

game_over(state(Board, _, _, _), Winner) :-
    check_win(Board, red),
    player_color(Winner, red).

% check_win(+Board, +Color)
% Check for a win in any direction and any size
check_win(Board, Color) :-
    (check_horizontal_win(Board, Color)
    ; check_vertical_win(Board, Color)
    ; check_diagonal_win(Board, Color)).

% check_horizontal_win(+Board, +Color)
% Check for horizontal wins by checking each row
check_horizontal_win(Board, Color) :-
    between(1, 3, Y),
    (check_row_win(Board, Y, small, Color)
    ; check_row_win(Board, Y, medium, Color)
    ; check_row_win(Board, Y, large, Color)).

% check_row_win(+Board, +Y, +Size, +Color)
% Check for a win in an individual row by checking if there is 3 of a certain Size on a certain Y of the same color
check_row_win(Board, Y, Size, Color) :-
    findall(X, 
        (between(1, 3, X),
         member(cell(X, Y, Slots), Board),
         member(slot(Size, Color), Slots)),
        Xs),
    length(Xs, 3).

% check_vertical_win(+Board, +Color)
% Check for vertical wins by checking each column
check_vertical_win(Board, Color) :-
    between(1, 3, X),
    (check_column_win(Board, X, small, Color)
    ; check_column_win(Board, X, medium, Color)
    ; check_column_win(Board, X, large, Color)).

% check_column_win(+Board, +X, +Size, +Color)
% Check for a win in an individual row by checking if there is 3 of a certain Size on a certain X of the same color
check_column_win(Board, X, Size, Color) :-
    findall(Y,
        (between(1, 3, Y),
         member(cell(X, Y, Slots), Board),
         member(slot(Size, Color), Slots)),
        Ys),
    length(Ys, 3).

% check_diagonal_win(+Board, +Color)
% Check for diagonal wins, for each size and with a certain color for the 2 diagonals
check_diagonal_win(Board, Color) :-
    (check_diagonal1_win(Board, small, Color)
    ; check_diagonal1_win(Board, medium, Color)
    ; check_diagonal1_win(Board, large, Color)
    ; check_diagonal2_win(Board, small, Color)
    ; check_diagonal2_win(Board, medium, Color)
    ; check_diagonal2_win(Board, large, Color)).

% check_diagonal1_win(+Board, +Size, +Color)
% Main diagonal (top-left to bottom-right), see if (1,1) / (2,2) / (3,3) for a certain Color and for a certain Size have 3 Matches, which indicates a line
check_diagonal1_win(Board, Size, Color) :-
    findall(1, 
        (between(1, 3, I),
         member(cell(I, I, Slots), Board),
         member(slot(Size, Color), Slots)),
        Matches),
    length(Matches, 3).

% check_diagonal2_win(+Board, +Size, +Color)
% Second diagonal (top-right to bottom-left), see if (1,3) / (2,2) / (3,1) for a certain Color and for a certain Size have 3 Matches, which indicates a line
check_diagonal2_win(Board, Size, Color) :-
    findall(1,
        (between(1, 3, I),
         J is 4-I, % Relation between row and column is this
         member(cell(I, J, Slots), Board),
         member(slot(Size, Color), Slots)),
        Matches),
    length(Matches, 3).
