# Figma foundation

The shared UI foundation is based on the My Garden Figma file supplied by the project owner:

- https://www.figma.com/design/i3Jq3mO3o724r7J8JjkKLv/My-Garden

The Flutter implementation starts from the shared theme in `mobile/lib/core/theme/app_theme.dart`. All feature screens should reuse the theme, Material 3 components, shared spacing, and the cream/green visual language instead of introducing module-specific colors. When exact Figma exports are available, update this file and the theme tokens together so design decisions remain discoverable in the repository.
