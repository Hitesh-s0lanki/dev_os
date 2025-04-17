#include "screen.h"
#include "graphics.h"
#include "font.h"
#include "progressbar.h"
#include "../video/vbe.h"   // for VBE_WIDTH, VBE_HEIGHT

static int g_bar_x, g_bar_y;
static int g_bar_width, g_bar_height;
static uint32_t g_bg, g_fg;

/**
 * Centered text uses 8×8 font.
 */
static int text_pixel_width(const char *msg) {
    int len = 0;
    while (msg[len]) ++len;
    return len * 8;
}

void loading_screen_init(const char *msg,
                         uint32_t bg_color,
                         uint32_t fg_color,
                         int bar_width,
                         int bar_height)
{
    g_bg = bg_color;
    g_fg = fg_color;
    g_bar_width  = bar_width;
    g_bar_height = bar_height;

    // 1) Clear screen
    clear_screen(g_bg);

    // 2) Compute text position
    int text_w = text_pixel_width(msg);
    int x_text = (VBE_WIDTH  - text_w) / 2;
    int y_text = (VBE_HEIGHT / 2) - bar_height - 16;  // 16px spacing above bar

    // 3) Draw the message
    draw_text(x_text, y_text, msg, g_fg, g_bg);

    // 4) Initialize progress bar just below the text
    g_bar_x = (VBE_WIDTH  - bar_width) / 2;
    g_bar_y = y_text + 16 + 8;  // text height (8px) + spacing (8px)
    progressbar_init(g_bar_x, g_bar_y, bar_width, bar_height, 0xFF555555, g_fg);
}

void loading_screen_update(int pct) {
    progressbar_update(pct);
}

void loading_screen_finish(void) {
    // For now, just clear screen to black (or bg) before switching context
    clear_screen(g_bg);
    // If you want to return to text mode, you could call a bios text-mode stub here.
}
