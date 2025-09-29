# 🐉 Cleli's Lair - Digital Dragons & Creative Code

<div align="center">

![Version](https://img.shields.io/badge/version-0.0.1-blue.svg?cacheSeconds=2592000)
![Svelte](https://img.shields.io/badge/Svelte-5.0-FF3E00?logo=svelte&logoColor=white)
![Three.js](https://img.shields.io/badge/Three.js-0.180-000000?logo=three.js&logoColor=white)
![TypeScript](https://img.shields.io/badge/TypeScript-5.0-3178C6?logo=typescript&logoColor=white)

**Where dragons meet code and creativity takes flight** 🌟

[Website](https://cleli.de) • [Discord Server](https://discord.gg/7nZKeT5ZTQ) • [GitHub](https://github.com/cleli61)

</div>

---

## 🌋 About This Lair

Welcome to Cleli's digital domain! This repository houses a modern web application built with the latest web technologies. Like a dragon's treasure hoard, it contains carefully crafted interactive experiences, from elegant landing pages to mesmerizing 3D visualizations.

### ✨ Current Treasures

- **🏠 Landing Page** - A sleek contact hub with theme switching
- **🧪 Test Lab** - Experimental features and demos
- **🎨 Three.js Playground** - Interactive 3D graphics with customizable:
  - Multiple geometries (Sphere, Torus, Cube, Dodecahedron)
  - Dynamic particle systems (100-5000 particles)
  - Rainbow and solid color schemes
  - Real-time animation controls
  - Wireframe rendering mode

## 🔥 Tech Stack

This dragon flies on modern wings:

| Technology | Purpose | Why? |
|-----------|---------|------|
| **[Svelte 5](https://svelte.dev/)** | Framework | Blazingly fast, reactive, and elegant |
| **[SvelteKit](https://kit.svelte.dev/)** | Meta-framework | File-based routing, SSR/SSG capabilities |
| **[Three.js](https://threejs.org/)** | 3D Graphics | WebGL made simple and powerful |
| **[TypeScript](https://www.typescriptlang.org/)** | Type Safety | Catch bugs before they hatch |
| **[Tailwind CSS 4](https://tailwindcss.com/)** | Styling | Utility-first CSS with DaisyUI |
| **[DaisyUI](https://daisyui.com/)** | Components | Beautiful, accessible UI components |
| **[Bun](https://bun.sh/)** | Runtime & Package Manager | Lightning-fast JavaScript runtime |
| **[Vite](https://vitejs.dev/)** | Build Tool | Next-gen frontend tooling |

## 🚀 Quick Start

### Prerequisites

- [Bun](https://bun.sh/) installed on your system
- A dragon's patience (just kidding, it's really fast!)

### Installation

```bash
# Clone the treasure
git clone https://github.com/cleli61/cleli.git
cd cleli

# Install dependencies with Bun's speed
bun install
```

### Development

```bash
# Start the dev server
bun run dev

# Open your browser to http://localhost:5173
# Watch the magic happen! ✨
```

### Building for Production

```bash
# Build the production bundle
bun run build

# Preview the production build
bun run preview
```

### Code Quality

```bash
# Type checking
bun run check

# Watch mode for type checking
bun run check:watch

# Lint your code
bun run lint

# Format with Prettier
bun run format
```

## 🗺️ Project Structure

```
cleli/
├── src/
│   ├── routes/                 # SvelteKit file-based routing
│   │   ├── +page.svelte       # Landing page
│   │   ├── +layout.svelte     # Root layout
│   │   ├── tests/             # Test/Demo pages
│   │   └── threejs/           # Three.js 3D demo
│   ├── lib/                   # Reusable components & utilities
│   │   ├── DiscordIcon.svelte
│   │   └── index.svelte.ts
│   └── app.html               # HTML template
├── static/                    # Static assets
│   └── favicon.png
├── package.json               # Project dependencies
├── svelte.config.js          # Svelte configuration
├── vite.config.ts            # Vite configuration
├── tsconfig.json             # TypeScript configuration
└── eslint.config.js          # ESLint configuration
```

## 🎮 Features Showcase

### Three.js Demo Page

An interactive 3D visualization playground featuring:

- **🎭 Multiple Geometries**: Switch between sphere, torus, cube, and dodecahedron
- **🌈 Dynamic Coloring**: Rainbow animation or solid colors (blue, red, purple)
- **⭐ Particle System**: Adjustable particle count with spherical distribution
- **🎬 Animation Controls**: Play/pause, rotation speed adjustment
- **📐 Wireframe Mode**: Toggle between solid and wireframe rendering
- **🎯 Camera Controls**: Reset camera to default position
- **🌗 Theme Toggle**: Light and dark mode support

### Landing Page

- **📧 Contact Information**: Email, Discord, GitHub links
- **🎨 Responsive Design**: Beautiful on all devices
- **🌓 Dark Mode**: Persistent theme selection
- **💎 Modern UI**: DaisyUI components with glass morphism effects

## 🛠️ Development Philosophy

This project embraces:

- **🎯 Modern Best Practices**: ESM, TypeScript, strict linting
- **⚡ Performance First**: Optimized builds, lazy loading, efficient rendering
- **🎨 Design Excellence**: Attention to detail, smooth animations, intuitive UX
- **♿ Accessibility**: Semantic HTML, ARIA labels, keyboard navigation
- **📱 Responsive**: Mobile-first approach, works everywhere

## 🐲 Connect with the Dragon

- **📧 Email**: [hello@cleli.de](mailto:hello@cleli.de)
- **💬 Discord**: @cleli
- **🏰 Discord Server**: [I love Dragons](https://discord.gg/7nZKeT5ZTQ) (Join the dragon enthusiasts!)
- **💻 GitHub**: [@cleli61](https://github.com/cleli61)

## 📄 License

This project is private and proprietary. All rights reserved.

## 🌟 Acknowledgments

Built with love, coffee, and a healthy dose of dragon magic! 🐉☕✨

Special thanks to:
- The Svelte team for creating such an elegant framework
- The Three.js community for making 3D graphics accessible
- The open-source community for all the amazing tools

---

<div align="center">

**"Not all those who wander are lost, but those who code with dragons are definitely having more fun!"**

Made with 🔥 by Cleli

</div>