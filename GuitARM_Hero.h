/// @file GuitARM_Hero.h
/// Header file for main program and game logic
///----------------------------------------------------------------------------
#ifndef GUITARM_HERO_H
#define GUITARM_HERO_H

///             Includes
#include <stdbool.h>
#include <stdint.h>

#include "Song.h"

///----------------------------------------------------------------------------
/// @addtogroup Defines
/// @{

#define BUTTON_BLUE_FLAG   1
#define BUTTON_RED_FLAG    2
#define BUTTON_YELLOW_FLAG 4

/// @}
///----------------------------------------------------------------------------
/// @addtogroup Typedefs
/// @{
//Game
typedef uint8_t lives_t;
typedef uint16_t score_t;
typedef uint8_t level_t;

/// @}
///----------------------------------------------------------------------------
/// @addtogroup Enums
/// @{

/// @}
///----------------------------------------------------------------------------
/// @addtogroup Structs
/// @{

///Data structure containing all necessary info for a player
struct PlayerGameData{
	///Amount of lives player has
	lives_t lives;
	///Player score
	score_t score;
};

///Data structure containing all of the necessary information to contain the
/// state of an active game.
///If modified, #startGame() must be modified to handle the changes.
typedef struct GameState_s{
	///Game-only data for player
	struct PlayerGameData player;
	SongData song;
	int songTime;
} GameState;

///Data structure representing a union of every data structure of every
/// independent state.
/// Used to save memory.
typedef union StateUnion_s{
	GameState game;
} StateUnion;

///Data structure for on-chip inputs that are used in this program.
typedef struct Inputs_s{
	/// The current state of the slider.
	int8_t slider;
	/// The current state of the buttons
	int8_t buttons;
} Inputs;

///Data structure for variables that are common to at least most states.
typedef struct SharedData_s{
} SharedData;

/// @}
///----------------------------------------------------------------------------
/// @addtogroup Variables
/// @{

/// The current mode of operation (Do not update directly)
/// @see updateOpState
extern opmode_t opMode;

/// Contains the data for the current state.
/// @see StateUnion
extern StateUnion state;

/// Contains the current state of the inputs.
/// @see Inputs
extern Inputs inputs;

/// Contains data common to at least most states.
/// @see SharedData
extern SharedData data;

/// @}
///----------------------------------------------------------------------------
/// @addtogroup Functions
/// @{

///@brief Updates the current operating state. 
void updateOpState(opmode_t);

///Generates a pseudo-random number
///@return a pseudo-random number
//int rand(void);

/// @}
#endif
