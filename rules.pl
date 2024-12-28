% Validate a placement
valid_place(small, blue).
valid_place(medium, blue).
valid_place(large, blue).
valid_place(small, red).
valid_place(medium, red).
valid_place(large, red).

% can_move_pieces(+Player, +PlayerProgress)
can_move_pieces(player1, progress(Player1Progress, _)) :-
    member(small, Player1Progress),
    member(medium, Player1Progress),
    member(large, Player1Progress).

can_move_pieces(player2, progress(_, Player2Progress)) :-
    member(small, Player2Progress),
    member(medium, Player2Progress),
    member(large, Player2Progress).

% Check if a specific piece exists on the board
has_piece(Board, Piece) :-
    member(cell(_, _, Slots), Board),   % Iterate through all cells on the board;
    member(Piece, Slots).               % Check if the specific piece is in the slots;