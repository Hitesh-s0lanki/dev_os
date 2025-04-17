#ifndef SCREEN_H
#define SCREEN_H

#include <stdint.h>

/**
 * Initialize and show a centered loading screen:
 *  - Sets background color
 *  - Draws centered text
 *  - Draws an empty progress bar below the text
 *
 * @param msg         The null‑terminated message to display (e.g. "Loading…")
 * @param bg_color    Screen clear color (ARGB)
 * @param fg_color    Text color (ARGB)
 * @param bar_width   Width of progress bar in pixels
 * @param bar_height  Height of progress bar in pixels
 */
void loading_screen_init(const char *msg,
                         uint32_t bg_color,
                         uint32_t fg_color,
                         int bar_width,
                         int bar_height);

/**
 * Advance the progress bar to the given percentage.
 * @param pct  Value from 0 to 100
 */
void loading_screen_update(int pct);

/**
 * Tear down the loading screen when finished.
 * For example, clears graphics or returns to text mode.
 */
void loading_screen_finish(void);

#endif // SCREEN_H
