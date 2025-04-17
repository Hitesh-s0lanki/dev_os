#ifndef GRAPHICS_H
#define GRAPHICS_H

#include <stdint.h>

/**
 * Initialize graphics subsystem.
 * Call after vbe_set_mode() and switching to protected mode.
 */
void graphics_init(void);

/**
 * Plot a single pixel at (x,y) in 32‑bit ARGB format.
 */
void draw_pixel(int x, int y, uint32_t color);

/**
 * Draw a filled rectangle at (x,y) of width w and height h.
 */
void draw_rect(int x, int y, int w, int h, uint32_t color);

/**
 * Clear entire screen to the given color.
 */
void clear_screen(uint32_t color);

#endif // GRAPHICS_H
