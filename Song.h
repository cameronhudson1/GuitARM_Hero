/// @file Song.h
/// Header file which gives the basic Song data types
///----------------------------------------------------------------------------
#ifndef SONG_H
#define SONG_H
///----------------------------------------------------------------------------
/// @addtogroup Typedefs
/// @{

/// Represents time measured by samples.
typedef uint16_t samptime_t;

/// Represents an audio instruction
typedef uint16_t audioop_t;
/// Represents a GuitARM Hero note
typedef uint8_t noteop_t;
/// Represents the start to a list audio instructions that make up a song
typedef audioop_t *songaudio_t; 
/// Represents the start to a list game instructions that make up a song 
typedef noteop_t *songnotes_t;


/// @}
///----------------------------------------------------------------------------
/// @addtogroup Structs
/// @{


///Data structure for song.
typedef struct SongData_s{
	songaudio_t audio;
	songnotes_t notes;
        samptime_t length;
} SongData;


/// @}