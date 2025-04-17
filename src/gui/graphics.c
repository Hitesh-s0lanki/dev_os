#include "graphics.h"
#include "../video/vbe.h"   // for VBE_FRAMEBUFFER, VBE_WIDTH, VBE_HEIGHT, VBE_PITCH

static volatile uint8_t *framebuffer;
static int screen_width;
static int screen_height;
static int pitch;      // bytes per scanline
static int bpp_bytes;  // bytes per pixel

void graphics_init(void) {
    framebuffer   = (volatile uint8_t*)VBE_FRAMEBUFFER;
    screen_width  = VBE_WIDTH;
    screen_height = VBE_HEIGHT;
    pitch         = VBE_PITCH;
    bpp_bytes     = VBE_BPP / 8;
}

/**
 * Compute the address of pixel (x,y) in the linear framebuffer.
 */
static inline volatile uint8_t* pixel_addr(int x, int y) {
    return framebuffer + y * pitch + x * bpp_bytes;
}

void draw_pixel(int x, int y, uint32_t color) {
    if (x < 0 || x >= screen_width || y < 0 || y >= screen_height)
        return;
    volatile uint8_t *p = pixel_addr(x, y);
    // Write in little‑endian order: B G R A
    p[0] = (uint8_t)(color      ); // blue
    p[1] = (uint8_t)(color >>  8); // green
    p[2] = (uint8_t)(color >> 16); // red
    p[3] = (uint8_t)(color >> 24); // alpha
}

void draw_rect(int x, int y, int w, int h, uint32_t color) {
    for (int yy = y; yy < y + h; yy++) {
        for (int xx = x; xx < x + w; xx++) {
            draw_pixel(xx, yy, color);
        }
    }
}

void clear_screen(uint32_t color) {
    for (int yy = 0; yy < screen_height; yy++) {
        for (int xx = 0; xx < screen_width; xx++) {
            draw_pixel(xx, yy, color);
        }
    }
}
