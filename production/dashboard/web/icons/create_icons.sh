#!/bin/bash
# Create placeholder PNG icons for web app

# Check if ImageMagick is available
if ! command -v convert &> /dev/null; then
    echo "ImageMagick not available, creating SVG placeholder instead"
    # Create SVG that can be used as fallback
    cat > Icon-192.svg << 'SVGEOF'
<svg width="192" height="192" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <linearGradient id="grad" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" style="stop-color:#667eea;stop-opacity:1" />
      <stop offset="100%" style="stop-color:#764ba2;stop-opacity:1" />
    </linearGradient>
  </defs>
  <rect width="192" height="192" rx="40" fill="url(#grad)"/>
  <text x="96" y="120" font-family="Arial, sans-serif" font-size="100" font-weight="bold" fill="white" text-anchor="middle">F</text>
</svg>
SVGEOF
    
    cat > Icon-512.svg << 'SVGEOF'
<svg width="512" height="512" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <linearGradient id="grad" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" style="stop-color:#667eea;stop-opacity:1" />
      <stop offset="100%" style="stop-color:#764ba2;stop-opacity:1" />
    </linearGradient>
  </defs>
  <rect width="512" height="512" rx="106" fill="url(#grad)"/>
  <text x="256" y="330" font-family="Arial, sans-serif" font-size="280" font-weight="bold" fill="white" text-anchor="middle">F</text>
</svg>
SVGEOF
    
    # Try to convert SVG to PNG if available
    if command -v inkscape &> /dev/null; then
        inkscape Icon-192.svg -o Icon-192.png -w 192 -h 192 2>/dev/null || echo "Inkscape conversion failed"
        inkscape Icon-512.svg -o Icon-512.png -w 512 -h 512 2>/dev/null || echo "Inkscape conversion failed"
        cp Icon-192.png Icon-maskable-192.png 2>/dev/null
        cp Icon-512.png Icon-maskable-512.png 2>/dev/null
    elif command -v rsvg-convert &> /dev/null; then
        rsvg-convert Icon-192.svg -w 192 -h 192 -o Icon-192.png 2>/dev/null || echo "rsvg-convert failed"
        rsvg-convert Icon-512.svg -w 512 -h 512 -o Icon-512.png 2>/dev/null || echo "rsvg-convert failed"
        cp Icon-192.png Icon-maskable-192.png 2>/dev/null
        cp Icon-512.png Icon-maskable-512.png 2>/dev/null
    else
        echo "No SVG to PNG converter available. SVG files created as fallback."
        # Copy SVG as "png" for now - browser will handle it
        cp Icon-192.svg Icon-192.png
        cp Icon-512.svg Icon-512.png
        cp Icon-192.svg Icon-maskable-192.png
        cp Icon-512.svg Icon-maskable-512.png
    fi
else
    # Use ImageMagick to create icons
    convert -size 192x192 -background "gradient:#667eea-#764ba2" -gravity center -fill white -font Arial-Bold -pointsize 100 label:F -bordercolor none -border 20 Icon-192.png
    convert -size 512x512 -background "gradient:#667eea-#764ba2" -gravity center -fill white -font Arial-Bold -pointsize 280 label:F -bordercolor none -border 50 Icon-512.png
    cp Icon-192.png Icon-maskable-192.png
    cp Icon-512.png Icon-maskable-512.png
fi

echo "Icons created successfully"
