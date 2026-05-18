<!DOCTYPE html><html class="dark" lang="en"><head>
<meta charset="utf-8">
<meta content="width=device-width, initial-scale=1.0" name="viewport">
<script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&amp;display=swap" rel="stylesheet">
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap" rel="stylesheet">
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap" rel="stylesheet">
<script id="tailwind-config">
      tailwind.config = {
        darkMode: "class",
        theme: {
          extend: {
            "colors": {
                    "surface-container-low": "#131b2e",
                    "surface-tint": "#adc6ff",
                    "primary-fixed": "#d8e2ff",
                    "inverse-surface": "#dae2fd",
                    "outline-variant": "#424754",
                    "surface-container-high": "#222a3d",
                    "on-tertiary": "#003824",
                    "on-primary-container": "#00285d",
                    "primary-fixed-dim": "#adc6ff",
                    "on-tertiary-container": "#00311f",
                    "secondary-fixed": "#d8e3fb",
                    "on-secondary": "#263143",
                    "surface-variant": "#2d3449",
                    "surface": "#0b1326",
                    "on-primary-fixed-variant": "#004395",
                    "background": "#0b1326",
                    "on-primary": "#002e6a",
                    "on-secondary-fixed-variant": "#3c475a",
                    "surface-bright": "#31394d",
                    "tertiary": "#4edea3",
                    "surface-dim": "#0b1326",
                    "outline": "#8c909f",
                    "on-secondary-container": "#aeb9d0",
                    "on-background": "#dae2fd",
                    "error-container": "#93000a",
                    "secondary": "#bcc7de",
                    "tertiary-container": "#00a572",
                    "error": "#ffb4ab",
                    "tertiary-fixed": "#6ffbbe",
                    "on-secondary-fixed": "#111c2d",
                    "surface-container-highest": "#2d3449",
                    "inverse-primary": "#005ac2",
                    "secondary-container": "#3e495d",
                    "inverse-on-surface": "#283044",
                    "on-primary-fixed": "#001a42",
                    "on-tertiary-fixed-variant": "#005236",
                    "tertiary-fixed-dim": "#4edea3",
                    "primary": "#adc6ff",
                    "secondary-fixed-dim": "#bcc7de",
                    "on-error": "#690005",
                    "primary-container": "#4d8eff",
                    "on-surface": "#dae2fd",
                    "on-tertiary-fixed": "#002113",
                    "surface-container": "#171f33",
                    "on-surface-variant": "#c2c6d6",
                    "surface-container-lowest": "#060e20",
                    "on-error-container": "#ffdad6"
            },
            "borderRadius": {
                    "DEFAULT": "0.25rem",
                    "lg": "0.5rem",
                    "xl": "0.75rem",
                    "full": "9999px"
            },
            "spacing": {
                    "margin-mobile": "16px",
                    "sidebar-width": "280px",
                    "toolbar-width": "64px",
                    "unit": "4px",
                    "gutter": "16px",
                    "margin-desktop": "24px"
            },
            "fontFamily": {
                    "headline-lg": ["Inter"],
                    "label-md": ["Inter"],
                    "title-md": ["Inter"],
                    "label-sm": ["Inter"],
                    "headline-md": ["Inter"],
                    "body-md": ["Inter"],
                    "headline-lg-mobile": ["Inter"],
                    "body-lg": ["Inter"],
                    "display-lg": ["Inter"]
            },
            "fontSize": {
                    "headline-lg": ["32px", {"lineHeight": "40px", "letterSpacing": "-0.01em", "fontWeight": "600"}],
                    "label-md": ["12px", {"lineHeight": "16px", "letterSpacing": "0.01em", "fontWeight": "500"}],
                    "title-md": ["18px", {"lineHeight": "24px", "fontWeight": "500"}],
                    "label-sm": ["11px", {"lineHeight": "14px", "letterSpacing": "0.03em", "fontWeight": "600"}],
                    "headline-md": ["24px", {"lineHeight": "32px", "fontWeight": "600"}],
                    "body-md": ["14px", {"lineHeight": "20px", "fontWeight": "400"}],
                    "headline-lg-mobile": ["24px", {"lineHeight": "32px", "fontWeight": "600"}],
                    "body-lg": ["16px", {"lineHeight": "24px", "fontWeight": "400"}],
                    "display-lg": ["48px", {"lineHeight": "56px", "letterSpacing": "-0.02em", "fontWeight": "700"}]
            }
          },
        },
      }
    </script>
<style>
        .material-symbols-outlined {
            font-variation-settings: 'FILL' 0, 'wght' 400, 'GRAD' 0, 'opsz' 24;
        }
        .glass-overlay {
            background: rgba(30, 41, 59, 0.7);
            backdrop-filter: blur(12px);
            border-top: 1px solid rgba(255, 255, 255, 0.1);
        }
        ::-webkit-scrollbar { width: 6px; }
        ::-webkit-scrollbar-track { background: transparent; }
        ::-webkit-scrollbar-thumb { background: #334155; border-radius: 10px; }
        ::-webkit-scrollbar-thumb:hover { background: #475569; }
    </style>
</head>
<body class="bg-background text-on-background font-body-md text-body-md overflow-hidden">
<!-- Global Side Navigation (Rail) -->
<aside class="fixed left-0 top-0 h-screen w-[64px] bg-surface-container-low border-r border-outline-variant flex flex-col items-center py-4 gap-8 z-50">
<div class="font-headline-md text-headline-md font-bold text-primary">P</div>
<nav class="flex flex-col gap-6 w-full items-center">
<button class="flex flex-col items-center gap-1 group text-primary border-r-2 border-primary w-full py-2 cursor-pointer active:scale-95 transition-colors">
<span class="material-symbols-outlined" data-icon="grid_view" style="font-variation-settings: &quot;FILL&quot; 1;">grid_view</span>
<span class="font-label-md text-label-md">Workspace</span>
</button>
<button class="flex flex-col items-center gap-1 group text-on-surface-variant hover:bg-surface-variant w-full py-2 cursor-pointer active:scale-95 transition-colors">
<span class="material-symbols-outlined" data-icon="auto_awesome_motion">auto_awesome_motion</span>
<span class="font-label-md text-label-md">Templates</span>
</button>
<button class="flex flex-col items-center gap-1 group text-on-surface-variant hover:bg-surface-variant w-full py-2 cursor-pointer active:scale-95 transition-colors mt-auto">
<span class="material-symbols-outlined" data-icon="settings">settings</span>
<span class="font-label-md text-label-md">Settings</span>
</button>
</nav>
</aside>
<!-- Top App Bar -->
<header class="fixed top-0 right-0 left-[64px] h-[64px] bg-surface-container-highest/70 backdrop-blur-xl border-b border-outline-variant flex justify-between items-center px-6 z-40 shadow-sm">
<div class="flex items-center gap-4">
<span class="font-title-md text-title-md font-semibold text-on-surface">Inbox</span>
<span class="text-on-surface-variant font-body-md opacity-60">/Pictures/Collage_Inbox</span>
</div>
<div class="flex items-center gap-6">
<button class="text-primary font-bold hover:text-primary transition-all duration-200 font-label-sm text-label-sm">Change Folder</button>
<div class="flex items-center gap-4">
<span class="material-symbols-outlined text-on-surface-variant cursor-pointer hover:text-primary transition-colors" data-icon="notifications">notifications</span>
<span class="material-symbols-outlined text-on-surface-variant cursor-pointer hover:text-primary transition-colors" data-icon="help">help</span>
<div class="w-8 h-8 rounded-full bg-primary-container flex items-center justify-center text-on-primary-container font-bold text-xs">JD</div>
</div>
</div>
</header>
<!-- Main Workspace Area -->
<main class="ml-[64px] mt-[64px] mb-[24px] h-[calc(100vh-88px)] flex">
<!-- Left Panel: Image Gallery -->
<section class="w-[320px] bg-surface-container border-r border-outline-variant flex flex-col">
<div class="p-4 border-b border-outline-variant flex justify-between items-center bg-surface-container-high/50">
<h2 class="font-title-md text-title-md font-semibold">Library</h2>
<div class="flex gap-2">
<span class="material-symbols-outlined text-sm text-on-surface-variant cursor-pointer" data-icon="sort">sort</span>
<span class="material-symbols-outlined text-sm text-on-surface-variant cursor-pointer" data-icon="search">search</span>
</div>
</div>
<div class="flex-1 overflow-y-auto p-4 space-y-4">
<!-- Gallery Item 1 -->
<div class="group relative bg-surface-container-highest rounded-xl overflow-hidden border border-transparent hover:border-primary transition-all cursor-grab active:cursor-grabbing">
<img alt="Thumbnail" class="w-full h-32 object-cover" data-alt="A professional high-resolution photograph of a vintage film camera sitting on a rustic wooden table. The lighting is moody and dramatic, with soft morning sunlight streaming through a nearby window, creating long shadows and highlighting the metallic textures of the camera. The overall aesthetic is dark and sophisticated, emphasizing technical precision and artistic nostalgia." src="https://lh3.googleusercontent.com/aida-public/AB6AXuALkaAlScMjrbqwAOvGlM-aEA35zPhm9ubN8e-ZZCHCIHbMLQEbnjh2uwJ4nQDLlIwSLJR6GyLNhvqGG1OoaUO_WIhn3Tcf71oustjMJi4e3Dji2HEKx4eHVfnF8Ldk-5efv2C2GklmqvFq0RsDCJqQh8OFDo2hgY5hPa5WAcQYaiXt3dE74Yi72k4CL9gHXDxJHlU3-25KNY9xtsJJaDUTPakfv4qEyDf0aZ-EiiNCUMRmIZw-Or2LqdYGuzmP2kcDWrHJlK7hbrWU">
<div class="p-2">
<p class="font-label-sm text-label-sm text-on-surface truncate">DSC_0842.jpg</p>
<p class="text-[10px] text-on-surface-variant uppercase">Just Now</p>
</div>
</div>
<!-- Gallery Item 2 -->
<div class="group relative bg-surface-container-highest rounded-xl overflow-hidden border border-transparent hover:border-primary transition-all cursor-grab">
<img alt="Thumbnail" class="w-full h-32 object-cover" data-alt="A cinematic architectural shot of a modern brutalist concrete building against a deep navy twilight sky. The sharp geometric lines of the structure are illuminated by minimalist white LED strips, creating a high-contrast and professional look. The atmosphere is quiet and enabling, showcasing structural elegance and dark-mode photographic excellence." src="https://lh3.googleusercontent.com/aida-public/AB6AXuD7i4W1Y_M2-ODylF7hDn_B9ZzaHbsAgQVJTe4dKZwS9rFPvcdQpDUWIMYyr0SDs3M8wQHeITkKgjoFm0maxG0FwV2SQva97mnvSJyVbp2huGE_2Av-EPvWif3Hs707nWVV5kL1haJAcsaH2inpm2XAUy41k2O6_hOhaq5cCvKRDDn7sJzM19VNErSYWf70lCAfUcj8xc6xDzQzUGf3mKlbOba4MbVcntScH3XFpOanUdyBGLtYYDZXAsiLdeviDZxwQSb4lDa3u5oC">
<div class="p-2">
<p class="font-label-sm text-label-sm text-on-surface truncate">ARCH_WORK_01.png</p>
<p class="text-[10px] text-on-surface-variant uppercase">2 mins ago</p>
</div>
</div>
<!-- Gallery Item 3 -->
<div class="group relative bg-surface-container-highest rounded-xl overflow-hidden border border-transparent hover:border-primary transition-all cursor-grab">
<img alt="Thumbnail" class="w-full h-32 object-cover opacity-80" data-alt="An ethereal forest landscape captured with a shallow depth of field, focusing on a single vibrant green fern amidst a sea of dark, blurred pines. The lighting is diffused and soft, as if filtered through a thick mist, creating a serene and creative mood. The color palette is dominated by deep forest greens and slate grays, perfectly aligned with a professional creative tool aesthetic." src="https://lh3.googleusercontent.com/aida-public/AB6AXuBB0LefoXdGnVXPfTV1NNSzn6qFOPAsmNklSamFe2zRoUSbKD3813RR51SKIdhSrZR22x81htGEQpXdcbl7b9rI--2XOPR4z-y4P9zZnlvcop02IycMnEHP4ccwrk-Ur2OeS78KkkBze9MM9UaMQ-sDdeOaS3FPS0bUs9AoezsqSBcFiMEL9J65BaIm16NYt50mB3fMAROPCPqPxFrcgcOVeBcxzKe8N-Ypd2dsHbt6iQ6dKlIMecyftGzVM7J-TEWgWyIzU8Kp2fW-">
<div class="p-2">
<p class="font-label-sm text-label-sm text-on-surface truncate">NATURE_RAW_9.jpg</p>
<p class="text-[10px] text-on-surface-variant uppercase">15 mins ago</p>
</div>
</div>
<!-- Gallery Item 4 -->
<div class="group relative bg-surface-container-highest rounded-xl overflow-hidden border border-transparent hover:border-primary transition-all cursor-grab">
<img alt="Thumbnail" class="w-full h-32 object-cover" data-alt="A macro shot of a sleek, black smartphone camera lens reflecting a neon-lit city street at night. The image is filled with vibrant streaks of blue and magenta light, contrasting sharply against the matte black surface of the device. The composition is technical and precise, evoking a sense of modern digital creativity and high-end hardware performance." src="https://lh3.googleusercontent.com/aida-public/AB6AXuC7ThMwWs3SsTnDrUu-C7zXpzn3c5M2QrXeULwTuvv28xgktIwG82bheqICCJTa0Xt1j_DJN89LF-75oOfflI7kfU3snkx4iTWkRsDZqROQdQab6jppDwhcVUJloY0lPZ6ygk0Hc7fbT_AwjF8GQYColeWdNC9jpMXPAt-KDG4yxooOJFcNdUj9TTtYsrYS4ZL0vNrVcheV1VPLdR_p45L3Vg7BJONR7iL9O6Mdnq8Q4_QLqnWqKXjMO4RHiir1VdlKrfdYOs18I6ip">
<div class="p-2">
<p class="font-label-sm text-label-sm text-on-surface truncate">TECH_DETAIL_44.png</p>
<p class="text-[10px] text-on-surface-variant uppercase">1 hour ago</p>
</div>
</div>
</div>
</section>
<!-- Center: Composer Area -->
<section class="flex-1 bg-surface flex flex-col relative p-8">
<!-- Composer Toolbar -->
<div class="absolute top-4 left-1/2 -translate-x-1/2 flex items-center gap-2 glass-overlay px-4 py-2 rounded-full border border-outline-variant z-10">
<button class="flex items-center gap-2 px-3 py-1.5 hover:bg-surface-variant rounded-lg transition-colors group">
<span class="material-symbols-outlined text-lg group-hover:text-primary" data-icon="refresh">refresh</span>
<span class="font-label-sm text-label-sm">Reset all slots</span>
</button>
<div class="w-[1px] h-4 bg-outline-variant mx-1"></div>
<button class="flex items-center gap-2 px-3 py-1.5 hover:bg-surface-variant rounded-lg transition-colors group">
<span class="material-symbols-outlined text-lg group-hover:text-primary" data-icon="ads_click">ads_click</span>
<span class="font-label-sm text-label-sm">Select slot</span>
</button>
<div class="w-[1px] h-4 bg-outline-variant mx-1"></div>
<button class="flex items-center gap-2 px-3 py-1.5 hover:bg-error rounded-lg transition-colors group">
<span class="material-symbols-outlined text-lg group-hover:text-on-error" data-icon="delete">delete</span>
<span class="font-label-sm text-label-sm group-hover:text-on-error">Delete photo from slot</span>
</button>
</div>
<!-- Canvas/Composer -->
<div class="flex-1 flex items-center justify-center">
<div class="w-full max-w-[500px] aspect-[1/2] grid grid-rows-2 gap-4 bg-surface-container-lowest p-4 rounded-xl border border-outline-variant shadow-2xl relative">
<!-- Slot 1 (Empty) -->
<div class="relative group border-2 border-dashed border-outline rounded-lg flex flex-col items-center justify-center bg-surface-container-low hover:border-primary hover:bg-surface-container transition-all cursor-pointer">
<span class="material-symbols-outlined text-4xl text-outline-variant mb-2" data-icon="add_photo_alternate">add_photo_alternate</span>
<p class="font-label-md text-label-md text-on-surface-variant">Drop image or click to select</p>
<div class="absolute top-2 right-2 bg-surface-container-highest px-2 py-1 rounded text-[10px] font-bold text-on-surface-variant">SLOT 01</div>
</div>
<!-- Slot 2 (Empty) -->
<div class="relative group border-2 border-dashed border-outline rounded-lg flex flex-col items-center justify-center bg-surface-container-low hover:border-primary hover:bg-surface-container transition-all cursor-pointer">
<span class="material-symbols-outlined text-4xl text-outline-variant mb-2" data-icon="add_photo_alternate">add_photo_alternate</span>
<p class="font-label-md text-label-md text-on-surface-variant">Drop image or click to select</p>
<div class="absolute top-2 right-2 bg-surface-container-highest px-2 py-1 rounded text-[10px] font-bold text-on-surface-variant">SLOT 02</div>
</div>
</div>
</div>
<!-- Primary Action Floating -->
<button class="absolute bottom-8 right-8 flex items-center gap-3 bg-primary text-on-primary px-8 py-4 rounded-xl shadow-lg hover:scale-105 active:scale-95 transition-all font-bold">
<span class="material-symbols-outlined" data-icon="ios_share">ios_share</span>
<span class="font-body-lg text-body-lg">Preview &amp; Export</span>
</button>
</section>
<!-- Right Panel: Property Inspector (Contextual) -->
<section class="w-[sidebar-width] bg-surface-container border-l border-outline-variant flex flex-col">
<div class="p-4 border-b border-outline-variant bg-surface-container-high/50">
<h2 class="font-title-md text-title-md font-semibold">Properties</h2>
</div>
<div class="p-4 space-y-6">
<div>
<label class="font-label-sm text-label-sm text-on-surface-variant uppercase block mb-3">Layout Grid</label>
<div class="grid grid-cols-2 gap-2">
<button class="border-2 border-primary bg-primary/10 p-4 rounded-lg flex flex-col items-center">
<span class="material-symbols-outlined text-primary" data-icon="view_agenda">view_agenda</span>
<span class="text-[10px] mt-1 text-primary">1x2 Vertical</span>
</button>
<button class="border border-outline-variant hover:bg-surface-variant p-4 rounded-lg flex flex-col items-center">
<span class="material-symbols-outlined text-on-surface-variant" data-icon="view_column">view_column</span>
<span class="text-[10px] mt-1 text-on-surface-variant">2x1 Horizontal</span>
</button>
</div>
</div>
<div class="space-y-4">
<label class="font-label-sm text-label-sm text-on-surface-variant uppercase block">Canvas Settings</label>
<div class="space-y-4">
<div>
<div class="flex justify-between text-[11px] mb-2">
<span class="">Border Radius</span>
<span class="text-primary">12px</span>
</div>
<input class="w-full h-1 bg-surface-variant rounded-lg appearance-none cursor-pointer accent-primary" type="range">
</div>
<div>
<div class="flex justify-between text-[11px] mb-2">
<span class="">Inner Padding</span>
<span class="text-primary">8px</span>
</div>
<input class="w-full h-1 bg-surface-variant rounded-lg appearance-none cursor-pointer accent-primary" type="range">
</div>
</div>
</div>
<div class="pt-4 border-t border-outline-variant">
<label class="font-label-sm text-label-sm text-on-surface-variant uppercase block mb-3">Export Format</label>
<div class="flex gap-2">
<span class="px-3 py-1 bg-surface-container-highest text-on-surface rounded-full text-xs cursor-pointer border border-primary">PNG</span>
<span class="px-3 py-1 bg-surface-container-highest text-on-surface-variant rounded-full text-xs cursor-pointer border border-transparent hover:border-outline">JPG</span>
<span class="px-3 py-1 bg-surface-container-highest text-on-surface-variant rounded-full text-xs cursor-pointer border border-transparent hover:border-outline">TIFF</span>
</div>
</div>
</div>
</section>
</main>
<!-- Footer Status Bar -->
<footer class="fixed bottom-0 right-0 left-[64px] h-[24px] bg-surface-container-low border-t border-outline-variant flex items-center justify-between px-4 z-50">
<div class="flex items-center gap-4">
<span class="font-label-sm text-label-sm text-on-surface-variant">System Ready | Watching Folder: /Pictures/Collage_Inbox</span>
</div>
<div class="flex items-center gap-6">
<div class="flex items-center gap-1">
<div class="w-2 h-2 rounded-full bg-tertiary"></div>
<span class="font-label-sm text-label-sm text-tertiary">Export Status: Success</span>
</div>
<span class="font-label-sm text-label-sm text-on-surface-variant">0 Errors</span>
</div>
</footer>
<div class="fixed inset-0 z-[100] flex items-center justify-center bg-black/80 backdrop-blur-sm" id="preview-export-modal">
<div class="bg-surface-container-high w-full max-w-4xl rounded-2xl border border-outline-variant shadow-2xl flex flex-col overflow-hidden max-h-[90vh]">
<!-- Modal Header -->
<div class="flex items-center justify-between p-6 border-b border-outline-variant">
<h2 class="font-headline-md text-headline-md">Preview &amp; Export</h2>
<button class="p-2 hover:bg-surface-variant rounded-full transition-colors">
<span class="material-symbols-outlined text-on-surface-variant">close</span>
</button>
</div>
<!-- Modal Body -->
<div class="flex flex-1 overflow-hidden">
<!-- Preview Area -->
<div class="flex-[2] bg-surface-container-lowest p-8 flex items-center justify-center border-r border-outline-variant">
<div class="relative w-full aspect-[4/3] rounded-lg overflow-hidden border border-outline-variant shadow-lg">
<img alt="Collage Preview" class="w-full h-full object-cover" src="https://www.gstatic.com/labs-code/stitch/stitch-placeholder-300x300.svg">
</div>
</div>
<!-- Settings Panel -->
<div class="flex-1 p-6 flex flex-col gap-8 bg-surface-container-high">
<div class="space-y-6">
<h3 class="font-label-sm text-label-sm text-on-surface-variant uppercase tracking-wider">Export Settings</h3>
<div class="flex items-center justify-between">
<div class="flex items-center gap-3">
<span class="material-symbols-outlined text-primary">print</span>
<span class="font-body-md">Print after export</span>
</div>
<div class="w-10 h-6 bg-primary rounded-full relative cursor-pointer">
<div class="absolute right-1 top-1 w-4 h-4 bg-on-primary rounded-full shadow-sm"></div>
</div>
</div>
<div class="flex items-center justify-between">
<div class="flex items-center gap-3">
<span class="material-symbols-outlined text-primary">phone_android</span>
<span class="font-body-md">Send to Mobile</span>
</div>
<div class="w-10 h-6 bg-surface-variant rounded-full relative cursor-pointer">
<div class="absolute left-1 top-1 w-4 h-4 bg-outline rounded-full shadow-sm"></div>
</div>
</div>
</div>
<div class="mt-auto">
<div class="p-4 bg-surface-container rounded-lg border border-outline-variant mb-6">
<p class="text-xs text-on-surface-variant leading-relaxed">
              Your collage will be exported in high-quality PNG format at 300 DPI for optimal printing results.
            </p>
</div>
</div>
</div>
</div>
<!-- Modal Footer -->
<div class="p-6 border-t border-outline-variant flex justify-end bg-surface-container-highest/30">
<button class="bg-primary text-on-primary px-10 py-3 rounded-xl font-bold hover:scale-105 active:scale-95 transition-all shadow-lg flex items-center gap-2">
<span class="material-symbols-outlined">rocket_launch</span>
<span class="">Start Now</span>
</button>
</div>
</div>
</div>

</body></html>