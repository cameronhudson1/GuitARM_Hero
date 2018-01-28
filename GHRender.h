/// @file GHRender.h
/// Contains declarations for rendering functions that can be implemented
///  in different ways.
///----------------------------------------------------------------------------
#ifndef GHRENDER_H
#define GHRENDER_H

/// Includes
#include "GuitARM_Hero.h"
///----------------------------------------------------------------------------
/// @addtogroup Defines
/// @{

/// X Max of screen
#define SCREEN_WIDTH 80

/// Y Max of screen
#define SCREEN_HEIGHT 40

/// @}
///----------------------------------------------------------------------------
/// @addtogroup Major Functions
/// @{
/// @brief Initializes the renderer.
void initRenderer(void);
	
void clearScreen(void);
	
void flushScreen(void);

/// @brief Draws the board 
void drawBoard(GameState *states);

/// @}
#endif 
