
/*-------------------------------------------------------------------------------*/
/* <Pokemon>, by <Danijel Pejic, Florian Ster, Christoph Moosbrugger>. */
:- dynamic i_am_at/1, at/2, holding/1, has_pokemon/0.
:- retractall(at(_, _)), retractall(i_am_at(_)), retractall(alive(_)).

i_am_at(my_room).
/* Facts about the map connections */

/*Inside house*/
path(my_room,d,downstairs).
path(downstairs,u,my_room).

path(downstairs,s,frontyard).
path(frontyard,w,downstairs).

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
/*Placement of items*/


/* These rules describe how to pick up an object. */

take(X) :-
        holding(X),
        write('You''re already holding it!'),
        !, nl.

take(X) :-
        i_am_at(Place),
        at(X, Place),
        retract(at(X, Place)),
        assert(holding(X)),
        write('OK.'),
        !, nl.

take(_) :-
        write('I don''t see it here.'),
        nl.


/* These rules describe how to put down an object. */

drop(X) :-
        holding(X),
        i_am_at(Place),
        retract(holding(X)),
        assert(at(X, Place)),
        write('OK.'),
        !, nl.

drop(_) :-
        write('You aren''t holding it!'),
        nl.


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
        path(crossing, Direction, fighting_area),
        write('No Pokemon teleport to oaks lab'),nl,
        retract(i_am_at(_)),
        assert(i_am_at(oaks_lab)),
        look.

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
        nl,
        notice_objects_at(Place),
        nl.


/* These rules set up a loop to mention all the objects
   in your vicinity. */

notice_objects_at(Place) :-
        at(X, Place),
        write('There is a '), write(X), write(' here.'), nl,
        fail.

notice_objects_at(_).


/* This rule tells how to die. */

die :-
        nl,
        write('Your pokemon died'),
        nl,
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
        write('take(Object).      -- to pick up an object.'), nl,
        write('drop(Object).      -- to put down an object.'), nl,
        write('instructions.      -- to see this message again.'), nl,
        write('halt.              -- to end the game and quit.'), nl,
        nl.


/* This rule prints out instructions and tells where you are. */

start :-
        instructions,
        look.


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
        write('Go back inside(downstairs) - w'),nl,
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
        write('leave oaks lab - w.'),nl,!.

describe(tall_grass) :-
        write('You are at the tall grass area'),nl,
        write('Here,you might be able to find some wild pokemons'),nl,
        write('leave tall grass area - w.'),nl,!.

describe(arena) :-
        write('You are at the arena'),nl,
        write('Here you can combat other trainers'),nl,
        write('leave arena - e.'),nl,!.

describe(fighting_area) :-
        write('You are at the fighting area'),nl,
        write('Here, you are free to choose if you want to fight wild pokemons in the tall grass area, or combat other trainers in the arena'),nl,
        write('Go to tall grass area - e.'),nl,
        write('Go to arena -  w.'),nl,
        write('Leave fighting area (crossing) - s.'),nl,!.


describe(pokecenter) :-
        write('You are at the pokecenter.'),nl,
        write('Leave Pokecenter - n.'),nl,!.

describe(_) :- write('This room is not defined yet.').
