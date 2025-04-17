#ifndef FONT_H
#define FONT_H

#include <stdint.h>

/**
 * 8×8 monochrome bitmap font for ASCII 0–127.
 * You can obtain the full font8x8_basic array from:
 *   https://github.com/dhepper/font8x8/blob/master/font8x8_basic.h
 */
extern const uint8_t font8x8_basic[128][8];

/**
 * Draw a single character at (x,y) in pixels.
 * - c: ASCII code (0–127)
 * - fg: foreground color (32‑bit ARGB)
 * - bg: background color
 */
void draw_char(int x, int y, char c, uint32_t fg, uint32_t bg);

/**
 * Draw a null‑terminated string starting at (x,y).
 * Each glyph is 8×8 pixels, no kerning.
 */
void draw_text(int x, int y, const char *str, uint32_t fg, uint32_t bg);

#endif // FONT_H
