% ai.pl
% Implements AI players with different strategies

% Random AI: Chooses a random move
choose_move(_, Moves, computer, Move) :-
    write('AI (Computer) selecting a random move...'), nl,
    random_member(Move, Moves),
    format("AI selected Move: ~w~n", [Move]).

% Strong Computer AI: Chooses the best move using minimax
choose_move(GameState, Moves, strong_computer, Move) :-
    write('AI (Strong Computer) selecting a smart move...'), nl,
    best_move(GameState, Moves, 4, -10000, 10000, BestMove, BestScore),
    ( BestMove = none ->
        write('No valid moves available for AI.'), nl,
        Move = none
    ;
        write('AI selected Best Move: '), writeln(BestMove),
        Move = BestMove
    ).

% Human Player: Prompts user for move
choose_move(_, Moves, human, ChosenMove) :-
    display_moves_with_indices(Moves),
    write('Enter the number of the move you want to make: '), nl,
    read(Index),
    ( 
        integer(Index), 
        Index >= 1, 
        length(Moves, Len),
        Index <= Len,
        nth1(Index, Moves, ChosenMove),
        !
    ;
        write('Invalid choice. Please try again.'), nl,
        choose_move(_, Moves, human, ChosenMove)
    ).

% Find the best move using minimax with alpha-beta pruning
best_move(_, [], _, _, _, _, -10000).
best_move(GameState, [Move|Moves], Depth, Alpha, Beta, BestMove, BestScore) :-
    move(GameState, Move, NewState),
    min_move(NewState, Depth-1, Alpha, Beta, _, Score),
    update_best_move(GameState, Move, Score, Moves, Depth, Alpha, Beta, BestMove, BestScore).

% Handle move updates for maximizing player
update_best_move(GameState, Move, Score, Moves, Depth, Alpha, Beta, BestMove, BestScore) :-
    Score > Alpha,
    !,
    best_move(GameState, Moves, Depth, Score, Beta, Move1, Score1),
    (Score > Score1 -> (BestMove = Move, BestScore = Score);
                      (BestMove = Move1, BestScore = Score1)).
update_best_move(GameState, _, _, Moves, Depth, Alpha, Beta, BestMove, BestScore) :-
    best_move(GameState, Moves, Depth, Alpha, Beta, BestMove, BestScore).

% Minimizing player's move
min_move(GameState, 0, _, _, _, Score) :-
    evaluate_position(GameState, Score),
    !.
min_move(GameState, _, _, _, _, Score) :-
    game_over(GameState, Winner),
    evaluate_winner(Winner, Score),
    !.
min_move(GameState, Depth, Alpha, Beta, BestMove, BestScore) :-
    valid_moves(GameState, Moves),
    min_move_list(GameState, Moves, Depth, Alpha, Beta, BestMove, BestScore).

% Process list of moves for minimizing player
min_move_list(_, [], _, _, Beta, _, Beta).
min_move_list(GameState, [Move|Moves], Depth, Alpha, Beta, BestMove, BestScore) :-
    move(GameState, Move, NewState),
    max_move(NewState, Depth-1, Alpha, Beta, _, Score),
    Score < Beta,
    !,
    min_move_list(GameState, Moves, Depth, Alpha, Score, Move, BestScore).
min_move_list(_, _, _, Alpha, Beta, _, Beta).

% Maximizing player's move
max_move(GameState, 0, _, _, _, Score) :-
    evaluate_position(GameState, Score),
    !.
max_move(GameState, _, _, _, _, Score) :-
    game_over(GameState, Winner),
    evaluate_winner(Winner, Score),
    !.
max_move(GameState, Depth, Alpha, Beta, BestMove, BestScore) :-
    valid_moves(GameState, Moves),
    max_move_list(GameState, Moves, Depth, Alpha, Beta, BestMove, BestScore).

% Process list of moves for maximizing player
max_move_list(_, [], _, Alpha, _, _, Alpha).
max_move_list(GameState, [Move|Moves], Depth, Alpha, Beta, BestMove, BestScore) :-
    move(GameState, Move, NewState),
    min_move(NewState, Depth-1, Alpha, Beta, _, Score),
    Score > Alpha,
    !,
    max_move_list(GameState, Moves, Depth, Score, Beta, Move, BestScore).
max_move_list(_, _, _, Alpha, Beta, _, Alpha).

% Evaluate the position based on piece placement and potential wins
evaluate_position(GameState, Score) :-
    state(Board, _, CurrentPlayer, _) = GameState,
    player_color(CurrentPlayer, Color),
    count_potential_wins(Board, Color, MyScore),
    next_player(CurrentPlayer, Opponent),
    player_color(Opponent, OpponentColor),
    count_potential_wins(Board, OpponentColor, OpponentScore),
    Score is MyScore - OpponentScore.

% Count potential winning lines for a given color
count_potential_wins(Board, Color, Score) :-
    findall(1, (member(Size, [small, medium, large]),
                (check_potential_row(Board, Size, Color);
                 check_potential_column(Board, Size, Color);
                 check_potential_diagonal(Board, Size, Color))), Scores),
    sum_list(Scores, Score).

% Check for potential wins in rows
check_potential_row(Board, Size, Color) :-
    between(1, 3, Y),
    findall(X, (between(1, 3, X),
                member(cell(X, Y, Slots), Board),
                \+ member(slot(Size, OpponentColor), Slots),
                (OpponentColor \= Color, OpponentColor \= empty)), Xs),
    length(Xs, Len),
    Len >= 2.

% Helper predicates for evaluating winner
evaluate_winner(Winner, Score) :-
    (Winner = player1 -> Score = 1000;
     Winner = player2 -> Score = -1000;
     Score = 0).