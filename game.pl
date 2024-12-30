% game.pl;
% Displays the game menu / Reads the configuration / Starts the game loop;

% Include random module for random number generation predicates, between for numeric ranges and lists to manipulate lists
:- use_module(library(random)).
:- use_module(library(between)).
:- use_module(library(lists)).

% Include the other .pl files
:- [display, moves, rules, state]. 

% Entry point of the game
play :-
    display_menu, % Prints the game menu to the console
    read_configuration(GameConfig), % Reads user input and validates game configuration
    initial_state(GameConfig, GameState), % Sets up the inital state of the game based on configuration
    game_cycle(GameState). % Starts the main game loop, until game is over

% Print the menu
display_menu :-
    write('Welcome to ~ Aqua Pipe ~ by Bruno and Goncalo'), nl,
    write('Choose your game mode:'), nl,
    write('(1.) Human vs Human (H/H)'), nl,
    write('(2.) Human vs Computer (H/PC)'), nl,
    write('(3.) Human vs Strong Computer (H/PC)'), nl,
    write('(4.) Strong Computer vs Strong Computer (PC/PC)'), nl,
    write('(5.) Quit'), nl. % 1-4 are game modes, 5 quits the game

% Assigns player1 the color blue, and player2 the color red, used for display and logic purposes
player_color(player1, blue).
player_color(player2, red).

% Maps each option to specific configurations, and does coin toss to define starting player
configure_game(1, game_config(human, human, normal, StartingPlayer)) :- coin_toss(StartingPlayer).
configure_game(2, game_config(human, computer, normal, StartingPlayer)) :- coin_toss(StartingPlayer).
configure_game(3, game_config(human, strong_computer, normal, StartingPlayer)) :- coin_toss(StartingPlayer).
configure_game(4, game_config(strong_computer, strong_computer, normal, StartingPlayer)) :- coin_toss(StartingPlayer).
configure_game(5, quit).

% Performs coin toss to define who is the starting player
coin_toss(Player) :-
    random(RandomFloat),
    (RandomFloat < 0.5 -> Player = player1; Player = player2).

% Read the configuration
read_configuration(GameConfig) :-
    read(Option), % Reads the input and stores it in Option variable
    (configure_game(Option, GameConfig) -> % If there is a valid game configuration
        (GameConfig = quit -> write('Goodbye!'), nl, halt; % When GameConfig is quit, print 'Goodbye!' and quit the game
         GameConfig = game_config(_, _, _, StartingPlayer), % Otherwise, write who is the starting player based on coin toss
         format("The starting player is: ~w~n", [StartingPlayer])) % Use format to print correct player
         ;
        write('Invalid option, please try again.'), nl, % In case no valid configuration was chosen, print the error
        read_configuration(GameConfig) % And try again
    ).

% Game cycle, this is the main loop
game_cycle(GameState) :-
    (game_over(GameState, Winner) -> % When we have game over, print who is the winner
        format("Game over! The winner is: ~w~n", [Winner]) 
        ;
        current_player(GameState, CurrentPlayer), % Extract current player
        display_game(GameState), % Display the game (display.pl)
        valid_moves(GameState, Moves), % Extract the valid moves (moves.pl)       
        display_moves(Moves), % Display the moves (display.pl)
        choose_move(Moves, ChosenMove), % Choose the next move and store it in ChosenMove
        move(GameState, ChosenMove, NewGameState), % Apply the chosen move (moves.pl)
        write('Move executed successfully.'), nl, % Print out success
        game_cycle(NewGameState) % Recursive call
    ).

% Extract the current player from the game state
current_player(state(_, _, CurrentPlayer, _), CurrentPlayer).

% next_player(+CurrentPlayer, -NextPlayer), this is basically a flip
next_player(player1, player2).
next_player(player2, player1).

% Allow the player to choose a move from the list of valid moves
choose_move(Moves, ChosenMove) :-
    write('Enter the number of the move you want to make: '), nl, % Write instruction
    read(Index), % Read the index from the player
    nth1(Index, Moves, ChosenMove), % Based on the index chosen from the possible moves, match it to ChosenMove
    !. % No backtrack once we find the move                                     
choose_move(Moves, ChosenMove) :-
    write('Invalid choice. Please try again.'), nl, % No match was made, print error
    choose_move(Moves, ChosenMove). % Recursive call for the function
