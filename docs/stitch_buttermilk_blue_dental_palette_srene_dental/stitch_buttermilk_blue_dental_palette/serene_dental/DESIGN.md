---
name: Serene Dental
colors:
  surface: '#faf9f7'
  surface-dim: '#dadad8'
  surface-bright: '#faf9f7'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f4f3f1'
  surface-container: '#efeeec'
  surface-container-high: '#e9e8e6'
  surface-container-highest: '#e3e2e0'
  on-surface: '#1a1c1b'
  on-surface-variant: '#424842'
  inverse-surface: '#2f3130'
  inverse-on-surface: '#f1f1ef'
  outline: '#737972'
  outline-variant: '#c2c8c0'
  surface-tint: '#4a654e'
  primary: '#4a654e'
  on-primary: '#ffffff'
  primary-container: '#8ba88e'
  on-primary-container: '#233d29'
  inverse-primary: '#b0ceb2'
  secondary: '#625e57'
  on-secondary: '#ffffff'
  secondary-container: '#e6ded6'
  on-secondary-container: '#67625b'
  tertiary: '#52606d'
  on-tertiary: '#ffffff'
  tertiary-container: '#94a2b1'
  on-tertiary-container: '#2b3945'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#cceace'
  primary-fixed-dim: '#b0ceb2'
  on-primary-fixed: '#07200f'
  on-primary-fixed-variant: '#334d38'
  secondary-fixed: '#e9e1d9'
  secondary-fixed-dim: '#ccc5be'
  on-secondary-fixed: '#1e1b16'
  on-secondary-fixed-variant: '#4a4640'
  tertiary-fixed: '#d5e4f4'
  tertiary-fixed-dim: '#b9c8d8'
  on-tertiary-fixed: '#0f1d28'
  on-tertiary-fixed-variant: '#3a4855'
  background: '#faf9f7'
  on-background: '#1a1c1b'
  surface-variant: '#e3e2e0'
typography:
  headline-xl:
    fontFamily: Noto Serif
    fontSize: 48px
    fontWeight: '400'
    lineHeight: '1.2'
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Noto Serif
    fontSize: 32px
    fontWeight: '400'
    lineHeight: '1.3'
  headline-md:
    fontFamily: Noto Serif
    fontSize: 24px
    fontWeight: '500'
    lineHeight: '1.4'
  body-lg:
    fontFamily: Manrope
    fontSize: 18px
    fontWeight: '400'
    lineHeight: '1.6'
  body-md:
    fontFamily: Manrope
    fontSize: 16px
    fontWeight: '400'
    lineHeight: '1.6'
  label-md:
    fontFamily: Manrope
    fontSize: 14px
    fontWeight: '600'
    lineHeight: '1.2'
    letterSpacing: 0.05em
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  unit: 8px
  container-max: 1200px
  gutter: 24px
  margin-page: 40px
  section-padding: 80px
---

## Brand & Style

The brand personality of the design system is centered on restorative care and psychological comfort. It aims to dissolve the traditional "clinical anxiety" associated with dentistry by adopting the visual language of a high-end wellness spa. The target audience includes individuals seeking a premium, thoughtful healthcare experience where tranquility is as prioritized as technical excellence.

The design style is **Minimalism** infused with **Organic Modernism**. This approach relies on heavy whitespace to provide "room to breathe," a muted color palette to lower sensory input, and soft tactile elements that feel approachable rather than sterile. The emotional response is one of immediate decompression, safety, and professional reliability.

## Colors

The color palette deliberately avoids the traditional high-contrast "medical blue" in favor of an earth-toned, muted spectrum. 

- **Primary (Sage Green):** Used for key actions and health-related highlights. It evokes growth and natural healing.
- **Secondary (Warm Stone):** A grounding neutral used for secondary buttons, borders, and subtle backgrounds to add warmth to the interface.
- **Tertiary (Deep Slate):** A softer alternative to black, used for typography and icons to maintain high legibility without visual harshness.
- **Background (Soft Cream):** The base `neutral_color` is a warm off-white, reducing the eye strain caused by pure white backgrounds.

## Typography

This design system utilizes a sophisticated typographic pairing to balance tradition with modernity. 

**Noto Serif** is used for headlines to convey authority, timelessness, and elegance. It suggests a high level of craftsmanship and care.

**Manrope** is used for body copy and UI labels. Its clean, geometric construction and open counters ensure exceptional legibility, even at smaller sizes, while maintaining a calm and contemporary professional tone. 

Use generous line heights (1.6x for body text) to ensure blocks of information do not feel overwhelming or "crowded."

## Layout & Spacing

The layout philosophy follows a **Fixed Grid** model for desktop and a fluid model for mobile devices. The rhythm is dictated by a generous 8px base unit. 

To achieve the "wellness spa" feel, the design system mandates significant vertical breathing room between sections (80px or more). Content should never feel cramped; if a component feels tight, increase the internal padding rather than decreasing the font size. Align elements to a 12-column grid to maintain structural integrity amidst the openness.

## Elevation & Depth

Hierarchy is established through **Ambient Shadows** and **Tonal Layers** rather than heavy lines. 

- **Shadows:** Use extremely soft, multi-layered shadows with a low opacity (4-8%) and a subtle tint of the Deep Slate color. This makes cards and modals appear to float gently above the surface.
- **Surface Tiers:** Use the Warm Stone and Soft Cream colors to create subtle depth. For example, a Stone-colored section might sit behind a Sage-colored card to create a clear but soft visual separation.
- **Glassmorphism:** Use subtle backdrop blurs (10px - 15px) for navigation bars to maintain a sense of environmental continuity as the user scrolls.

## Shapes

The design system uses a consistent **ROUND_TWELVE** (0.5rem / 8px) corner radius for standard elements like buttons and input fields. For larger containers and cards, the radius increases to `rounded-lg` (1rem / 16px) or `rounded-xl` (1.5rem / 24px).

These soft, rounded corners are essential to the "less stress" narrative, as they eliminate the perceived "sharpness" of clinical environments and evoke a more organic, human-centric feel.

## Components

### Buttons
- **Primary:** Solid Sage Green with white or Deep Slate text. High internal padding (16px 32px) to feel substantial.
- **Secondary:** Warm Stone ghost buttons with a 1px border or subtle stone fill.
- **Tertiary:** Text-only with a subtle underline effect on hover, using Deep Slate.

### Input Fields
Soft Cream backgrounds with a 1px border in Warm Stone. On focus, the border transitions to Sage Green with a subtle outer glow. Labels should always be visible above the field in Manrope SemiBold.

### Cards
Use the `rounded-lg` (16px) radius. Cards should have a white background and an ambient shadow. Internal padding should be at least 32px to ensure the content within feels serene.

### Lists & Chips
- **Chips:** Used for medical tags or appointment types. Pill-shaped with low-opacity Sage Green backgrounds.
- **Lists:** Use generous 16px spacing between list items, with icons rendered in a soft Sage Green.

### Specialty Components
- **Appointment Scheduler:** A clean, high-whitespace calendar using the Warm Stone palette for dates and Sage Green for selected slots.
- **Progress Steppers:** Soft, rounded indicators that guide the patient through medical forms without feeling clinical or intimidating.