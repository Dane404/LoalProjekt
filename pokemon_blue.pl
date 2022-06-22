
/*-------------------------------------------------------------------------------*/
/* <Pokemon>, by <Danijel Pejic, Florian Ster, Christoph Moosbrugger>. */
:- dynamic i_am_at/1, at/2, holding/1, has_pokemon/0, available_pokemon/1, dead_pokemon/1.
:- retractall(at(_, _)), retractall(i_am_at(_)), retractall(alive(_)).

i_am_at(my_room).




/* Pokemon*/
is_pokemon(charmander).
is_pokemon(charmeleon).
is_pokemon(charizard).

is_pokemon(squirtle).
is_pokemon(wartortle).
is_pokemon(blastoise).

is_pokemon(bulbasaur).
is_pokemon(ivysaur).
is_pokemon(venusaur).

directly_evolves(charmander,charmeleon).
directly_evolves(charmeleon,charizard).
directly_evolves(squirtle,wartortle).
directly_evolves(wartortle,blastoise).
directly_evolves(bulbasaur,ivysaur).
directly_evolves(ivysaur,venusaur).

evolves(PokemonX,PokemonY):- directly_evolves(PokemonX,PokemonY).
evolves(PokemonX,PokemonZ) :- directly_evolves(PokemonX,PokemonY),evolves(PokemonY,PokemonZ).

evolve(Pokemon) :- (directly_evolves(Pokemon,X),write(Pokemon),write(' evolves to '),write( X),retract(available_pokemon(Pokemon)),assert(available_pokemon(X)),!)
;(write(Pokemon),write(' has no evolution')).



has_type(charmander,fire).
has_type(charmeleon,fire).
has_type(charizard,fire).

has_type(squirtle,water).
has_type(wartortle,water).
has_type(blastoise,water).

has_type(bulbasaur,plant).
has_type(ivysaur,plant).
has_type(venusaur,plant).



/*Inside house*/
path(my_room,d,downstairs).
path(downstairs,u,my_room).

path(downstairs,s,frontyard).
path(frontyard,n,downstairs).

/*Outside*/

path(frontyard,e,crossing).
path(crossing,w,frontyard).

path(fighting_area,s,crossing).
path(crossing,n,fighting_area).

path(tall_grass,w,fighting_area).
path(fighting_area,e,tall_grass).

path(arena,e,fighting_area).
path(fighting_area,w,arena).

path(pokecenter,n,crossing).
path(crossing,s,pokecenter).

path(oaks_lab,w,crossing).
path(crossing,e,oaks_lab).


/*Battle */
beats_type(fire,plant).
beats_type(water,fire).
beats_type(plant,water).

beats(PokemonX,PokemonY) :-(evolves(PokemonY,PokemonX),!);(not(evolves(PokemonX,PokemonY)),( has_type(PokemonX,TypeX),has_type(PokemonY,TypeY),beats_type(TypeX,TypeY)),!).

start_battle(EnemyPokemon):- (available_pokemon(X),battle_pokemon(X,EnemyPokemon));die.

battle_pokemon(PokemonX,PokemonY):-(write_pokebattle_intro(PokemonX,PokemonY),beats(PokemonX,PokemonY),write(PokemonX),write(' won the battle and tries to evolve!'),nl,evolve(PokemonX),!)
;(write(PokemonX),write(' died!'),nl,kill_pokemon(PokemonX),false).

write_pokebattle_intro(PokemonX,PokemonY):-write(PokemonX),write(' battles '), write(PokemonY),nl.




/* Pokemon managment*/

get_pokemon(Pokemon):- add_pokemon(Pokemon),retractall(has_pokemon),assert(has_pokemon),!.

add_pokemon(Pokemon):- available_pokemon(Pokemon);(assert(available_pokemon(Pokemon)),nl,write('You cought a '),write(Pokemon)),nl.

kill_pokemon(Pokemon):-retract(available_pokemon(Pokemon)),assert(dead_pokemon(Pokemon)) .

restore_pokemon :- dead_pokemon(X),write_restore_message(X),retract(dead_pokemon(X)), assert(available_pokemon(X)),(restore_pokemon;true),!.


write_restore_message(Pokemon) :- write(Pokemon), write(' is being restored!'),nl.

/* These rules define the direction letters as calls to go/1. */

n :- go(n).

s :- go(s).

e :- go(e).

w :- go(w).

u :- go(u).

d :- go(d).


/* This rule tells how to move in a given direction. */


go(Direction) :-
        i_am_at(crossing),
        path(crossing, Direction, tall_grass),
        has_pokemon,
        retract(i_am_at(_)),
        assert(i_am_at(_)),
        !, look;
        i_am_at(crossing),
        path(crossing, Direction, fighting_area),((not(has_pokemon),
        write('OAK: Hey! Wait! Dont go out! Its unsafe!'),nl,
        write('Wild Pokémon live in tall grass! You need your own Pokémon for your protection.'),nl,
        write('I know! Here, come with me!'),nl,!,
        retract(i_am_at(_)),
        assert(i_am_at(oaks_lab)),look);
        (
         retract(i_am_at(_)),
         assert(i_am_at(fighting_area)),
         nl,look,!)).

go(Direction) :-
        i_am_at(Here),
        path(Here, Direction, There),
        retract(i_am_at(Here)),
        assert(i_am_at(There)),
        !, look.


go(_) :-
        write('You can''t go that way.').


/* This rule tells how to look about you. */

look :-
        i_am_at(Place),
        describe(Place),
        nl.




/* This rule tells how to die. */

die :-
        nl,
        write('Your pokemons died'),nl,
        retract(i_am_at(_)),
        assert(i_am_at(pokecenter)),
        look.


/* Under UNIX, the "halt." command quits Prolog but does not
   remove the output window. On a PC, however, the window
   disappears before the final output can be seen. Hence this
   routine requests the user to perform the final "halt." */

finish :-
        nl,
        write('The game is over. Please enter the "halt." command.'),
        nl.


/* This rule just writes out game instructions. */

instructions :-
        nl,
        write('Enter commands using standard Prolog syntax.'), nl,
        write('Available commands are:'), nl,
        write('start.             -- to start the game.'), nl,
        write('n.  s.  e.  w.     -- to go in that direction.'), nl,
        write('u. d.              -- up and down'),nl,
        write('instructions.      -- to see this message again.'), nl,
        write('map.      -- to see the map.'), nl,
        write('halt.              -- to end the game and quit.'), nl,
        nl.


/* This rule prints out instructions and tells where you are. */

start :-
        instructions,
        look.

map :-
        nl,
        write('o o o o o o o o o o o o o o o o o o o o o o o o o o o o o o o o o o o o o o'),nl,
        write('o +------------+                                                          o'),nl,
        write('o |            |                                                          o'),nl,
        write('o |  upstairs  |          +------------+ +---------------+ +------------+ o'),nl,
        write('o |            |          |            | |               | |            | o'),nl,
        write('o +-----||-----+          |    arena   === fighting area === tall grass | o'),nl,
        write('o |            |          |            | |               | |            | o'),nl,
        write('o | downstairs |          +-----||-----+ +------||-------+ +------------+ o'),nl,
        write('o |            |                                ||                        o'),nl,
        write('o +-----||-----+                          +-----||-----+ +------------+   o'),nl,
        write('o |            |                          |            | |            |   o'),nl,
        write('o | frontyard  ============================  crossing  ===  oaks lab  |   o'),nl,
        write('o |            |                          |            | |            |   o'),nl,
        write('o +------------+                          +-----||-----+ +------------+   o'),nl,
        write('o                                               ||                        o'),nl,
        write('o                                         +-----||-----+                  o'),nl,
        write('o                                         |            |                  o'),nl,
        write('o                                         | pokecemter |                  o'),nl,
        write('o                                         |            |                  o'),nl,
        write('o                                         +------------+                  o'),nl,
        write('o o o o o o o o o o o o o o o o o o o o o o o o o o o o o o o o o o o o o o'),nl,
        nl.

/* These rules describe the various rooms.  Depending on
   circumstances, a room may have more than one description. */

describe(my_room) :-
        write('You are at home'),nl,
        write('go downstairs - d.'),nl,!.

describe(downstairs) :-
        write('You are downstairs'),nl,
        write('Go to frontyard - s.'),nl,
        write('Go upstairs(your room) - u.'),nl,!.

describe(frontyard) :-
        write('You are in the frontyard'),nl,
        write('Go back inside(downstairs) - n'),nl,
        write('Go to the crossing - e.'),nl,!.

describe(crossing) :-
        write('You are at the crossing.'), nl,
        write('There are many paths to choose'), nl,
        write('Fighting area - n.'), nl,
        write('Home - w.'), nl,
        write('Oaks lab - e.'), nl,
        write('Pokecenter - s.'), nl,!.

describe(oaks_lab) :-
        write('You are at oaks lab'),nl,
        ((not(has_pokemon),write('Which pokemon do you want?'),nl,
         write('charmander - c.'),nl,
         write('bulbasaur - b.'),nl,
         write('squirtle - sq.'),nl);true),
        write('leave oaks lab - w.'),nl,!.



describe(tall_grass) :-
        nl,write('You are at the tall grass area'),nl,
        write('Here,you might be able to find some wild pokemons'),nl,random_pokemon(X),start_battle(X),i_am_at(tall_grass),!,get_pokemon(X),nl,
        write('leave tall grass area - w.'),nl,!.

describe(arena) :-
        write('You are at the arena'),nl,
        write('Here you can combat other trainers'),nl,
        write('leave arena - e.'),nl,!.

describe(fighting_area) :-
        nl,write('You are at the fighting area'),nl,
        write('Here, you are free to choose if you want to fight wild pokemons in the tall grass area, or combat other trainers in the arena'),nl,
        write('Battle random pokemon - fight.'),nl,
        write('Go to tall grass area - e.'),nl,
        write('Go to arena -  w.'),nl,
        write('Leave fighting area (crossing) - s.'),nl,!.


describe(pokecenter) :-
        nl,write('You are at the pokecenter.'),nl,(restore_pokemon,nl,
        write('Your pokemons are restored!'),nl;true),nl,
        write('Leave Pokecenter - n.'),nl,!.



describe(_) :- write('This room is not defined yet.').


/* get pokemon in oaks lab*/
c :- get_pokemon(charmander),nl,write('You chose charmander!'),nl,look.
b :- get_pokemon(bulbasaur),nl,write('You chose bulbasaur!'),nl,look.
sq :- get_pokemon(squirtle),nl,write('You chose squirtle!'),nl,look.

battle_charmander :- start_battle(charmander).
battle_squirtle :- start_battle(squirtle).
battle_bulbasaur:- start_battle(bulbasaur).

/*utilities*/
pokemons(L) :- findall(X,is_pokemon(X),L).
random_pokemon(X) :- pokemons(L),random_member(X,L),!.

fight :-  random_pokemon(X),start_battle(X),(i_am_at(fighting_area),look;true),!.
