/// @file GuitARM_Hero.c
/// Center of all game logic. Contains main program
/// @author Koen Komeya <kxk2610@rit.edu>
//-----------------------------------------------------------------------------
/// @addtogroup Pragmas
/// @{
//Make it possible to use anonymous unions
#pragma anon_unions

/// @}
///----------------------------------------------------------------------------
///             Imports
#include <stdlib.h>
#include <string.h>

#include "MKL46Z4.h"
#include "GuitARM_Hero.h"
#include "GMRender.h"
#include "TouchDriver.h"

///----------------------------------------------------------------------------
/// @addtogroup Variables
/// @{

/// The current mode of operation.
/// @see OperationMode
opmode_t opMode;

/// The current mode's delegate for ticking
void (*mode_tick)();

/// The current mode's delegate for rendering
void (*mode_render)();

/// The current mode's delegate for any after-tick processes
void (*mode_posttick)();

/// Contains the data for the current state.
/// @see StateUnion
StateUnion state;

/// Contains the current state of the inputs.
/// @see Inputs
Inputs inputs;


/// Contains data common to at least most states.
/// @see SharedData
SharedData data;

///Seed for #rand()
int rand_seed;

//Current tick number
int cTick = 0;

/// @}
///----------------------------------------------------------------------------
/// @addtogroup Functions
/// @{
/// @addtogroup Major Functions
/// @{

/// Assembly Subroutine to enable periodic ticks
void EnableClock(void);
/// Assembly Subroutine to wait until the next timed tick.
void WaitForTick(void);

/// Does nothing; used as a dummy function.
void noop(){}
	
/// Initializes game structures
void startGame(){
	updateOpState(OM_Game);
	data.level = 0;
	//GameState *gs = &(state.game);
	data.score = 0;
	nextLevel();
}


/// Called every 1/1000'th of a second to do stuff.
void tick(){
	mode_tick();
	mode_render();
	mode_posttick();
}

void prepReadInputs(void);
/// Entry point to the game
int main(){
	srand(rand_seed);
	//Initialize variables/state.
	opMode = OM_TransitionState; //Have to do this first to ensure some routine
	                             //doesn't get called for deinitialization.
	updateOpState(OM_TransitionState);
	memset(&data, 0, sizeof(SharedData));
	//Enable Peripherals
	EnableButtonDriver();
	EnableTSI();
	prepReadInputs();
	initRenderer();
	EnableClock();
	startGame();
	//Do tick loop: Tick every 0.001s interval
	while (1){
		WaitForTick();
		tick();
	}
}

void tickGame(void);
void renderGame(void);
void postGame(void);
/// Updates the operation mode safely, updating #mode_tick and #mode_render in the process
/// @see OperationMode
void updateOpState(opmode_t newState){
	__asm("CPSID I");
	switch (opMode){ //Deinitialization Procedure
		case OM_Game:
		break;
		case OM_GameOver:
		break;
		case OM_MainMenu:
		break;
		case OM_IntroSequence:
		break;
		case OM_Credits:
		break;
	}
	opMode = newState;
	switch (opMode){ //Initialization Procedure
		case OM_TransitionState:
			mode_tick = noop;
			mode_render = noop;
			mode_posttick = noop;
		break;
		case OM_Game:
			mode_tick = tickGame;
			mode_render = renderGame;
			mode_posttick = postGame;
		break;
		case OM_GameOver:
			mode_tick = noop;
			mode_render = noop;
			mode_posttick = noop;
		break;
		case OM_MainMenu:
			mode_tick = noop;
			mode_render = noop;
			mode_posttick = noop;
		break;
		case OM_IntroSequence:
			mode_tick = noop;
			mode_render = noop;
			mode_posttick = noop;
		break;
		case OM_Credits:
			mode_tick = noop;
			mode_render = noop;
			mode_posttick = noop;
		break;
	}
	__asm("CPSIE I");
}

///@brief generate pseudo-random number
//int rand(){
//rand_seed
//}
/// @}
/// @addtogroup Minor Functions
/// @{

/// Does any end of tick preparation to quickly read inputs the next ticks,
void prepReadInputs(void){
	ScanTSI();
}

/// Reads all input sources for this game.
void readInputs(void){
	inputs.slider = ReadTSIScaled();
}

/// Ticks everything in a game session.
void tickGame(){
	readInputs();
}

/// Renders everything in a game session.
void renderGame(){
	
}

/// Does post-tick processes
void postGame(void){
	prepReadInputs();
}

/// @}

/// @addtogroup Sub-Minor Functions
/// @{

/// @}
/// @}
