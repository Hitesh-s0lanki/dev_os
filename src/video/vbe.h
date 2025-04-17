#ifndef VBE_H
#define VBE_H

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

/**
 * Set the graphics mode to 1024×768×32bpp with a linear framebuffer.
 * Must be called in real-mode (or V86) before switching to protected mode.
 */
void vbe_set_mode(void);

/**
 * Framebuffer physical base address.
 * If you parse the ModeInfoBlock, you can replace this hard‑coded pointer
 * with the real one from the VBE info (offset 0x28).
 */
#define VBE_FRAMEBUFFER ((uint32_t*)0xE0000000)

/** Screen width in pixels. */
#define VBE_WIDTH  1024
/** Screen height in pixels. */
#define VBE_HEIGHT 768
/** Bits per pixel. */
#define VBE_BPP    32
/** Pitch (bytes per scanline). */
#define VBE_PITCH  (VBE_WIDTH * (VBE_BPP / 8))

#ifdef __cplusplus
}
#endif

#endif // VBE_H
