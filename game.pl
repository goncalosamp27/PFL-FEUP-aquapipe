% game.pl
% Displays the game menu / Reads the configuration / Starts the game loop

% Include random module for random number generation predicates, between for numeric ranges and lists to manipulate lists
:- use_module(library(random)).
:- use_module(library(between)).
:- use_module(library(lists)).

% Include the other .pl files
:- [display, moves, rules, state, ai, cleanup]. 

% Entry point of the game
play :-
    clear_data, % Clear all data before starting a new game
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

% player_color(+Player, -Color)
% Assigns player1 the color blue, and player2 the color red, used for display and logic purposes
player_color(player1, blue).
player_color(player2, red).

% configure_game(+Option, -GameConfig)
% Maps each option to specific configurations, and does coin toss to define starting player
configure_game(1, game_config(human, human, StartingPlayer)) :- coin_toss(StartingPlayer).
configure_game(2, game_config(human, computer, StartingPlayer)) :- coin_toss(StartingPlayer).
configure_game(3, game_config(human, strong_computer, StartingPlayer)) :- coin_toss(StartingPlayer).
configure_game(4, game_config(strong_computer, strong_computer, StartingPlayer)) :- coin_toss(StartingPlayer).
configure_game(5, quit).

% coing_toss(-Player)
% Performs coin toss to define who is the starting player, 50/50 chance for each
coin_toss(Player) :-
    random(RandomFloat),
    RandomFloat < 0.5, 
    Player = player1.

coin_toss(Player) :-
    random(RandomFloat),
    RandomFloat >= 0.5, 
    Player = player2.

% read_configuration(-GameConfig)
% Main predicate to read and process the game configuration
read_configuration(GameConfig) :-
    read(Option), % I/O operation to get the configuration chosen
    configure_game_option(Option, GameConfig).

% configure_game_option(+Option, -GameConfig)
% Handle the case where the option leads to a valid game configuration
configure_game_option(Option, GameConfig) :-
    configure_game(Option, GameConfig), % Unification with a valid game_config into GameConfig from Option read
    process_game_config(GameConfig). % Go to processing

% Handle the case where the option is invalid
configure_game_option(_, _) :-
    write('Invalid option, please try again.'), nl,
    read_configuration(_). % Recursive call to read configuration until we get a valid option

% Process the game configuration based on its type
process_game_config(quit) :-
    write('Goodbye, Thanks for playing Aqua Pipe!'), nl,
    halt.

% When we have a valid case of a game configuration, print out the starting player
process_game_config(game_config(_, _, StartingPlayer)) :-
    format("The starting player is: ~w~n", [StartingPlayer]).

% game_cycle(+GameState)
% Main predicate to initiate the game cycle
game_cycle(GameState) :-
    check_game_over(GameState, Outcome), % Always check for game over every turn
    handle_outcome(Outcome, GameState). % Based on the outcome of the check, handle game

% check_game_over(+GameState, -Outcome)
% Predicate to check if the game is over and determine the outcome
check_game_over(GameState, outcome(over, Winner)) :-
    game_over(GameState, Winner), !.
check_game_over(_, outcome(ongoing, _)).

% handle_outcome(+Outcome, -GameState)
% Predicate to handle the outcome of the game
handle_outcome(outcome(over, Winner), GameState) :-
    display_game(GameState),
    format("Game over! The winner is: ~w~n", [Winner]),
    play.
handle_outcome(outcome(ongoing, _), GameState) :-
    display_game(GameState),
    valid_moves(GameState, Moves),
    display_moves(Moves),
    choose_move(GameState, Moves, ChosenMove),
    move(GameState, ChosenMove, NewGameState), !,
    write('Move executed successfully.'), nl,
    game_cycle(NewGameState).

% current_player(+GameState, -CurrentPlayer)
% Extract the current player from the game state
current_player(state(_, _, CurrentPlayer, _), CurrentPlayer).

% player_type(+GameState, +CurrentPlayer, -PlayerType)
% Get the player type based on whose turn it is
player_type(state(_, game_config(P1Type, _, _), _, _), player1, P1Type).
player_type(state(_, game_config(_, P2Type, _), _, _), player2, P2Type).

% next_player(+CurrentPlayer, -NextPlayer) 
% This is a flip that cycles through player 1 and player 2
next_player(player1, player2).
next_player(player2, player1).

% choose_move(+GameState, +Moves, -ChosenMove)
% Choose move based on player type
choose_move(GameState, Moves, ChosenMove) :-
    current_player(GameState, CurrentPlayer), % Get the current player
    player_type(GameState, CurrentPlayer, PlayerType), % Get the player type
    choose_move(GameState, Moves, PlayerType, ChosenMove). % Based on those two variables, get the chosen move
