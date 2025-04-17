#include "progressbar.h"
#include "graphics.h"

// Stored parameters
static int pb_x, pb_y, pb_w, pb_h;
static uint32_t pb_bg, pb_fg;

void progressbar_init(int x, int y, int width, int height,
                      uint32_t bg, uint32_t fg)
{
    pb_x = x;
    pb_y = y;
    pb_w = width;
    pb_h = height;
    pb_bg = bg;
    pb_fg = fg;

    // Draw the empty bar
    draw_rect(pb_x, pb_y, pb_w, pb_h, pb_bg);
}

void progressbar_update(int percent)
{
    if (percent < 0) percent = 0;
    if (percent > 100) percent = 100;

    // Compute filled width
    int fill_w = (pb_w * percent) / 100;

    // Redraw background first (optional if init did it once)
    draw_rect(pb_x, pb_y, pb_w, pb_h, pb_bg);

    // Draw filled portion
    if (fill_w > 0)
        draw_rect(pb_x, pb_y, fill_w, pb_h, pb_fg);
}
