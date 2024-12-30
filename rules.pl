% Validate a placement
valid_place(small, blue).
valid_place(medium, blue).
valid_place(large, blue).
valid_place(small, red).
valid_place(medium, red).
valid_place(large, red).

can_move_pieces(Player, Board) :-
    player_color(Player, PlayerColor),                % Get the player's color
    findall(Size,
        (member(cell(_, _, Slots), Board),            % Iterate through all cells
         member(slot(Size, PlayerColor), Slots)),     % Check if the slot matches the player's color
        Sizes),
    subset([small, medium, large], Sizes).            % Check if all sizes are present

subset([], _). % An empty list is a subset of any list;
subset([H|T], List) :-
    member(H, List), % Check if H is in List;
    subset(T, List). % Recursive call for the rest of the elements;

% Check if a specific piece exists on the board
has_piece(Board, Piece) :-
    member(cell(_, _, Slots), Board),   % Iterate through all cells on the board;
    member(Piece, Slots).               % Check if the specific piece is in the slots;

% Check if the game is over
game_over(state(Board, _, CurrentPlayer, _), Winner) :-
    % Check for a win in any direction
    (check_win(Board, blue) -> player_color(Winner, blue)
    ; check_win(Board, red) -> player_color(Winner, red)
    ; false).

% Check for a win in any direction and any size
check_win(Board, Color) :-
    (check_horizontal_win(Board, Color)
    ; check_vertical_win(Board, Color)
    ; check_diagonal_win(Board, Color)).

% Check for horizontal wins
check_horizontal_win(Board, Color) :-
    between(1, 3, Y),
    (check_row_win(Board, Y, small, Color)
    ; check_row_win(Board, Y, medium, Color)
    ; check_row_win(Board, Y, large, Color)).

check_row_win(Board, Y, Size, Color) :-
    findall(X, 
        (between(1, 3, X),
         member(cell(X, Y, Slots), Board),
         member(slot(Size, Color), Slots)),
        Xs),
    length(Xs, 3).

% Check for vertical wins
check_vertical_win(Board, Color) :-
    between(1, 3, X),
    (check_column_win(Board, X, small, Color)
    ; check_column_win(Board, X, medium, Color)
    ; check_column_win(Board, X, large, Color)).

check_column_win(Board, X, Size, Color) :-
    findall(Y,
        (between(1, 3, Y),
         member(cell(X, Y, Slots), Board),
         member(slot(Size, Color), Slots)),
        Ys),
    length(Ys, 3).

% Check for diagonal wins
check_diagonal_win(Board, Color) :-
    (check_diagonal1_win(Board, small, Color)
    ; check_diagonal1_win(Board, medium, Color)
    ; check_diagonal1_win(Board, large, Color)
    ; check_diagonal2_win(Board, small, Color)
    ; check_diagonal2_win(Board, medium, Color)
    ; check_diagonal2_win(Board, large, Color)).

% Main diagonal (top-left to bottom-right)
check_diagonal1_win(Board, Size, Color) :-
    findall(1, 
        (between(1, 3, I),
         member(cell(I, I, Slots), Board),
         member(slot(Size, Color), Slots)),
        Matches),
    length(Matches, 3).

% Secondary diagonal (top-right to bottom-left)
check_diagonal2_win(Board, Size, Color) :-
    findall(1,
        (between(1, 3, I),
         J is 4-I,
         member(cell(I, J, Slots), Board),
         member(slot(Size, Color), Slots)),
        Matches),
    length(Matches, 3).