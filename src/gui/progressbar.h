#ifndef PROGRESSBAR_H
#define PROGRESSBAR_H

#include <stdint.h>

/**
 * Initialize the progress bar.
 * @param x      Left pixel coordinate
 * @param y      Top pixel coordinate
 * @param width  Total width in pixels
 * @param height Total height in pixels
 * @param bg     Background color (unfilled portion)
 * @param fg     Foreground color (filled portion)
 */
void progressbar_init(int x, int y, int width, int height,
                      uint32_t bg, uint32_t fg);

/**
 * Update the progress bar fill.
 * @param percent 0–100
 */
void progressbar_update(int percent);

#endif // PROGRESSBAR_H
