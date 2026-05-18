---
name: Lumina Creative
colors:
  surface: '#0b1326'
  surface-dim: '#0b1326'
  surface-bright: '#31394d'
  surface-container-lowest: '#060e20'
  surface-container-low: '#131b2e'
  surface-container: '#171f33'
  surface-container-high: '#222a3d'
  surface-container-highest: '#2d3449'
  on-surface: '#dae2fd'
  on-surface-variant: '#c2c6d6'
  inverse-surface: '#dae2fd'
  inverse-on-surface: '#283044'
  outline: '#8c909f'
  outline-variant: '#424754'
  surface-tint: '#adc6ff'
  primary: '#adc6ff'
  on-primary: '#002e6a'
  primary-container: '#4d8eff'
  on-primary-container: '#00285d'
  inverse-primary: '#005ac2'
  secondary: '#bcc7de'
  on-secondary: '#263143'
  secondary-container: '#3e495d'
  on-secondary-container: '#aeb9d0'
  tertiary: '#4edea3'
  on-tertiary: '#003824'
  tertiary-container: '#00a572'
  on-tertiary-container: '#00311f'
  error: '#ffb4ab'
  on-error: '#690005'
  error-container: '#93000a'
  on-error-container: '#ffdad6'
  primary-fixed: '#d8e2ff'
  primary-fixed-dim: '#adc6ff'
  on-primary-fixed: '#001a42'
  on-primary-fixed-variant: '#004395'
  secondary-fixed: '#d8e3fb'
  secondary-fixed-dim: '#bcc7de'
  on-secondary-fixed: '#111c2d'
  on-secondary-fixed-variant: '#3c475a'
  tertiary-fixed: '#6ffbbe'
  tertiary-fixed-dim: '#4edea3'
  on-tertiary-fixed: '#002113'
  on-tertiary-fixed-variant: '#005236'
  background: '#0b1326'
  on-background: '#dae2fd'
  surface-variant: '#2d3449'
typography:
  display-lg:
    fontFamily: Inter
    fontSize: 48px
    fontWeight: '700'
    lineHeight: 56px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Inter
    fontSize: 32px
    fontWeight: '600'
    lineHeight: 40px
    letterSpacing: -0.01em
  headline-lg-mobile:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
  headline-md:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
  title-md:
    fontFamily: Inter
    fontSize: 18px
    fontWeight: '500'
    lineHeight: 24px
  body-lg:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  label-md:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '500'
    lineHeight: 16px
    letterSpacing: 0.01em
  label-sm:
    fontFamily: Inter
    fontSize: 11px
    fontWeight: '600'
    lineHeight: 14px
    letterSpacing: 0.03em
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  unit: 4px
  gutter: 16px
  margin-mobile: 16px
  margin-desktop: 24px
  sidebar-width: 280px
  toolbar-width: 64px
---

## Brand & Style

The design system is engineered for a high-performance photo utility that balances creative expression with professional-grade efficiency. The brand personality is **Technical, Precise, and Enabling**, positioning the tool as an extension of the user’s creative intent rather than an obstacle.

The visual style is **Modern Professional with Glassmorphic accents**. It utilizes a deep dark-mode foundation to make user content (photos and collages) the focal point. The interface employs subtle translucency and background blurs for non-modal overlays, creating a sense of layered depth without sacrificing the speed and clarity required of a functional utility. The aesthetic is clean and structured, drawing inspiration from high-end creative suites while maintaining a lower barrier to entry through friendly geometry.

## Colors

This design system uses a **Deep Dark** palette optimized for image editing and composition. 

- **Primary (#3B82F6):** Used for primary actions, active tool states, and selection highlights. It provides a high-contrast focal point against the dark background.
- **Secondary/Neutral Range:** A Slate-based scale. `#020617` is reserved for the main workspace/canvas, `#0F172A` for sidebars and navigation, and `#1E293B` for elevated components like cards or popovers.
- **Accent/Success (#10B981):** Reserved for "Export," "Save," and "Done" actions, as well as positive state feedback.
- **Text:** Primary text should be `#F8FAFC` (Slate 50), with secondary metadata in `#94A3B8` (Slate 400).

## Typography

The system utilizes **Inter** for its exceptional legibility in dense UI environments. The hierarchy is designed to keep the interface unobtrusive. 

**Usage Guidelines:**
- **Headlines:** Reserved for page titles and major modal headers.
- **Labels:** Use `label-sm` (uppercase) for sidebar category headers and `label-md` for tool tooltips and button labels.
- **Body:** `body-md` is the standard for property inspectors and side-panel descriptions.
- **Contrast:** Always use high-contrast white for active labels and muted slate for inactive or disabled text.

## Layout & Spacing

The layout follows a **Fixed-Sidebar Modular Grid** model. The application architecture is split into three primary zones:

1.  **The Global Navigation:** A narrow left-hand rail (64px) for high-level tool switching.
2.  **The Property Inspector:** A 280px collapsible sidebar for granular controls.
3.  **The Canvas:** A fluid, center-aligned workspace with 24px internal margins.

Spacing is based on a **4px base unit**. All component internal padding and external margins must be multiples of 4 (8px, 12px, 16px, 24px, 32px). On mobile, sidebars reflow into bottom sheets to maximize the photo viewing area.

## Elevation & Depth

Hierarchy is established through **Tonal Layering** and **Glassmorphism**, rather than heavy shadows.

- **Level 0 (Canvas):** The lowest layer, `#020617`.
- **Level 1 (Sidebars):** `#0F172A` with a 1px border (`#1E293B`) on the inner edge.
- **Level 2 (Cards/Modules):** `#1E293B` with a subtle 4px blur shadow.
- **Overlays (Dialogs/Tooltips):** These utilize a **Glassmorphic** effect. Surfaces use a semi-transparent Slate (`rgba(30, 41, 59, 0.7)`) with a 12px backdrop-filter blur and a 1px semi-transparent white top-border to simulate a highlight.

## Shapes

The design system adopts a **Rounded** profile to soften the technical nature of the application. 

- **Standard (8px):** Used for small input fields and tool buttons.
- **Default (12px):** Applied to primary buttons, collage thumbnails, and cards.
- **Large (24px):** Used for main modal containers and large image previews.
- **Full (Pill):** Reserved for status badges and toggle switches.

## Components

### Buttons
- **Primary:** Solid `#3B82F6` with white text. 12px corner radius. High-emphasis actions.
- **Secondary:** Ghost style with a 1px border of `#334155`. Background becomes `#1E293B` on hover.
- **Action (Ghost):** Square 40x40px buttons for toolbar icons with no border; background appears only on hover.

### Input Fields
- Dark backgrounds (`#020617`) with a 1px border (`#334155`). Focus state transitions the border to Primary Blue and adds a subtle outer glow.

### Cards & Thumbnails
- Used for collage templates and photo library items. Always feature a 12px radius. Active selections are marked by a 2px Primary Blue border.

### Chips & Sliders
- **Sliders:** Primary Blue tracks with white circular handles for photo adjustments (brightness, contrast).
- **Chips:** Used for "Tags" or "Filters." Low-contrast Slate background with `label-md` typography.

### Additional Components
- **Collage Grid Rail:** A dedicated scrollable area for dragging and dropping templates.
- **Export Progress Bar:** A thin 4px bar using the Emerald Accent color to indicate completion.