% Validate a placement
valid_place(small, blue).
valid_place(medium, blue).
valid_place(large, blue).
valid_place(small, red).
valid_place(medium, red).
valid_place(large, red).

can_move_pieces(Player, Board) :-
    write("DEBUG: Checking if player can move pieces: "), write(Player), nl,
    findall(Size, 
        (member(cell(_, _, Slots), Board),
         member(slot(Size, PlayerColor), Slots),
         player_color(Player, PlayerColor)),
        Sizes),
    write("DEBUG: Sizes Found: "), write(Sizes), nl,
    subset([small, medium, large], Sizes).

subset([], _). % An empty list is a subset of any list;
subset([H|T], List) :-
    member(H, List), % Check if H is in List;
    subset(T, List). % Recursive call for the rest of the elements;


% Check if a specific piece exists on the board
has_piece(Board, Piece) :-
    member(cell(_, _, Slots), Board),   % Iterate through all cells on the board;
    member(Piece, Slots).               % Check if the specific piece is in the slots;