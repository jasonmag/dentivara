---
name: Clinic Design System
colors:
  surface: '#f9f9ff'
  surface-dim: '#d4daea'
  surface-bright: '#f9f9ff'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f1f3ff'
  surface-container: '#e8eeff'
  surface-container-high: '#e3e8f9'
  surface-container-highest: '#dde2f3'
  on-surface: '#161c27'
  on-surface-variant: '#414750'
  inverse-surface: '#2a303d'
  inverse-on-surface: '#ecf0ff'
  outline: '#727782'
  outline-variant: '#c1c7d2'
  surface-tint: '#1960a3'
  primary: '#005394'
  on-primary: '#ffffff'
  primary-container: '#2b6cb0'
  on-primary-container: '#e1ecff'
  inverse-primary: '#a2c9ff'
  secondary: '#615e57'
  on-secondary: '#ffffff'
  secondary-container: '#e7e2d9'
  on-secondary-container: '#67645d'
  tertiary: '#245483'
  on-tertiary: '#ffffff'
  tertiary-container: '#406d9d'
  on-tertiary-container: '#e1ecff'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#d3e4ff'
  primary-fixed-dim: '#a2c9ff'
  on-primary-fixed: '#001c38'
  on-primary-fixed-variant: '#004881'
  secondary-fixed: '#e7e2d9'
  secondary-fixed-dim: '#cbc6bd'
  on-secondary-fixed: '#1d1b16'
  on-secondary-fixed-variant: '#494640'
  tertiary-fixed: '#d1e4ff'
  tertiary-fixed-dim: '#9ecaff'
  on-tertiary-fixed: '#001d36'
  on-tertiary-fixed-variant: '#154976'
  background: '#f9f9ff'
  on-background: '#161c27'
  surface-variant: '#dde2f3'
typography:
  display-xl:
    fontFamily: Manrope
    fontSize: 48px
    fontWeight: '800'
    lineHeight: '1.2'
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Manrope
    fontSize: 32px
    fontWeight: '700'
    lineHeight: '1.3'
  headline-md:
    fontFamily: Manrope
    fontSize: 24px
    fontWeight: '600'
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
  label-sm:
    fontFamily: Manrope
    fontSize: 14px
    fontWeight: '600'
    lineHeight: '1.2'
    letterSpacing: 0.01em
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  unit: 8px
  container-max: 1280px
  gutter: 24px
  margin-mobile: 16px
  margin-desktop: 40px
  stack-sm: 8px
  stack-md: 16px
  stack-lg: 32px
---

## Brand & Style

The brand personality of this design system is rooted in **empathy, precision, and tranquility**. It moves away from the cold, sterile visuals often associated with clinical environments, opting instead for a "Warm Professionalism." The goal is to reduce patient anxiety through a soft, inviting interface while maintaining a high level of authority and medical competence.

The design style follows a **Modern / Minimalist** approach. It utilizes expansive whitespace, intentional layering, and a restrained color palette to ensure the user journey—whether booking an appointment or reviewing dental records—is frictionless and calm. The visual language conveys trust through clarity and accessibility, ensuring that information is easily digestible for users of all ages.

## Colors

The palette is anchored by a dual-tone strategy:
- **Buttermilk (#FFF9F0):** Used as the primary canvas. This creamy off-white provides a warmer, more organic feel than pure white, reducing screen glare and creating a soothing environment.
- **Mid-Blue (#2B6CB0):** The primary action color. This specific shade of blue is chosen for its association with health and cleanliness, providing a clear visual signal for interaction.
- **Deep Navy (#003E6B):** Reserved for high-contrast typography and iconography to ensure AAA accessibility.
- **Functional Greys:** Used for subtle borders and secondary text, ensuring the hierarchy remains clear without overwhelming the warm background.

Use the Buttermilk color for all large surface areas (Body Background, Card Surfaces) and the Mid-Blue for critical path elements like Primary Buttons, Links, and Active States.

## Typography

**Manrope** has been selected as the sole typeface for this design system due to its modern, geometric construction and exceptional legibility in health-related contexts. Its balanced proportions provide a sense of stability and technical excellence.

Headlines should utilize the bolder weights (700-800) with slightly tighter letter spacing to create a strong visual anchor. Body text should maintain a generous line height (1.6) to ensure readability for patients who may be browsing on mobile devices or in stressful situations. For administrative or data-heavy labels, use the semi-bold weight at smaller sizes to maintain clarity without sacrificing the soft aesthetic.

## Layout & Spacing

This design system employs a **fixed grid model** for desktop environments to maintain a premium, editorial feel, transitioning to a fluid layout for mobile devices. 

The spacing logic is built on an **8px base unit**, creating a predictable rhythmic flow between elements. 
- Use **large margins** (40px+) on the edges of the screen to prevent the content from feeling "cramped," reinforcing the sense of calm.
- **Sectional Spacing:** Use 80px to 120px of vertical padding between major homepage sections to let the buttermilk background act as a visual breather.
- **Grouping:** Use smaller increments (8px, 16px) for related elements like form labels and inputs.

## Elevation & Depth

Depth in this design system is achieved through **ambient, tinted shadows**. Rather than using harsh black shadows, we use shadows tinted with a hint of the Mid-Blue or a warm Umber to complement the Buttermilk surface.

- **Level 1 (Default Cards):** A very soft, wide-spread shadow (Y: 4px, Blur: 12px, Opacity: 4%) to give the impression that cards are slightly lifted from the background.
- **Level 2 (Hover/Active):** An increased spread and slightly higher opacity (Y: 8px, Blur: 20px, Opacity: 8%) to provide tactile feedback during interaction.
- **Flat Borders:** For interactive elements like input fields, use a 1px solid border in a muted blue-grey instead of shadows to maintain a clean, professional look.

## Shapes

The shape language is defined by **Rounded (0.5rem base)** geometry. This moderate radius strikes a balance between the friendliness of organic shapes and the structure of professional medical software.

- **Standard Buttons & Inputs:** 0.5rem (8px) radius.
- **Cards & Containers:** 1rem (16px) radius to emphasize the "soft container" feel.
- **Icons:** Should be housed in circular containers or follow a "soft-corner" illustrative style to match the UI.

## Components

### Buttons
- **Primary:** Solid Mid-Blue background with white text. High contrast is essential.
- **Secondary:** Transparent background with a Mid-Blue border and text.
- **States:** Hover states should involve a subtle darkening of the blue, rather than a color shift, to maintain brand consistency.

### Cards
- Cards should use a white surface (#FFFFFF) to pop against the Buttermilk (#FFF9F0) background. 
- Apply the Level 1 Elevation (subtle shadow) to define the boundaries without needing heavy borders.

### Input Fields
- Inputs feature a light grey border that transitions to Mid-Blue on focus. 
- Labels must always be visible (not just placeholder text) to ensure accessibility for elderly patients.

### Chips & Badges
- Used for dental services (e.g., "Cleaning," "Orthodontics"). These should use a very light tint of the primary blue with deep blue text for high legibility.

### Specialized Components
- **Appointment Picker:** A clean, grid-based calendar using the 8px spacing rhythm, highlighting available slots in Mid-Blue.
- **Testimonial Blocks:** Large-format typography on Buttermilk backgrounds with soft-rounded profile imagery.